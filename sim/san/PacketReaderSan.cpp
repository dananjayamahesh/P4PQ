/*
 * PacketReader.cpp
 *
 *  Created on: May 26, 2015
 *      Author: aditha
 */

#include "headers/PacketReaderSan.h"
#include <pcap.h>

void dispatcher_handlerSan(u_char* pcap_pkt, const struct pcap_pkthdr* header, const u_char* pkt_data) {
	rd_pktSan *rpkt = (rd_pktSan*) pcap_pkt;
	rpkt->header = header;
	rpkt->pkt_data = pkt_data;
}

PacketReaderSan::PacketReaderSan() {
	fp = NULL;
}


PacketReaderSan::~PacketReaderSan() {
}

// Read the next packet of the pcap file
int PacketReaderSan::GetNextPacket(rd_pktSan& pkt) {
    /* u_char* rd_pkt = (u_char*) &pkt; */

    /* pcap_loop(fp, 1, dispatcher_handler, rd_pkt); */

    /* return SUCCESS; */
    struct pcap_pkthdr *header;
    const u_char *data;
    int ret = pcap_next_ex(fp, &header, &data);
    pkt.header = header;
    pkt.pkt_data = data;
    return ret;

}

// Open the pcap file
int PacketReaderSan::open_file(const char* filename) {
    char errbuf[PCAP_ERRBUF_SIZE];

    fp = pcap_open_offline(filename, errbuf);
    if(fp == NULL)
    {
        return FAILURE;
    }
    else
    {
        return SUCCESS;
    }
}

void PacketReaderSan::close_file(){
     pcap_close(fp);
}

