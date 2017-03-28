#include "headers/load_output_buffer.h"

void load_output_buffer(bitset<OUTPUT_BUFFER_SIZE> *output_buffer, bitset<PREFETCH_WORD_SIZE> *prefetched_frame, int *output_buffer_pointer){

	for(int i=0; i<PREFETCH_WORD_SIZE; i++){								//load the output buffer before a prefetch
		output_buffer->set(*output_buffer_pointer+i, prefetched_frame->test(i));
	}
	*output_buffer_pointer += PREFETCH_WORD_SIZE;
	//cout << "output buffer " << *output_buffer << endl;

}

void load_offset_buffer(int header_id, int field_id, bitset<OFFSET_BUFFER_SIZE>	*offset_buffer, int *offset_buffer_pointer, bitset<FIELD_OFFSET_WIDTH> *field_offset){

	bitset<3> 	header_bits 	= bitset<3>(header_id);
	bitset<5> 	field_bits		= bitset<5>(field_id);
	for(int i=0; i<3; i++){
		offset_buffer->set(*offset_buffer_pointer + i, header_bits.test(i));
	}
	for(int i=0; i<5; i++){
		offset_buffer->set(*offset_buffer_pointer + 3 + i, field_bits.test(i));
	}
	for(int i=0; i<FIELD_OFFSET_WIDTH; i++){
		offset_buffer->set(*offset_buffer_pointer + 8 + i, field_offset->test(i));
	}
	*offset_buffer_pointer += (8 + FIELD_OFFSET_WIDTH);
}

void update_hdr_seq(int header_id, bitset<HDR_SEQ_BUFFER_SIZE>	*hdr_seq_buffer, int *hdr_seq_buf_pointer){

	bitset<64> temp_hdr_id;
	temp_hdr_id		=	bitset<64>(header_id);
	for(int i=0; i<64; i++){
		hdr_seq_buffer->set(*hdr_seq_buf_pointer + i, temp_hdr_id.test(i));
	}
	*hdr_seq_buf_pointer += 64;
}