#include "PacketReaderSan.h"
#include "pcappkts.h"
#include "PktPreProcessorSan.h"
#include "load_prefetcher.h"
#include "load_flag.h"
#include "extract_prefetcher.h"
#include "load_output_buffer.h"
#include "load_buffers.h"

#include <iostream>
#include <vector>
#include <string>
#include <queue>
#include <pcap.h>
#include <bitset>
#include <fstream>
#include <typeinfo>
#include <stdlib.h> 

#define NO_PACKETS					6
#define PREFETCH_WORD_SIZE 			512
#define OUTPUT_BUFFER_SIZE			4096
#define OFFSET_BUFFER_SIZE			4096
#define EXTRACT_BUFFER_SIZE			4096
#define HDR_SEQ_BUFFER_SIZE			1024
#define FIELD_OFFSET_WIDTH			10
#define MAX_HEADERS					10
#define MAX_FIELDS_PER_HEADER		32
#define HEADER_LENGTH_BIT_WORD		32

#define FIELD_ID_WIDTH				5
#define HEADER_ENTRY_WIDTH			8
#define HEADER_LENGTH_ENTRY_WIDTH	16
#define FIELD_LENGTH_ENTRY_WIDTH	9
#define NEXT_HEADERTYPE_ENTRY_WIDTH	24

class Parser {

	public:
	    void run();

		uint64_t get_field_buffer_word();

		uint64_t get_offset_queue_word();

		uint64_t get_ext_queue_word();

		uint64_t get_hdr_Seq_queue_word();

};