/*
 * CommonTypes.h
 *
 *  Created on: May 26, 2015
 *      Author: aditha
 */

#ifndef HEADERS_COMMONTYPES_H_
#define HEADERS_COMMONTYPES_H_

#include <stdint.h>

typedef unsigned int uint;
typedef uint8_t ip_addr[4];
typedef uint16_t port;
typedef uint8_t protocol;
typedef uint8_t mask;

typedef uint16_t state_t;
typedef uint64_t output_t;

//struct DNSResponse {
	//ip_addr dns_ip;
	//DNSResponse* next_response;
//};

struct match_unit {
	state_t state;
	char value;
	state_t next_state;
};

#endif /* HEADERS_COMMONTYPES_H_ */
