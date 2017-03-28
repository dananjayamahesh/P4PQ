/*
 *  load_flag.h
 *
 *  Created on: March 14, 2017
 *      Author: sandaruwan
 */

#include <iostream>
#include <bitset>

#define PREFETCH_WORD_SIZE 			512
#define OUTPUT_BUFFER_SIZE			4096
#define OFFSET_BUFFER_SIZE			4096
#define HDR_SEQ_BUFFER_SIZE			1024
#define FIELD_OFFSET_WIDTH			10

void load_output_buffer(std::bitset<OUTPUT_BUFFER_SIZE> *output_buffer, std::bitset<PREFETCH_WORD_SIZE> *prefetched_frame, int *output_buffer_pointer);

void load_offset_buffer(int header_id, int field_id, std::bitset<OFFSET_BUFFER_SIZE>	*offset_buffer, int *offset_buffer_pointer, std::bitset<FIELD_OFFSET_WIDTH> *field_offset);

void update_hdr_seq(int header_id, std::bitset<HDR_SEQ_BUFFER_SIZE>	*hdr_seq_buffer, int *hdr_seq_buf_pointer);