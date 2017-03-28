/*
 * PktPreProcessor.cpp
 * 
 * Created on: July 15, 2015
 *     author: Aditha
 *
 */

#include "headers/PktPreProcessorSan.h"

PktPreProcessorSan::PktPreProcessorSan() 
{
}

PktPreProcessorSan::~PktPreProcessorSan()
{
}

int PktPreProcessorSan::ConvertPkt(rd_pktSan rp, packet &pkt)
{
    const struct pcap_pkthdr *header = rp.header;
    const u_char *pkt_data = rp.pkt_data;
    char z_buf[200];
    frame fr;

    if (header->len != header->caplen) {
    	snprintf(z_buf, sizeof(z_buf), "Error:[RepToolHw::PushNetPkt]:packet len = %d and captured len = %d mismatch", (int)header->len, (int)header->caplen);
    	//PrintLog(z_buf);
        return FAILURE;
    }

    uint len = (header->caplen / 8);

    if ((header->caplen % 8) != 0) { 
        len = len + 1;
    }
    for (uint i = 0; i < len; i++) {
        fr.sframe.b1 = (8 * i > (uint) header->caplen)     ? 0  : pkt_data[i * 8];
        fr.sframe.b2 = (8 * i + 1 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 1];
        fr.sframe.b3 = (8 * i + 2 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 2];
        fr.sframe.b4 = (8 * i + 3 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 3];
        fr.sframe.b5 = (8 * i + 4 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 4];
        fr.sframe.b6 = (8 * i + 5 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 5];
        fr.sframe.b7 = (8 * i + 6 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 6];
        fr.sframe.b8 = (8 * i + 7 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 7];
        
        pkt.frame_set.push(fr.all);
    }

    return SUCCESS;
}
