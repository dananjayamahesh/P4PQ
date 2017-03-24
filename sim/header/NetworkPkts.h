/*
 * NetworkPkts.h
 *
 *  Created on: May 26, 2015
 *      Author: aditha
 */

#ifndef HEADERS_NETWORKPKTS_H_
#define HEADERS_NETWORKPKTS_H_

#include <stdint.h>
#include <vector>

#include "CommonDefs.h"

#define IPV4_TYPE 	0x0800ULL
#define VLAN_TYPE   0x8100ULL   //new 2016/1/12
#define TCP_TYPE 	0x6ULL
#define UDP_TYPE    0x11ULL

struct splitted_frame {
    uint64_t b1:8;
    uint64_t b2:8;
    uint64_t b3:8;
    uint64_t b4:8;
    uint64_t b5:8;
    uint64_t b6:8;
    uint64_t b7:8;
    uint64_t b8:8;
};

union frame {
    splitted_frame sframe;
    uint64_t all;
};

struct packet {
    std::vector<uint64_t> frame_set;
};

// ethernet header
struct eth_header {
    uint8_t     mac_dest_addr[6];
    uint8_t     mac_src_addr[6];
    uint16_t    type1;
    uint16_t    vidm : 4, CFI : 1, PRI : 3, vidl : 8;
    uint16_t    type2;
    uint8_t     data;
#ifdef LINUX
}__attribute__((__packed__));
#else
};
#endif

// IPv4 header
struct ipv4_header {
	uint8_t     header_len : 4, version : 4;        //i change the order
    uint8_t     tos;
    uint16_t    total_len;
    uint16_t    id;
    uint16_t    ip_flags : 3, frag_offset : 13;
    uint8_t     ttl;
    uint8_t     protocol;
    uint16_t    header_checksum;
    uint8_t     src_ip_addr[4];
    uint8_t     dest_ip_addr[4];
    uint8_t     data;
#ifdef LINUX
}__attribute__((__packed__));
#else
};
#endif

// IPv6 header
// TODO

// tcp header
struct tcp_header {
    uint16_t    src_port;
    uint16_t    dest_port;
    uint32_t    seq_number;
    uint32_t    ack_number;
    uint8_t     reserved : 4, header_len : 4;  //i change the order
    uint8_t     tcp_flags;
    uint16_t    window_size;
    uint16_t    tcp_checksum;
    uint16_t    urgrnt_pointer;
    uint8_t     data;
#ifdef LINUX
}__attribute__((__packed__));
#else
};
#endif

// udp header
struct udp_header {
    uint16_t    src_port;
    uint16_t    dest_port;
    uint16_t    udp_len;
    uint16_t    udp_checksum;
    uint8_t     data;
#ifdef LINUX
}__attribute__((__packed__));
#else
};
#endif

#endif /* HEADERS_NETWORKPKTS_H_ */
