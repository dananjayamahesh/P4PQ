/*
 * NetworkPkts.h
 *
 *  Created on: May 26, 2015
 *      Author: aditha
 */

#ifndef HEADERS_NETWORKPKTS_H_
#define HEADERS_NETWORKPKTS_H_

#include <stdint.h>
#include <queue>

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
    std::queue<uint64_t> frame_set;
};

#endif /* HEADERS_NETWORKPKTS_H_ */
