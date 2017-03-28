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

void load_field_buffer(std::bitset<OUTPUT_BUFFER_SIZE> *output_buffer, std::queue<uint64_t> *field_buffer);

void load_field_offset(std::bitset<OFFSET_BUFFER_SIZE> *offset_buffer, std::queue<uint64_t> *offset_queue);

void load_field_ext(std::bitset<EXTRACT_BUFFER_SIZE> *ext_buffer, std::queue<uint64_t> *field_extracted);

void load_hdr_seq(std::bitset<HDR_SEQ_BUFFER_SIZE> *hdr_seq_buffer, std::queue<uint64_t> *header_queue);