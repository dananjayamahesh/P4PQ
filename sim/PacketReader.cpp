
#include "header/PacketReader.h"
#include <pcap.h>
#include <queue>

#include <stdlib.h> 
#include <stdio.h>
#include <iostream>
#include <fstream>

void dispatcher_handler(u_char* pcap_pkt, const struct pcap_pkthdr* header, const u_char* pkt_data) {
	rd_pkt *rpkt = (rd_pkt*) pcap_pkt;
	rpkt->header = header;
	rpkt->pkt_data = pkt_data;
}

PacketReader::PacketReader() {
	fp = NULL;
}


PacketReader::~PacketReader() {
}

// Read the next packet of the pcap file
int PacketReader::GetNextPacket(rd_pkt& pkt) {
    u_char* rd_pkt = (u_char*) &pkt;

    pcap_loop(fp, 1, dispatcher_handler, rd_pkt);

    return SUCCESS;
}

// Open the pcap file
int PacketReader::open_file(const char* filename) {
    char errbuf[PCAP_ERRBUF_SIZE];

  std::cout << filename << std::endl; 
    fp = pcap_open_offline(filename, errbuf);
    if(fp == NULL)
    {
         std::cout << "ReadFail" << std::endl; 
        return FAILURE;
    }
    else
    {
        std::cout << "ReadSuccess" << std::endl; 
        return SUCCESS;
    }
}

