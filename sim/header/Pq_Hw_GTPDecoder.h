/*
 * Pq_Hw_GTPDecoder.h
 *
 * created:- 2016/04/25
 * author:- Indunil Wanigasooriya
*/ 

#ifndef HEADER_PQ_HW_GTPDECODER_H_
#define HEADER_PQ_HW_GTPDECODER_H_

#include <stdint.h>
#include <cstring>
#include <iostream>
#include "ChannelDefs.h"
#include "CommonDefs.h"
#include "CommonFuncs.h"
#include "CommonTypes.h"
#include "NetworkPkts.h"
#include "TSPrint.h"

#include "Pq_Hw_GtpStruct.h"   //include the structures
//#include "Pq_Hw_GtpStructV1.h"
//#include "Pq_Hw_GtpStructV2.h"

//#define TEMP_PRTINT
//#define GTPV1C
//#define GTPV1U
#define GTPV2C

static int cnt =1;

class Pq_Hw_GTPDecoder {
public:
    int gtp_data_str_offset;
    int length;
    int len_cnt;

    eth_header e_hdr;
    ipv4_header ipv4_hdr;
    udp_header udp_hdr;
    tcp_header tcp_hdr;

    Pq_Hw_GTPDecoder();
    ~Pq_Hw_GTPDecoder();

    void proce_frame (packet pkt, gtp_decoder_data &gtpdecoder);
    void set_init (gtp_decoder_data &gtpdecoder);
    void gtpv1_init (gtp_decoder_data &gtpdecoder);
    void gtpv2_init (gtp_decoder_data &gtpdecoder);
    void network_layer_proce (unsigned char *z_packet, gtp_decoder_data &gtpdecoder, int &byte_offset); 
    void trasport_layer_proce (unsigned char *z_packet, gtp_decoder_data &gtpdecoder, int &byte_offset);
    void trasport_layer_proce_tcp (unsigned char *z_packet, gtp_decoder_data &gtpdecoder, int &byte_offset); 
    void gtpv1c_proce (unsigned char *gtp_pld, gtp_decoder_data &gtpdecoder, int &byte_offset); 
    void gtpv2c_proce (unsigned char *gtp_pld, gtp_decoder_data &gtpdecoder, int &byte_offset); 
    void print_output (gtp_decoder_data &gtpdecoder);
    void print_gtpv1_c_output (gtp_decoder_data &gtpdecoder);
    void print_gtpv2_c_output (gtp_decoder_data &gtpdecoder);
    void print_gtpv1_u_output (gtp_decoder_data &gtpdecoder);
    void AddHdr(packet &pkt);
};

#endif
