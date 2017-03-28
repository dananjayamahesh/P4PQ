#include <iostream>
#include <stdint.h>

using namespace std;

class Parser1 {

	public:
	    void run();

		uint64_t get_field_buffer_word();

		uint64_t get_offset_queue_word();

		uint64_t get_ext_queue_word();

		uint64_t get_hdr_Seq_queue_word();

};