/*
 *  load_flag.h
 *
 *  Created on: March 14, 2017
 *      Author: sandaruwan
 */

#include <iostream>
#include <bitset>

#include "pcappkts.h"
#include "load_prefetcher.h"
#include "load_output_buffer.h"

#define PREFETCH_WORD_SIZE 			512
#define FIELD_LENGTH_ENTRY_WIDTH	9
#define OUTPUT_BUFFER_SIZE			4096
#define EXTRACT_BUFFER_SIZE			4096

using namespace std;

void load_header_length(packet *p, bitset<32> *header_length, bitset<PREFETCH_WORD_SIZE> *prefetched_frame, int field_length, int field_offset, bitset<OUTPUT_BUFFER_SIZE> 	*output_buffer, int *output_buffer_pointer);

void load_next_field_length(packet *p, bitset<FIELD_LENGTH_ENTRY_WIDTH> *field_len, bitset<PREFETCH_WORD_SIZE> *prefetched_frame, int field_length, int field_offset, bitset<OUTPUT_BUFFER_SIZE> *output_buffer, int *output_buffer_pointer);

void load_next_type(packet *p, bitset<24> *next_type, bitset<PREFETCH_WORD_SIZE> *prefetched_frame, int field_length, int field_offset, bitset<OUTPUT_BUFFER_SIZE> *output_buffer, int *output_buffer_pointer);

void load_extraction(packet *p, bitset<EXTRACT_BUFFER_SIZE>	*ext_buffer, int *ext_buffer_pointer, bitset<PREFETCH_WORD_SIZE> *prefetched_frame, int field_length, int field_offset, bitset<OUTPUT_BUFFER_SIZE> *output_buffer, int *output_buffer_pointer);