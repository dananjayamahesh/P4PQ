/*
 * PktPreProcessor.h
 * 
 * Created on: July 15, 2015
 *     author: Aditha
 *
 */

#ifndef HEADERS_PKTPREPROCESSOR_H_
#define HEADERS_PKTPREPROCESSOR_H_

#include <iostream>
#include <vector>
#include <stdint.h>
#include <cstring>

#include "CommonDefs.h"
#include "CommonTypes.h"
#include "CommonFuncs.h"
#include "NetworkPkts.h"
#include "PacketReader.h"

#define     IPV4    0x0800ULL
#define     TCP     0x06ULL
#define     UDP     0x11ULL

class PktPreProcessor {
private:

public:
    PktPreProcessor();
    ~PktPreProcessor();
    //void AddHeader(packet &pkt, uint32_t pkt_id); 
    int ConvertPkt(rd_pkt rp, packet &pkt);
};

#endif /* HEADERS_PKTPREPROCESSOR_H_ */
