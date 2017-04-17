
#include "header/PktPreProcessor.h"

PktPreProcessor::PktPreProcessor() 
{
}

PktPreProcessor::~PktPreProcessor()
{
}

int PktPreProcessor::ConvertPkt(rd_pkt rp, packet &pkt)
{
    const struct pcap_pkthdr *header = rp.header;
    const u_char *pkt_data = rp.pkt_data;
    char z_buf[200];
    frame fr;

    if (header->len != header->caplen) {
    	snprintf(z_buf, sizeof(z_buf), "Error:[RepToolHw::PushNetPkt]:packet len = %d and captured len = %d mismatch", (int)header->len, (int)header->caplen);
    	PrintLog(z_buf);
       std::cout << "CONV LEN" << ((int)header->len) <<  "CAPLEN" << ((int)header->caplen) << std::endl; 
        return FAILURE;
    }

    uint len = (header->caplen / 8);

    if ((header->caplen % 8) != 0) { 
        len = len + 1;
    }
    for (uint i = 0; i < len; i++) {
        /*
        fr.sframe.b1 = (8 * i > (uint) header->caplen)     ? 0  : pkt_data[i * 8];
        fr.sframe.b2 = (8 * i + 1 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 1];
        fr.sframe.b3 = (8 * i + 2 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 2];
        fr.sframe.b4 = (8 * i + 3 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 3];
        fr.sframe.b5 = (8 * i + 4 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 4];
        fr.sframe.b6 = (8 * i + 5 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 5];
        fr.sframe.b7 = (8 * i + 6 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 6];
        fr.sframe.b8 = (8 * i + 7 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 7];
        */

        fr.sframe.b8 = (8 * i > (uint) header->caplen) ? 0  : pkt_data[i * 8];
        fr.sframe.b7 = (8 * i + 1 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 1];
        fr.sframe.b6 = (8 * i + 2 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 2];
        fr.sframe.b5 = (8 * i + 3 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 3];
        fr.sframe.b4 = (8 * i + 4 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 4];
        fr.sframe.b3 = (8 * i + 5 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 5];
        fr.sframe.b2 = (8 * i + 6 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 6];
        fr.sframe.b1 = (8 * i + 7 > (uint) header->caplen) ? 0  : pkt_data[i * 8 + 7];
        
        pkt.frame_set.push_back(fr.all);
    }

    return SUCCESS;
}

/*void PktPreProcessor::AddHeader(packet &pkt, uint32_t pkt_id)
{
    int iPacketLen;
    uint64_t header = 0;
    uint64_t length = 0;

	// Convert the packet structure to a char stream
	iPacketLen = (pkt.frame_set.size() * 8);
	char z_packet[iPacketLen + 1];
	ReconstructPacket(pkt, z_packet);

	// Unpacking the Ethernet header
	eth_header e_hdr;
	memcpy(&e_hdr, z_packet, 15);

	if(swap_uint16(e_hdr.type1) == IPV4_TYPE) {
		// Unpack the ipv4 header
		ipv4_header ipv4_hdr;
		memcpy(&ipv4_hdr, (z_packet + 14), 21);

		if(ipv4_hdr.protocol == TCP_TYPE) {
			// Unpack the tcp header
			header = 2;
            header = header | (0xffffffff00ULL & (pkt_id << 8));
            header = header | (0xffff0000000000ULL & (IPV4 << 40));
            header = header | (0xff00000000000000ULL & (TCP << 56));
		}
		else if(ipv4_hdr.protocol == UDP_TYPE) {
			// Unpack the udp header
			header = 2;
            header = header | (0xffffffff00ULL & (pkt_id << 8)); 
            header = header | (0xffff0000000000ULL & (IPV4 << 40));
            header = header | (0xff00000000000000ULL & (UDP << 56));
		}
		else {
			// Not TCP or UDP
			header = 0xf;
            header = header | (0xffffffff00ULL & (pkt_id << 8)); 
		}
	}
	else {
		// Not IPv4
		header = 0xf;
        header = header | (0xffffffff00ULL & (pkt_id << 8)); 
	}

    std::vector<uint64_t>::iterator it;
    it = pkt.frame_set.begin();
    it = pkt.frame_set.insert(it, header);

    length = (uint64_t) pkt.frame_set.size();
    it = pkt.frame_set.begin();
    it = pkt.frame_set.insert(it, length);
}*/
