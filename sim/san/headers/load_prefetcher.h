/*
 *  load_prefetcher.h
 *
 *  Created on: March 14, 2017
 *      Author: sandaruwan
 */

#include <iostream>
#include <bitset>
#include <vector>

#include "pcappkts.h"

#define PREFETCH_WORD_SIZE 			512

std::bitset<PREFETCH_WORD_SIZE> load_prefetcher(packet *p);
