#include "headers/load_prefetcher.h"

#define PREFETCH_WORD_SIZE 			512

std::bitset<PREFETCH_WORD_SIZE> load_prefetcher(packet *p){

	std::bitset<PREFETCH_WORD_SIZE> 		prefetched_frame;

	for(int i = 0; i < 8; i++){										//external buffer to internal buffer
		std::bitset<64> 				temp1;
		temp1 										= p->frame_set.front();
		p->frame_set.pop();
		for(int j=0; j<8; j++){												//loop byte
			for (int k = 0; k < 8; k++){									//loop bit in a byte
				prefetched_frame[i*64 + j*8 + k] 	= 	temp1[j*8 + (7-k)];
			}
		}
	}

	return prefetched_frame;
}