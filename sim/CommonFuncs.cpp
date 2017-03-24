/*
 * CommonFuncs.cpp
 *
 *  Created on: May 27, 2015
 *      Author: aditha
 */

#include "header/CommonFuncs.h"

//! Byte swap unsigned short
uint16_t swap_uint16( uint16_t val ) {
    return (val << 8) | (val >> 8 );
}

//! Byte swap short
int16_t swap_int16( int16_t val ) {
    return (val << 8) | ((val >> 8) & 0xFF);
}

//! Byte swap unsigned int
uint32_t swap_uint32( uint32_t val ) {
    val = ((val << 8) & 0xFF00FF00 ) | ((val >> 8) & 0xFF00FF );
    return (val << 16) | (val >> 16);
}

//! Byte swap int
int32_t swap_int32( int32_t val ) {
    val = ((val << 8) & 0xFF00FF00) | ((val >> 8) & 0xFF00FF );
    return (val << 16) | ((val >> 16) & 0xFFFF);
}

//! Byte swap unsigned long int
uint64_t byteswap_uint64( uint64_t val ) {
    //val = ((val << 8) & 0xFF00FF00FF00FF00ULL) | ((val >> 8) & 0x00FF00FF00FF00FFULL);
    //val = ((val << 16) & 0xFFFF0000FFFF0000ULL) | ((val >>16) & 0x0000FFFF0000FFFFULL);
    //return (val << 32) | (val >> 32);
    val = ((val << 4) & 0xF0F0F0F0F0F0F0F0ULL) | ((val >> 4) & 0x0F0F0F0F0F0F0F0FULL); 
    return val;
}

uint64_t swap_uint64 (uint64_t val) {
    val = ((val << 8) & 0xFF00FF00FF00FF00) | ((val >> 8) & 0xFF00FF00FF00FF);
    val = ((val << 16) & 0xFFFF0000FFFF0000) | ((val >> 16) & 0xFFFF0000FFFF);
    val = ((val << 32) & 0xFFFFFFFF00000000) | ((val >> 32) & 0xFFFFFFFF);
    return val;
}

void ReconstructPacket(packet pkt, unsigned char* z_pkt)
{
    int iLen = pkt.frame_set.size();

    for(int i = 0; i < iLen; ++i) {
        frame frm;
        frm.all = pkt.frame_set[i];

        z_pkt[(i * 8) + 0] = (char) frm.sframe.b1;
        z_pkt[(i * 8) + 1] = (char) frm.sframe.b2;
        z_pkt[(i * 8) + 2] = (char) frm.sframe.b3;
        z_pkt[(i * 8) + 3] = (char) frm.sframe.b4;
        z_pkt[(i * 8) + 4] = (char) frm.sframe.b5;
        z_pkt[(i * 8) + 5] = (char) frm.sframe.b6;
        z_pkt[(i * 8) + 6] = (char) frm.sframe.b7;
        z_pkt[(i * 8) + 7] = (char) frm.sframe.b8;
    }
}

char SwapNibble(char val)
{
    return (((val >> 4) & 0x0F) | ((val << 4) & 0xF0));
}
