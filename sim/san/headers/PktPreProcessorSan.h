/*
 * PktPreProcessor.h
 * 
 * Created on: July 15, 2015
 *     author: Aditha
 *
 */

#ifndef HEADERS_PKTPREPROCESSORSAN_H_
#define HEADERS_PKTPREPROCESSORSAN_H_

#include <iostream>
#include <vector>
#include <stdint.h>
#include <cstring>

#include "CommonDefs.h"
#include "pcappkts.h"
#include "PacketReaderSan.h"

#define     IPV4    0x0800ULL
#define     TCP     0x06ULL
#define     UDP     0x11ULL

class PktPreProcessorSan {
	private:

	public:
	    PktPreProcessorSan();
	    ~PktPreProcessorSan();
	    //void AddHeader(packet &pkt, uint32_t pkt_id); 
	    int ConvertPkt(rd_pktSan rp, packet &pkt);
};

#endif /* HEADERS_PKTPREPROCESSOR_H_ */
