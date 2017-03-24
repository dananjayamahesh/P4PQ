/*
 * CommonFuncs.h
 *
 *  Created on: May 26, 2015
 *      Author: aditha
 */

#ifndef HEADERS_COMMONFUNCS_H_
#define HEADERS_COMMONFUNCS_H_

#include <stdint.h>
#include "NetworkPkts.h"

// Byte swap unsigned short
uint16_t swap_uint16( uint16_t val );

// Byte swap short
int16_t swap_int16( int16_t val );

// Byte swap unsigned int
uint32_t swap_uint32( uint32_t val );

// Byte swap int
int32_t swap_int32( int32_t val );

// Byte swap unsigned long int
uint64_t byteswap_uint64( uint64_t val );

// 64bits swap
uint64_t swap_uint64 (uint64_t val);

// Convert Packet to a char array
void ReconstructPacket(packet pkt, unsigned char* z_pkt);

char SwapNibble(char val);

#endif /* HEADERS_COMMONFUNCS_H_ */
