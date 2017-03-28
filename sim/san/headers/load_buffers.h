/*
 *  load_flag.h
 *
 *  Created on: March 14, 2017
 *      Author: sandaruwan
 */

#include <iostream>
#include <bitset>
#include <queue>
#include <stdint.h>

#define OUTPUT_BUFFER_SIZE			4096
#define OFFSET_BUFFER_SIZE			4096
#define EXTRACT_BUFFER_SIZE			4096
#define HDR_SEQ_BUFFER_SIZE			1024

using namespace std;

void load_field_buffer(bitset<OUTPUT_BUFFER_SIZE> *output_buffer, queue<uint64_t> *field_buffer);

void load_field_offset(bitset<OFFSET_BUFFER_SIZE> *offset_buffer, queue<uint64_t> *offset_queue);

void load_field_ext(bitset<EXTRACT_BUFFER_SIZE> *ext_buffer, queue<uint64_t> *field_extracted);

void load_hdr_seq(bitset<HDR_SEQ_BUFFER_SIZE> *hdr_seq_buffer, queue<uint64_t> *header_queue);