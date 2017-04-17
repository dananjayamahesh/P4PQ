#include "headers/Parser.h"

std::queue<uint64_t> field_buffer;
std::queue<uint64_t> offset_queue;
std::queue<uint64_t>	field_extracted;
std::queue<uint64_t>	header_queue;

void Parser::run(){
    int 						i_ret;
    PacketReaderSan 			*pkt_reader;                                    
	PktPreProcessorSan 			*pkt_preprocessor;
    std::bitset<PREFETCH_WORD_SIZE> 	prefetched_frame;								//internal buffer
    char 						* ptr;

    pkt_reader 													= 	new PacketReaderSan();
    pkt_preprocessor 											= 	new PktPreProcessorSan();

    i_ret 		= pkt_reader->open_file("dialog2.pcap"); 	//name of the pcap file
    if (i_ret != SUCCESS) {
        //cout << "failed to open pcap file" << endl;
    }else {
        //cout << "successfully opened pcap file" << endl;
    }

    packet p;                                           						//struct NetworkPkts.h ,vector

//-------------------------loop for each packet-----------------------------------------------------------------------------------------------------------------------																
    for (uint i = 0; i < (uint) NO_PACKETS; i++) {																		

    	int 						header_start_pointer 		= 0;			//keep the offset to header starting point from packet beginning

    	int 						output_buffer_pointer 		= 0;			//keep the starting point to write to output buffer
    	std::bitset<OUTPUT_BUFFER_SIZE> 	output_buffer;								//parsed field vector

		int 						offset_buffer_pointer 		= 0;
		std::bitset<OFFSET_BUFFER_SIZE>	offset_buffer;								//keep field offsets

		int 						ext_buffer_pointer 			= 0;			//keep offset for extracted fields in extraction buffer
		std::bitset<EXTRACT_BUFFER_SIZE>	ext_buffer;

		int 						hdr_seq_buf_pointer			= 0;			//keep the pointer for header sequence buffer
		std::bitset<HDR_SEQ_BUFFER_SIZE>	hdr_seq_buffer;
        
        rd_pktSan 						rp;                                      	//struct PacketReader.h
        
        pkt_reader->GetNextPacket(rp);                  						//read the next packet in the pcap file
        i_ret 					= 	pkt_preprocessor->ConvertPkt(rp, p);    	//convert according to we needed(as hardwear), and packet is stored in the vector packet
        if (i_ret != SUCCESS) {
            //cout << "failed to convert packet" << endl;
        }
        //cout <<"external buffer size "<< p.frame_set.size() << endl;

        prefetched_frame 										= load_prefetcher(&p);

		//cout << "prefetched_frame " << prefetched_frame << endl;

    	//state machine
    	int entry_no 											= 	1; 			//header entry(symbolize the current header)

    	loop:

    	std::string ram_entry;
    	std::ifstream myfile ("../sim/san/current_state_ram.txt");
		if (myfile.is_open()){
			int current_index = 1;												//current search entry
		    while ( getline (myfile,ram_entry) ){
		    	if(current_index != entry_no){
		    		current_index++;
		    		continue;
		    	}else{

			///////////////////-----In a header-----///////////////////////////////////////////////////////////////////////////////////////////////////////////

		    		//cout << "header id " << entry_no << endl;
		    		update_hdr_seq(entry_no, &hdr_seq_buffer, &hdr_seq_buf_pointer);

		    		std::bitset<32> header_length;										//keep header length
		    		std::bitset<24> next_type;											//keep the field for next headertype

		    		std::bitset<FIELD_OFFSET_WIDTH> field_offset[MAX_FIELDS_PER_HEADER];	//keep offset of each field

		    		std::bitset<1> enable_flag[MAX_FIELDS_PER_HEADER];
		    		std::bitset<1> header_length_flag[MAX_FIELDS_PER_HEADER];
		    		std::bitset<1> next_field_length_flag[MAX_FIELDS_PER_HEADER];
		    		std::bitset<1> next_headertype_flag[MAX_FIELDS_PER_HEADER];
		    		std::bitset<1> extract_flag[MAX_FIELDS_PER_HEADER];
		    		std::bitset<1> dynamic_length_flag[MAX_FIELDS_PER_HEADER];
		    		std::bitset<FIELD_LENGTH_ENTRY_WIDTH> field_length[MAX_FIELDS_PER_HEADER];

		    		//header length entry
		    		char temp_header_length[HEADER_LENGTH_ENTRY_WIDTH];
				    strcpy(temp_header_length, ram_entry.substr(0 , HEADER_LENGTH_ENTRY_WIDTH).c_str());
		    		header_length = std::bitset<32>(strtol(temp_header_length, & ptr, 2));

		    		//loop for each field
			    	for(int field_id=0; field_id<MAX_FIELDS_PER_HEADER; field_id++){

				    	enable_flag[field_id] 				= 	load_flag(ram_entry, HEADER_LENGTH_ENTRY_WIDTH + 0 + field_id*(6 + FIELD_LENGTH_ENTRY_WIDTH));
				    	header_length_flag[field_id] 		= 	load_flag(ram_entry, HEADER_LENGTH_ENTRY_WIDTH + 1 + field_id*(6 + FIELD_LENGTH_ENTRY_WIDTH));	
				    	next_field_length_flag[field_id] 	= 	load_flag(ram_entry, HEADER_LENGTH_ENTRY_WIDTH + 2 + field_id*(6 + FIELD_LENGTH_ENTRY_WIDTH));
				    	next_headertype_flag[field_id] 		= 	load_flag(ram_entry, HEADER_LENGTH_ENTRY_WIDTH + 3 + field_id*(6 + FIELD_LENGTH_ENTRY_WIDTH));
				    	extract_flag[field_id] 				= 	load_flag(ram_entry, HEADER_LENGTH_ENTRY_WIDTH + 4 + field_id*(6 + FIELD_LENGTH_ENTRY_WIDTH));	
				    	dynamic_length_flag[field_id] 		= 	load_flag(ram_entry, HEADER_LENGTH_ENTRY_WIDTH + 5 + field_id*(6 + FIELD_LENGTH_ENTRY_WIDTH));
				    	field_length[field_id] 				= 	((int)dynamic_length_flag[field_id].to_ulong() == 1) ? field_length[field_id] : load_length(ram_entry, HEADER_LENGTH_ENTRY_WIDTH + 6 + field_id*(6 + FIELD_LENGTH_ENTRY_WIDTH));

				    	//if not enabled ignore
				    	if((int)(enable_flag[field_id].to_ulong()) != 1){
				    		break;
				    	}

				    	field_offset[field_id] = (field_id == 0) ? std::bitset<FIELD_OFFSET_WIDTH>(header_start_pointer) : std::bitset<FIELD_OFFSET_WIDTH>((int)(field_offset[field_id - 1].to_ulong()) + (int)(field_length[field_id - 1].to_ulong()));	//absolute offset of the field
	
				    	load_offset_buffer(entry_no, field_id, &offset_buffer, &offset_buffer_pointer, &field_offset[field_id]);	//load offset buffer

				    	if((int)(header_length_flag[field_id].to_ulong()) == 1){					//if this field carries header length
				    		load_header_length(&p, &header_length, &prefetched_frame, (int)(field_length[field_id].to_ulong()), (int)(field_offset[field_id].to_ulong()), &output_buffer, &output_buffer_pointer);
				    		header_length = std::bitset<32>((int)(header_length.to_ulong())*HEADER_LENGTH_BIT_WORD);
				    		//cout << "header length " << endl;
				    	}

				    	if((int)(next_field_length_flag[field_id].to_ulong()) == 1){				//if this field carries next field length
							load_next_field_length(&p, &field_length[field_id + 1], &prefetched_frame, (int)(field_length[field_id].to_ulong()), (int)(field_offset[field_id].to_ulong()), &output_buffer, &output_buffer_pointer);
				    		//cout << "next field length " << endl;
				    	}

				    	if((int)(next_headertype_flag[field_id].to_ulong()) == 1){					//if this field carries next header type
							load_next_type(&p, &next_type, &prefetched_frame, (int)(field_length[field_id].to_ulong()), (int)(field_offset[field_id].to_ulong()), &output_buffer, &output_buffer_pointer);
				    		//cout << "next header type " << endl;
				    		//cout << "offset " << (int)(field_offset[field_id].to_ulong()) << endl;
				    		//cout << "length " << (int)(field_length[field_id].to_ulong()) << endl;
				    	}				    	

				    	if(((int)(extract_flag[field_id].to_ulong())) == 1 && ((int)(dynamic_length_flag[field_id].to_ulong())) == 0){		//extract for DPI
							load_extraction(&p, &ext_buffer, &ext_buffer_pointer, &prefetched_frame, (int)(field_length[field_id].to_ulong()), (int)(field_offset[field_id].to_ulong()), &output_buffer, &output_buffer_pointer);
				    		//cout << "extraction " << endl;
				    	}

				    	if(((int)(extract_flag[field_id].to_ulong())) == 1 && ((int)(dynamic_length_flag[field_id].to_ulong())) == 1){		//find dynamic last field length															    	
		    				field_length[field_id] = std::bitset<FIELD_LENGTH_ENTRY_WIDTH>((int)(header_length.to_ulong()) - ((int)(field_offset[field_id].to_ulong()) - header_start_pointer));
		    				//cout << "dynamic length " << endl;
		    			}

		    			if((int)(header_length_flag[field_id].to_ulong()) == 0 && (int)(next_field_length_flag[field_id].to_ulong()) == 0 && (int)(next_headertype_flag[field_id].to_ulong()) == 0 && (int)(extract_flag[field_id].to_ulong()) == 0 && (int)(dynamic_length_flag[field_id].to_ulong()) == 0 && (field_offset[field_id].to_ulong() / PREFETCH_WORD_SIZE != field_offset[field_id - 1].to_ulong() / PREFETCH_WORD_SIZE) && field_id != 0){ //No extraction but field length go out of prefetcher range
				     		//cout << "prefetch field id" <<  field_id << endl;
				     		load_output_buffer(&output_buffer, &prefetched_frame, &output_buffer_pointer);
				     		prefetched_frame 	=	load_prefetcher(&p);
		    			}

		    		}	//end loop for each the field

		    		header_start_pointer += (int)(header_length.to_ulong());	//update header start pointer

		    		//find next header
			     	std::string next_header_ram_entry;
			     	std::string next_header_lookup 	= 	(std::bitset<HEADER_ENTRY_WIDTH> (entry_no)).to_string() + next_type.to_string();
			     	//cout <<"lookup value "<< next_header_lookup << endl;
			     	std::ifstream myfile1 ("../sim/san/next_state_ram.txt");
			     	if(myfile1.is_open()){
			     		while(getline(myfile1, next_header_ram_entry)){
			     			
			     			if((next_header_ram_entry.substr(0, HEADER_ENTRY_WIDTH + NEXT_HEADERTYPE_ENTRY_WIDTH)).compare(next_header_lookup)==0){
			     				char temp_next_header[HEADER_ENTRY_WIDTH];
			     				char * ptr2;
			     				strcpy(temp_next_header, next_header_ram_entry.substr(HEADER_ENTRY_WIDTH + NEXT_HEADERTYPE_ENTRY_WIDTH, HEADER_ENTRY_WIDTH).c_str());
			     				entry_no 	= 	strtol(temp_next_header, & ptr2, 2);
			     				//cout << "entry found " << entry_no << endl;
			     				myfile.close();
			     				myfile1.close();
			     				goto loop;
			     				
			     			}else{
			     				continue;
			     			}
			     		}
			     		myfile1.close();

			     		//No entry in RAM for next header type
			    		//cout << "end parsing" << endl;

			    		load_output_buffer(&output_buffer, &prefetched_frame, &output_buffer_pointer);	//Add to packet data queue

			    		std::queue<uint64_t> empty_queue;
			    		p.frame_set 	= 	empty_queue;		//empty the external buffer after packet
			    		break;									//no further parsing: break and go to next packet
			     	}
		    	}
				myfile.close();
			}
			//////////////////////-----end of header-------/////////////////////////////////////////////////////////////////////////////////////////////////////
    	}	                                     	
    	load_field_buffer(&output_buffer, &field_buffer);	//load field_buffer
    	load_field_offset(&offset_buffer, &offset_queue);	//Add to offset queue
    	load_field_ext(&ext_buffer, &field_extracted);		//Add to extraction queue
    	load_hdr_seq(&hdr_seq_buffer, &header_queue);		//Add to header sequence queue
	}
//----------end of packet---------------------------------------------------------------------------------------------------------------------------------------

}

uint64_t Parser::get_field_buffer_word(
	)
{
	uint64_t word 	=	field_buffer.front();
	field_buffer.pop();
	return word;
}

uint64_t Parser::get_offset_queue_word(
	)
{
	uint64_t word 	=	offset_queue.front();
	offset_queue.pop();
	return word;
}

uint64_t Parser::get_ext_queue_word(
	)
{
	uint64_t word 	=	field_extracted.front();
	field_extracted.pop();
	return word;
}

uint64_t Parser::get_hdr_Seq_queue_word(
	)
{
	uint64_t word 	=	header_queue.front();
	header_queue.pop();
	return word;
}
