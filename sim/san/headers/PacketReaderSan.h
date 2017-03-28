/*
 * PacketReader.h
 *
 *  Created on: May 26, 2015
 *      Author: aditha
 */

#ifndef HEADERS_PACKETREADERSAN_H_
#define HEADERS_PACKETREADERSAN_H_

#include <vector>
#include <fstream>
#include <stdint.h>
#include <pcap.h>

#include "CommonDefs.h"

struct rd_pktSan {
	const struct pcap_pkthdr* header;
	const u_char* pkt_data;
};

class PacketReaderSan {
private:
	pcap_t *fp;

public:
    PacketReaderSan();
    ~PacketReaderSan();
    int open_file(const char* filename);
    int GetNextPacket(rd_pktSan& pkt);
};


#endif /* HEADERS_PACKETREADER_H_ */
