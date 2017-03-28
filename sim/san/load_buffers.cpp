#include "headers/load_buffers.h"

void load_field_buffer(std::bitset<OUTPUT_BUFFER_SIZE> *output_buffer, std::queue<uint64_t> *field_buffer){

	for(int i=0;i<OUTPUT_BUFFER_SIZE/64;i++){

		std::bitset<64> temp_bits;
		for(int j=0;j<64;j++){
			temp_bits[j] = output_buffer->test(64*i + j);
		}
		field_buffer->push(temp_bits.to_ulong());

	}
}

void load_field_offset(std::bitset<OFFSET_BUFFER_SIZE> *offset_buffer, std::queue<uint64_t> *offset_queue){

	for(int i=0;i<OFFSET_BUFFER_SIZE/64;i++){

		std::bitset<64> temp_bits;
		for(int j=0;j<64;j++){
			temp_bits[j] = offset_buffer->test(64*i + j);
		}
		offset_queue->push(temp_bits.to_ulong());

	}	
}

void load_field_ext(std::bitset<EXTRACT_BUFFER_SIZE> *ext_buffer, std::queue<uint64_t> *field_extracted){

	for(int i=0;i<EXTRACT_BUFFER_SIZE/64;i++){

		std::bitset<64> temp_bits;
		for(int j=0;j<64;j++){
			temp_bits[j] = ext_buffer->test(64*i + j);
		}
		field_extracted->push(temp_bits.to_ulong());

	}	
}

void load_hdr_seq(std::bitset<HDR_SEQ_BUFFER_SIZE> *hdr_seq_buffer, std::queue<uint64_t> *header_queue){

	for(int i=0;i<HDR_SEQ_BUFFER_SIZE/64;i++){

		std::bitset<64> temp_bits;
		for(int j=0;j<64;j++){
			temp_bits[j] = hdr_seq_buffer->test(64*i + j);
		}
		header_queue->push(temp_bits.to_ulong());

	}	
}