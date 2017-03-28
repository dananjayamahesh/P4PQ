#include "headers/extract_prefetcher.h"

void load_header_length(packet *p, bitset<32> *header_length, bitset<PREFETCH_WORD_SIZE> *prefetched_frame, int field_length, int field_offset, bitset<OUTPUT_BUFFER_SIZE> *output_buffer, int *output_buffer_pointer){

	int word_no = (int)(field_offset / PREFETCH_WORD_SIZE);

	for(int i=0; i<field_length; i++){

		if((field_offset + i) / PREFETCH_WORD_SIZE > word_no){

			load_output_buffer(output_buffer, prefetched_frame, output_buffer_pointer);
			word_no++;
			*prefetched_frame 		= load_prefetcher(p);
		}

		header_length->set(field_length - (i+1), prefetched_frame->test((field_offset + i) % PREFETCH_WORD_SIZE));
	}
}

void load_next_field_length(packet *p, bitset<FIELD_LENGTH_ENTRY_WIDTH> *field_len, bitset<PREFETCH_WORD_SIZE> *prefetched_frame, int field_length, int field_offset, bitset<OUTPUT_BUFFER_SIZE> *output_buffer, int *output_buffer_pointer){

	int word_no = (int)(field_offset / PREFETCH_WORD_SIZE);

	for(int i=0; i<field_length; i++){

		if((field_offset + i) / PREFETCH_WORD_SIZE > word_no){

			load_output_buffer(output_buffer, prefetched_frame, output_buffer_pointer);
			word_no++;
			*prefetched_frame 		= load_prefetcher(p);
		}

		field_len->set(field_length - (i+1), prefetched_frame->test((field_offset + i) % PREFETCH_WORD_SIZE));
	}
}

void load_next_type(packet *p, bitset<24> *next_type, bitset<PREFETCH_WORD_SIZE> *prefetched_frame, int field_length, int field_offset, bitset<OUTPUT_BUFFER_SIZE> *output_buffer, int *output_buffer_pointer){

	int word_no = (int)(field_offset / PREFETCH_WORD_SIZE);

	for(int i=0; i<field_length; i++){

		if((field_offset + i) / PREFETCH_WORD_SIZE > word_no){

			load_output_buffer(output_buffer, prefetched_frame, output_buffer_pointer);
			word_no++;
			*prefetched_frame 		= load_prefetcher(p);
		}

		next_type->set(field_length - (i+1), prefetched_frame->test((field_offset + i) % PREFETCH_WORD_SIZE));
	}
}

void load_extraction(packet *p, bitset<EXTRACT_BUFFER_SIZE>	*ext_buffer, int *ext_buffer_pointer, bitset<PREFETCH_WORD_SIZE> *prefetched_frame, int field_length, int field_offset, bitset<OUTPUT_BUFFER_SIZE> *output_buffer, int *output_buffer_pointer){

	int word_no = (int)(field_offset / PREFETCH_WORD_SIZE);

	for(int i=0; i<field_length; i++){

		if((field_offset + i) / PREFETCH_WORD_SIZE > word_no){

			load_output_buffer(output_buffer, prefetched_frame, output_buffer_pointer);
			word_no++;
			*prefetched_frame 		= load_prefetcher(p);
		}

		ext_buffer->set(*ext_buffer_pointer + i, prefetched_frame->test((field_offset + i) % PREFETCH_WORD_SIZE));
		*ext_buffer_pointer = *ext_buffer_pointer + field_length;
	}
}