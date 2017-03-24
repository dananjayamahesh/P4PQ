/*
 * PacketReader.h
 *
 *  Created on: May 26, 2015
 *      Author: aditha
 */

#ifndef HEADERS_PACKETREADER_H_
#define HEADERS_PACKETREADER_H_

#include <vector>
#include <fstream>
#include <stdint.h>
#include <pcap.h>

#include "CommonDefs.h"
#include "TSPrint.h"

struct rd_pkt {
	const struct pcap_pkthdr* header;
	const u_char* pkt_data;
};

class PacketReader {
private:
	pcap_t *fp;

public:
    PacketReader();
    ~PacketReader();
    int open_file(const char* filename);
    int GetNextPacket(rd_pkt& pkt);
};


#endif /* HEADERS_PACKETREADER_H_ */
