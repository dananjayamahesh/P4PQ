/*
 * Pq_Hw_GTPDecoder.cpp
 *
 * created:- 2015/11/03
 * author:- Indunil Wanigasooriya
*/ 

#include "header/Pq_Hw_GTPDecoder.h"

Pq_Hw_GTPDecoder::Pq_Hw_GTPDecoder() {

}

Pq_Hw_GTPDecoder::~Pq_Hw_GTPDecoder() {

}

void Pq_Hw_GTPDecoder::proce_frame (packet pkt, gtp_decoder_data &gtp_data) {  //process data link layer
    int iPacketLen;
    int byte_offset =0;   
    //char z_buf[200];

    // Convert the packet structure to a char stream
    iPacketLen = (pkt.frame_set.size() * 8);
    unsigned char z_packet[iPacketLen + 1];
    ReconstructPacket(pkt, z_packet);

    // Unpacking the Ethernet header
    memcpy(&e_hdr, z_packet, 19);                   //19 if vlan is there, 14 if no vlan

    set_init(gtp_data);                             //initialize the values

    /////////////////////////////////
    std::cout << "cnt:- " << cnt << std::endl;
    std::cout << "ipv4_type:- " << (int)e_hdr.type1 << std::endl;
    ////////////////////////////////

    if(swap_uint16(e_hdr.type1) == IPV4_TYPE) {      
        //unpack the ipv4 header
        memcpy(&ipv4_hdr, (z_packet + 14), 21);                     //has consider the length as well
        network_layer_proce(z_packet, gtp_data, byte_offset);        
    }
    else if (swap_uint16(e_hdr.type1) == VLAN_TYPE) {       //if vlan en
        std::cout << "vlan id :- " << 256*(int)e_hdr.vidm + (int)e_hdr.vidl << std::endl;

        if(swap_uint16(e_hdr.type2) == IPV4_TYPE) {
            std::cout << "ipv4_type2 :- " << (int)e_hdr.type2 << std::endl;
            //unpack the ipv4 header
            memcpy(&ipv4_hdr, (z_packet + 18), 21);    
            network_layer_proce(z_packet, gtp_data, byte_offset);    
        }  
    }

    //print the output
    if (gtp_data.gtp_en) {
        print_output(gtp_data);
    }
    //gtp_data.gtpv1.ie_gsn_cnt = 0;
    //gtp_data.gtpv1.ie_uli_cnt = 0;

    cnt++;
    std::cout << std::endl;
}

void Pq_Hw_GTPDecoder::set_init (gtp_decoder_data &gtp_data) {   //initialize the values
    gtp_data.gtp_en = false;
    gtp_data.ctrl_or_data = 0;

    gtpv1_init(gtp_data);
    gtpv2_init(gtp_data);
}

void Pq_Hw_GTPDecoder::gtpv1_init (gtp_decoder_data &gtp_data) {
    gtp_data.gtpv1.ie_gsn_cnt = 0;
    gtp_data.gtpv1.ie_uli_cnt = 0;
    gtp_data.gtpv1.length = 0;

    //flags for tx data check to packetizer
    gtp_data.gtpv1.fseq = 0;
    gtp_data.gtpv1.fcause = 0;
    gtp_data.gtpv1.fteidc = 0;
    gtp_data.gtpv1.fteidu = 0;
    gtp_data.gtpv1.fue = 0;
    gtp_data.gtpv1.fimei = 0;
    gtp_data.gtpv1.fimsi = 0;
    gtp_data.gtpv1.fmsisdn = 0;
    gtp_data.gtpv1.frat = 0;
    gtp_data.gtpv1.fuli = 0;
    gtp_data.gtpv1.fqos = 0;
    gtp_data.gtpv1.fmstime = 0;
    gtp_data.gtpv1.fgsnip = 0;
    gtp_data.gtpv1.fapn = 0;

    gtp_data.gtpv1.ie_cause_en = false;
    gtp_data.gtpv1.ie_imsi_en = false;
    gtp_data.gtpv1.ie_teid_d_en = false;
    gtp_data.gtpv1.ie_teid_c_en = false;
    gtp_data.gtpv1.ie_teardown_ind_en = false;    //no
    gtp_data.gtpv1.ie_nsapi_en = false;           //no
    gtp_data.gtpv1.ie_linked_nsapi_en = false;    //no
    gtp_data.gtpv1.ie_enduseraddr_en = false;
    gtp_data.gtpv1.ie_apn_en = false;
    
    gtp_data.gtpv1.ie_gsn_en = false;
    //gtp_data.ie_gsn_c_en = false;
    //gtp_data.ie_gsn_d_en = false;
    //gtp_data.ie_alternative_gsn_c_en = false;
    //gtp_data.ie_alternative_gsn_d_en = false;
    gtp_data.gtpv1.ie_msisdn_en = false;
    gtp_data.gtpv1.ie_qos_en = false;
    gtp_data.gtpv1.ie_rat_en = false;
    gtp_data.gtpv1.ie_uli_en = false;
    gtp_data.gtpv1.ie_ms_time_zone_en = false;
    gtp_data.gtpv1.ie_imei_en = false;
    gtp_data.gtpv1.ie_dtf_en = false;             //no
}

void Pq_Hw_GTPDecoder::gtpv2_init (gtp_decoder_data &gtp_data) {
    //initialize the bearer context values as well
    gtp_data.gtpv2.ie_ipaddr_cnt = 0;
    gtp_data.gtpv2.ie_fteid_cnt = 0;
    gtp_data.gtpv2.ie_be_context_cnt = 0;   
    gtp_data.gtpv2.ie_port_no_cnt = 0;
    gtp_data.gtpv2.ie_overload_ctrl_info_cnt = 0;
    gtp_data.gtpv2.ie_load_ctrl_info_cnt = 0;
    gtp_data.gtpv2.length = 0;

    gtp_data.gtpv2.ie_ipaddr_index = 0;
    gtp_data.gtpv2.ie_fteid_c_index = 0;
    gtp_data.gtpv2.ie_fteid_u_index = 0;    
    gtp_data.gtpv2.ie_be_context_cause_index = 0;
    gtp_data.gtpv2.ie_be_context_ebi_index = 0;
    gtp_data.gtpv2.ie_be_context_bqos_index = 0;
    gtp_data.gtpv2.ie_be_context_teidc_index = 0;
    gtp_data.gtpv2.ie_be_context_teidu_index = 0;

    //flags for tx data check to packetizer
    gtp_data.gtpv2.fseq = 1;
    gtp_data.gtpv2.fcause = 0;
    gtp_data.gtpv2.fteidc = 0;
    gtp_data.gtpv2.fteidu = 0;
    gtp_data.gtpv2.fipaddr = 0;
    gtp_data.gtpv2.fimei = 0;
    gtp_data.gtpv2.fimsi = 0;
    gtp_data.gtpv2.fmsisdn = 0;
    gtp_data.gtpv2.frat = 0;
    gtp_data.gtpv2.fuli = 0;
    gtp_data.gtpv2.fbqos = 0;
    gtp_data.gtpv2.febi = 0;
    gtp_data.gtpv2.fambr = 0;
    gtp_data.gtpv2.fmstime = 0;
    gtp_data.gtpv2.fteidipcv4 = 0;
    gtp_data.gtpv2.fteidipcv6 = 0;
    gtp_data.gtpv2.fteidipuv4 = 0;
    gtp_data.gtpv2.fteidipuv6 = 0;
    gtp_data.gtpv2.fapn = 0;

    gtp_data.gtpv2.ie_imsi_en = false;
    gtp_data.gtpv2.ie_cause_en = false;
    gtp_data.gtpv2.ie_apn_en = false;
    gtp_data.gtpv2.ie_ambr_en = false;
    gtp_data.gtpv2.ie_ebi_en = false;    
    gtp_data.gtpv2.ie_ipaddr_en = false;           
    gtp_data.gtpv2.ie_imei_en = false;    
    gtp_data.gtpv2.ie_msisdn_en = false;
    gtp_data.gtpv2.ie_beqos_en = false;
    gtp_data.gtpv2.ie_flqos_en = false;
    gtp_data.gtpv2.ie_rat_en = false;
    gtp_data.gtpv2.ie_uli_en = false;
    gtp_data.gtpv2.ie_fteid_c_en = false;
    gtp_data.gtpv2.ie_fteid_u_en = false;
    gtp_data.gtpv2.ie_be_context_en = false;    
    gtp_data.gtpv2.ie_ue_time_zone_en = false;           
    gtp_data.gtpv2.ie_port_no_en = false;    
    gtp_data.gtpv2.ie_uli_timestamp_en = false;
    gtp_data.gtpv2.ie_overload_ctrl_info_en = false;
    gtp_data.gtpv2.ie_load_ctrl_info_en = false;
    gtp_data.gtpv2.ie_apn_reltcap_en = false;

    //bearer context grouped IE
    for (int a = 0; a < 2; a++) {
        gtp_data.gtpv2.ie_be_context[a].ie_fteid_cnt = 0;
        gtp_data.gtpv2.ie_be_context[a].ie_cause_en = false;
        gtp_data.gtpv2.ie_be_context[a].ie_ebi_en = false;
        gtp_data.gtpv2.ie_be_context[a].ie_beqos_en = false;
        gtp_data.gtpv2.ie_be_context[a].ie_fteid_c_en = false;
        gtp_data.gtpv2.ie_be_context[a].ie_fteid_u_en = false;
    }
    //overload and load ctrl grouped IE
    for (int a = 0; a < 5; a++) {
        gtp_data.gtpv2.ie_overload_ctrl_info[a].ie_apn_en = false;
        gtp_data.gtpv2.ie_load_ctrl_info[a].ie_apn_reltcap_en = false;
    }
}

void Pq_Hw_GTPDecoder::network_layer_proce (unsigned char *z_packet, gtp_decoder_data &gtp_data, int &byte_offset) {   //process netowrk layer

    //////////////////////////////////////////
    std::cout << "ipv4_option_len :- " << (int)ipv4_hdr.header_len-5 << std::endl;
    std::cout << "transport_protocol:- " << (int)ipv4_hdr.protocol << std::endl;
    //////////////////////////////////////////

    if (ipv4_hdr.protocol == UDP_TYPE) {    //gtpv1 is only UDP
        memcpy(&udp_hdr, (z_packet + 34 + 4*((int)ipv4_hdr.header_len - 5)), 9);  //has fixed header size of 

        //////////////////////////////////////////
        std::cout << "src_port:- " << swap_uint16(udp_hdr.src_port) << std::endl;
        std::cout << "dest_port:- " << swap_uint16(udp_hdr.dest_port) << std::endl;
        if ((swap_uint16(udp_hdr.src_port)) == (swap_uint16(udp_hdr.dest_port))) {
            std::cout << "src_port and dest_port are matched" << std::endl;
        }
        else {
            std::cout << "src_port and dest_port are NOT matched" << std::endl;
        }
        ///////////////////////////////////////////

        trasport_layer_proce(z_packet, gtp_data, byte_offset);
    }
    else if (ipv4_hdr.protocol == TCP_TYPE) {  //not for gtpv1, only gtpv2
        memcpy(&udp_hdr, (z_packet + 34 + 4*((int)ipv4_hdr.header_len - 5)), 21);  //has fixed header size of 

        ///////////////////////////////////////////////////////
        std::cout << "tcp protocol is detected" << std::endl;

        std::cout << "src_port:- " << swap_uint16(tcp_hdr.src_port) << std::endl;
        std::cout << "dest_port:- " << swap_uint16(tcp_hdr.dest_port) << std::endl;
        if ((swap_uint16(tcp_hdr.src_port)) == (swap_uint16(tcp_hdr.dest_port))) {
            std::cout << "src_port and dest_port are matched" << std::endl;
        }
        else {
            std::cout << "src_port and dest_port are NOT matched" << std::endl;
        }
        ///////////////////////////////////////////////////////

        trasport_layer_proce_tcp(z_packet, gtp_data, byte_offset);
    }
}

void Pq_Hw_GTPDecoder::trasport_layer_proce (unsigned char *z_packet, gtp_decoder_data &gtp_data, int &byte_offset) {   //process trasport layer  
    
    if ((swap_uint16(udp_hdr.src_port) == 2123) | (swap_uint16(udp_hdr.dest_port) == 2123) | (swap_uint16(udp_hdr.src_port) == 2152) | (swap_uint16(udp_hdr.dest_port) == 2152)) {   //control & data packet only
        gtp_data_str_offset = (34 + 4*((int)ipv4_hdr.header_len-5) + 9 -1);                     //point to gtp hdr flags
        unsigned char *gtp_pld = (z_packet + gtp_data_str_offset);

        memcpy(&gtp_data.gtp_hdr, gtp_pld, 8+3);              //copy the gtp hdr mandatory field + sequence number (for gtpv2 there should be 24 bit field for seqeunce number)

        if (gtp_data.gtp_hdr.version == 1) {            //gtpv1
            if (gtp_data.gtp_hdr.pro_piggy) {                    //protocol = 1 -> GTP
                byte_offset = 8;                            //point to the seq number if it is there or point to a msg if no optional field 
                if (gtp_data.gtp_hdr.PN | gtp_data.gtp_hdr.S | gtp_data.gtp_hdr.E) {
                    byte_offset = byte_offset + 3;                                  //point to the extension hdr 
                    std::cout << "optional hdrs are detected" << std::endl;
                    if (gtp_data.gtp_hdr.E) {                                       //has extension hdr  //???????????????????????????????????????
                        //byte_offset = byte_offset + *(gtp_pld+byte_offset);         //point to a msg
                        std::cout << "extension hdr is detected" << std::endl;
                    }
                    else {
                        byte_offset = byte_offset + 1;      //skip extension hdr length
                    }

                    if (gtp_data.gtp_hdr.S) {
                        gtp_data.gtpv1.fseq = 1;
                        gtp_data.gtpv1.length++;
                    }
                }

                if (!gtp_data.gtp_hdr.E) {        
                    if ((swap_uint16(udp_hdr.src_port) == 2123) | (swap_uint16(udp_hdr.dest_port) == 2123)) {  //control plane
                        #ifdef GTPV1C
                            //process only create/update/delete PDP req/res
                            if ((gtp_data.gtp_hdr.msg_typ == 16) | (gtp_data.gtp_hdr.msg_typ == 17) | (gtp_data.gtp_hdr.msg_typ == 18) | (gtp_data.gtp_hdr.msg_typ == 19) | (gtp_data.gtp_hdr.msg_typ == 20) | (gtp_data.gtp_hdr.msg_typ == 21)) {
                                gtp_data.gtp_en = true;
                                gtp_data.ctrl_or_data = 1;                          //1 -> control
                                gtpv1c_proce(gtp_pld, gtp_data, byte_offset);
                            }
                            else {
                                std::cout << "different msg type is detected" << std::endl;
                            } 
                        #endif
                    }
                    else if ((swap_uint16(udp_hdr.src_port) == 2152) | (swap_uint16(udp_hdr.dest_port) == 2152)) {   //data plane
                        #ifdef GTPV1U
                            if (gtp_data.gtp_hdr.msg_typ == 255) {   //process only G-PDU
                                gtp_data.gtp_en = true;
                                gtp_data.ctrl_or_data = 2;                          //2 -> data
                            }
                            else {
                                std::cout << "different msg type is detected" << std::endl;
                            }
                            //gtp_data.gtpv1.byte_offset =  gtp_data_str_offset + byte_offset;    //skip upto G-PDU field
                            gtp_data.gtpv1u.byte_offset =  byte_offset;    //skip upto G-PDU field
                            memcpy(&gtp_data.gtpv1u, (gtp_pld + byte_offset), 8*4);
                
                            #ifdef TEMP_PRTINT
                                std::cout << "TEMP DATA GTPV1_U:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                            #endif
                        #endif
                    } 
                } 
            }   
            else {
                std::cout << "gtp prime" << std::endl;
                //don't process
            }
        }
        else if (gtp_data.gtp_hdr.version == 2) {       //gtpv2
            std::cout << "gtp version 2" << std::endl;
            byte_offset = 4;                            //point to the TEID if it is there or point to a seq number if no TEID 
            if (gtp_data.gtp_hdr.teid_en) {                    //if teid is there
                byte_offset = byte_offset + 8;      //poin to the msg type
            }

            if (gtp_data.gtp_hdr.pro_piggy) {
                std::cout << "piggyback is detected" << std::endl;   //????????????????????????????????????????
            }
            else {
                #ifdef GTPV2C
                if ((swap_uint16(udp_hdr.src_port) == 2123) | (swap_uint16(udp_hdr.dest_port) == 2123)) {  //control plane
                    if ((gtp_data.gtp_hdr.msg_typ == 32) | (gtp_data.gtp_hdr.msg_typ == 33) | (gtp_data.gtp_hdr.msg_typ == 34) | (gtp_data.gtp_hdr.msg_typ == 35) | (gtp_data.gtp_hdr.msg_typ == 36) | (gtp_data.gtp_hdr.msg_typ == 37) | (gtp_data.gtp_hdr.msg_typ == 95) | (gtp_data.gtp_hdr.msg_typ == 96) | (gtp_data.gtp_hdr.msg_typ == 97) | (gtp_data.gtp_hdr.msg_typ == 98) | (gtp_data.gtp_hdr.msg_typ == 99) | (gtp_data.gtp_hdr.msg_typ == 100)) {
                        gtp_data.gtp_en = true;
                        gtp_data.ctrl_or_data = 1;                          //1 -> control
                        gtpv2c_proce(gtp_pld, gtp_data, byte_offset);
                    }
                    else {
                        std::cout << "different msg type is detected" << std::endl;
                    } 
                }
                #endif
            } 
        }
    }
}

void Pq_Hw_GTPDecoder::trasport_layer_proce_tcp (unsigned char *z_packet, gtp_decoder_data &gtp_data, int &byte_offset) {   //process trasport layer  
    
    if ((swap_uint16(tcp_hdr.src_port) == 2123) | (swap_uint16(tcp_hdr.dest_port) == 2123)) {   //control packet only
        gtp_data_str_offset = (34 + 4*((int)ipv4_hdr.header_len-5) + 21 -1) + 4*(tcp_hdr.header_len-5);                     //point to gtp hdr flags
        unsigned char *gtp_pld = (z_packet + gtp_data_str_offset);

        memcpy(&gtp_data.gtp_hdr, gtp_pld, 8+3);              //copy the gtp hdr mandatory field + sequence number (for gtpv2 there should be 24 bit field for seqeunce number)

        //just same code as above gtpv2
        if (gtp_data.gtp_hdr.version == 2) {       //gtpv2
            std::cout << "gtp version 2" << std::endl;
            byte_offset = 4;                            //point to the TEID if it is there or point to a seq number if no TEID 
            if (gtp_data.gtp_hdr.teid) {                    //if teid is there
                byte_offset = byte_offset + 8;      //poin to the msg type
            }

            if (gtp_data.gtp_hdr.pro_piggy) {
                std::cout << "piggyback is detected" << std::endl;      //????????????????????????????????????????
            }
            else {
                if ((swap_uint16(udp_hdr.src_port) == 2123) | (swap_uint16(udp_hdr.dest_port) == 2123)) {  //control plane
                    if ((gtp_data.gtp_hdr.msg_typ == 32) | (gtp_data.gtp_hdr.msg_typ == 33) | (gtp_data.gtp_hdr.msg_typ == 34) | (gtp_data.gtp_hdr.msg_typ == 35) | (gtp_data.gtp_hdr.msg_typ == 36) | (gtp_data.gtp_hdr.msg_typ == 37) | (gtp_data.gtp_hdr.msg_typ == 95) | (gtp_data.gtp_hdr.msg_typ == 96) | (gtp_data.gtp_hdr.msg_typ == 97) | (gtp_data.gtp_hdr.msg_typ == 98) | (gtp_data.gtp_hdr.msg_typ == 99) | (gtp_data.gtp_hdr.msg_typ == 100)) {
                        gtp_data.gtp_en = true;
                        gtp_data.ctrl_or_data = 1;                          //1 -> control
                        gtpv2c_proce(gtp_pld, gtp_data, byte_offset);
                    }
                    else {
                        std::cout << "different msg type is detected" << std::endl;
                    } 
                }
            }
        }
    }
}

void Pq_Hw_GTPDecoder::gtpv1c_proce (unsigned char *gtp_pld, gtp_decoder_data &gtp_data, int &byte_offset) {
    while (swap_uint16(gtp_data.gtp_hdr.msg_length) > byte_offset-8) {         //use length to exit,  can use the byte offset as the length, it is 8 advanced
        //IE = cause*
        if ((int)*(gtp_pld+byte_offset) == 1) {                     
            gtp_data.gtpv1.ie_cause_en = true;
            gtp_data.gtpv1.fcause = 1;
            gtp_data.gtpv1.length++;
            memcpy(&gtp_data.gtpv1.ie_cause, (gtp_pld + byte_offset), 2);
            byte_offset = byte_offset + 2;                          //point to the next msg type

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA CAUSE:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif
        }
        //IE = IMSI*  
        else if ((int)*(gtp_pld+byte_offset) == 2) { 
            gtp_data.gtpv1.ie_imsi_en = true;
            gtp_data.gtpv1.fimsi = 1;
            gtp_data.gtpv1.length++;
            memcpy(&gtp_data.gtpv1.ie_imsi, (gtp_pld + byte_offset), 9);    
            byte_offset = byte_offset + 9;                          //point to the next msg type
            
            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA IMSI:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif
        }
        //IE = TEID-D*
        else if ((int)*(gtp_pld+byte_offset) == 16) { 
            gtp_data.gtpv1.ie_teid_d_en = true;
            gtp_data.gtpv1.fteidu = 1;
            gtp_data.gtpv1.length++;
            memcpy(&gtp_data.gtpv1.ie_teid_d, (gtp_pld + byte_offset), 5);
            byte_offset = byte_offset + 5;                              

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA TEID_D:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif
        }
        //IE = TEID-C*
        else if ((int)*(gtp_pld+byte_offset) == 17) {
            gtp_data.gtpv1.ie_teid_c_en = true;
            gtp_data.gtpv1.fteidc = 1;
            //if (!gtp_data.ie_teid_d_en) {
                gtp_data.gtpv1.length++;
            //}
            memcpy(&gtp_data.gtpv1.ie_teid_c, (gtp_pld + byte_offset), 5);
            byte_offset = byte_offset + 5;               

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA TEID_U:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif               
        }
        //IE = Teardown Ind*
        else if ((int)*(gtp_pld+byte_offset) == 19) {       
            gtp_data.gtpv1.ie_teardown_ind_en = true;
            memcpy(&gtp_data.gtpv1.ie_teardown_ind, (gtp_pld + byte_offset), 2);              
            byte_offset = byte_offset + 2;     

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA teardown_ind:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                         
        }
        //IE = NSAPI*, linked NSAPI* 
        else if ((int)*(gtp_pld+byte_offset) == 20) {   
            if (!gtp_data.gtpv1.ie_nsapi_en) {
                gtp_data.gtpv1.ie_nsapi_en = true;
                memcpy(&gtp_data.gtpv1.ie_nsapi, (gtp_pld + byte_offset), 2); 
            } 
            else {
                gtp_data.gtpv1.ie_linked_nsapi_en = true;
                memcpy(&gtp_data.gtpv1.ie_linked_nsapi, (gtp_pld + byte_offset), 2); 
            }       
            byte_offset = byte_offset + 2;  

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA NSAPI:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                            
        }
        //IE = End User Address*
        else if ((int)*(gtp_pld+byte_offset) == 128) {       
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            if (length == 2) {
                memcpy(&gtp_data.gtpv1.ie_enduseraddr, (gtp_pld + byte_offset), 5);              
                byte_offset = byte_offset + 5;
            }
            else if (length == 6) {
                gtp_data.gtpv1.ie_enduseraddr_en = true;
                gtp_data.gtpv1.fue = 1;
                gtp_data.gtpv1.length++;
                memcpy(&gtp_data.gtpv1.ie_enduseraddr, (gtp_pld + byte_offset), 25);              
                byte_offset = byte_offset + 9;
            }         
            else if (length == 18) {
                gtp_data.gtpv1.ie_enduseraddr_en = true;
                gtp_data.gtpv1.fue = 2;
                gtp_data.gtpv1.length = gtp_data.gtpv1.length + 2;
                memcpy(&gtp_data.gtpv1.ie_enduseraddr, (gtp_pld + byte_offset), 25);              
                byte_offset = byte_offset + 21;
            }                    
            else if (length == 22) {
                gtp_data.gtpv1.ie_enduseraddr_en = true;
                gtp_data.gtpv1.fue = 3;
                gtp_data.gtpv1.length = gtp_data.gtpv1.length + 3;
                memcpy(&gtp_data.gtpv1.ie_enduseraddr, (gtp_pld + byte_offset), 25);              
                byte_offset = byte_offset + 25;
            }    

            #ifdef TEMP_PRTINT
                //std::cout << "TEMP DATA UE length:- " << length << "   " << gtp_data.ie_enduseraddr.length << std::endl;
                std::cout << "TEMP DATA UE:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif
        }
        //IE = Access Point Name*   ???????????????????????????????????
        else if ((int)*(gtp_pld+byte_offset) == 131) {  
            gtp_data.gtpv1.ie_apn_en = true;
            gtp_data.gtpv1.fapn = 1;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv1.ie_apn, (gtp_pld + byte_offset), length + 3);              
            byte_offset = byte_offset + length + 3; 
            if (length%8 > 0) {
                gtp_data.gtpv1.length = gtp_data.gtpv1.length + 1 + (length/8) + 1;
            }
            else {
                gtp_data.gtpv1.length = gtp_data.gtpv1.length + 1 + (length/8);
            }          

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA APN:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                   
        }
        //IE = GSN_C*, GSN_D*, alternative_GSN_C*, alternative_GSN_D* ??????????????????????????
        else if ((int)*(gtp_pld+byte_offset) == 133) {      //have not finished this process
            gtp_data.gtpv1.ie_gsn_en = true;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv1.ie_gsn[gtp_data.gtpv1.ie_gsn_cnt], (gtp_pld + byte_offset), length + 3); 
            byte_offset = byte_offset + length + 3;    
            gtp_data.gtpv1.ie_gsn_cnt++;
            gtp_data.gtpv1.length++;              //??????????????????????????????????????????????          

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA GSN:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif               
        }
        //IE = MSISDN*  
        else if ((int)*(gtp_pld+byte_offset) == 134) { 
            gtp_data.gtpv1.ie_msisdn_en = true;
            gtp_data.gtpv1.fmsisdn = 1;
            gtp_data.gtpv1.length++;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv1.ie_msisdn, (gtp_pld + byte_offset), length + 3);              
            byte_offset = byte_offset + length + 3; 

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA MSISDN:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                             
        }
        //IE = QoS*  
        else if ((int)*(gtp_pld+byte_offset) == 135) { 
            gtp_data.gtpv1.ie_qos_en = true;
            gtp_data.gtpv1.fqos = 1;
            gtp_data.gtpv1.length++;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv1.ie_qos, (gtp_pld + byte_offset), length + 3);              
            byte_offset = byte_offset + length + 3;    

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA QOS:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                          
        }
        //IE = RAT*
        else if ((int)*(gtp_pld+byte_offset) == 151) {       
            gtp_data.gtpv1.ie_rat_en = true;
            gtp_data.gtpv1.frat = 1;
            gtp_data.gtpv1.length++;
            memcpy(&gtp_data.gtpv1.ie_rat, (gtp_pld + byte_offset), 4);              
            byte_offset = byte_offset + 4; 

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA RAT:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                             
        }
        //IE = ULI*  
        else if ((int)*(gtp_pld+byte_offset) == 152) { 
            gtp_data.gtpv1.ie_uli_en = true;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv1.ie_uli[gtp_data.gtpv1.ie_uli_cnt], (gtp_pld + byte_offset), length + 3);              
            byte_offset = byte_offset + length + 3; 
            //gtp_data.gtpv1.ie_uli_cnt++;
            gtp_data.gtpv1.length++;

            /*if (gtp_data.gtpv1.ie_uli_cnt == 1) {
                gtp_data.gtpv1.fuli = 1;
            }
            else if (gtp_data.gtpv1.ie_uli_cnt == 2) {
                gtp_data.gtpv1.fuli = 3;
            }
            else if (gtp_data.gtpv1.ie_uli_cnt == 3) {
                gtp_data.gtpv1.fuli = 7;
            }*/

            if (gtp_data.gtpv1.ie_uli[gtp_data.gtpv1.ie_uli_cnt].geo_loc_typ == 0) {
                gtp_data.gtpv1.fuli = gtp_data.gtpv1.fuli + 1;
            }
            else if (gtp_data.gtpv1.ie_uli[gtp_data.gtpv1.ie_uli_cnt].geo_loc_typ == 1) {
                gtp_data.gtpv1.fuli = gtp_data.gtpv1.fuli + 2;
            }
            else if (gtp_data.gtpv1.ie_uli[gtp_data.gtpv1.ie_uli_cnt].geo_loc_typ == 2) {
                gtp_data.gtpv1.fuli = gtp_data.gtpv1.fuli + 4;
            }
            gtp_data.gtpv1.ie_uli_cnt++;

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA ULI:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                             
        }
        //IE = MS time zone*  
        else if ((int)*(gtp_pld+byte_offset) == 153) { 
            gtp_data.gtpv1.ie_ms_time_zone_en = true;
            gtp_data.gtpv1.fmstime = 1;
            gtp_data.gtpv1.length++;
            memcpy(&gtp_data.gtpv1.ie_ms_time_zone, (gtp_pld + byte_offset), 5);              
            byte_offset = byte_offset + 5; 

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA MS time zone:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                             
        }
        //IE = IMEI*
        else if ((int)*(gtp_pld+byte_offset) == 154) {       
            gtp_data.gtpv1.ie_imei_en = true;
            gtp_data.gtpv1.fimei = 1;
            gtp_data.gtpv1.length++;
            memcpy(&gtp_data.gtpv1.ie_imei, (gtp_pld + byte_offset), 11);              
            byte_offset = byte_offset + 11;     

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA IMEI:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                         
        }
        //IE = DTF*  
        else if ((int)*(gtp_pld+byte_offset) == 182) { 
            gtp_data.gtpv1.ie_dtf_en = true;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv1.ie_dtf, (gtp_pld + byte_offset), length + 3);              
            byte_offset = byte_offset + length + 3;   

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA DTF:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                           
        }
        /////////////////////////////////////////////////////////////////////////
        //IE = RAI
        else if ((int)*(gtp_pld+byte_offset) == 3) {   //ok                    
            byte_offset = byte_offset + 7;  

            #ifdef TEMP_PRTINT  
                std::cout << "TEMP DATA 7:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;                          
            #endif
        }
        //IE = reordering req, Recovery, selection mode
        else if (((int)*(gtp_pld+byte_offset) == 8) | ((int)*(gtp_pld+byte_offset) == 14) | ((int)*(gtp_pld+byte_offset) == 15)) {    //ok
            byte_offset = byte_offset + 2; 

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA 2:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;                             
            #endif
        }
        //IE = charging characteristic, trace reference, trace type 
        else if (((int)*(gtp_pld+byte_offset) == 26) | ((int)*(gtp_pld+byte_offset) == 27) | ((int)*(gtp_pld+byte_offset) == 28)) {   //ok                  
            byte_offset = byte_offset + 3;  

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA 3:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                            
        }
        //IE = charging ID
        else if (((int)*(gtp_pld+byte_offset) == 127)) {   //ok        // | ((int)*(gtp_pld+byte_offset) == 153)       MS time zone      
            byte_offset = byte_offset + 5;   

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA 5:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                           
        }
        //for all variable length processing
        //IE = protocol configuration options, TFT, trigger ID, OMC ID, common flags, APN restriction, CAMEL, addiotional trace info,
        //IE = MS info change reporting action, correlation ID, bearer control mode, evolved allocation, UCI, CSG info reporting action, 
        //IE = APN-AMBR, GGSN back off time, signalling prority indication, ULI timestamp, CN operation, charging gateway addr, private extension  
        else {
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);                   
            byte_offset = byte_offset + length + 3; 

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA variable:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                             
        }
    }
}

void Pq_Hw_GTPDecoder::gtpv2c_proce (unsigned char *gtp_pld, gtp_decoder_data &gtp_data, int &byte_offset) {
    len_cnt = 0;

    while (swap_uint16(gtp_data.gtp_hdr.msg_length) > (len_cnt+8)) {         //use length to exit,  can use the byte offset as the length, it is 8 advanced
        //IE = IMSI*  
        if ((int)*(gtp_pld+byte_offset) == 1) { 
            gtp_data.gtpv2.ie_imsi_en = true;
            gtp_data.gtpv2.fimsi = 1;
            gtp_data.gtpv2.length++;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_imsi, (gtp_pld + byte_offset), length + 4);  
            byte_offset = byte_offset + length + 4;                 //point to the next msg type
            
            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA IMSI:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA IMSI len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif
        }
        //IE = cause*
        else if ((int)*(gtp_pld+byte_offset) == 2) {                     
            gtp_data.gtpv2.ie_cause_en = true;
            gtp_data.gtpv2.fcause = 1;
            gtp_data.gtpv2.length++;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_cause, (gtp_pld + byte_offset), length + 4);  
            byte_offset = byte_offset + length + 4;                 //point to the next msg type

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA CAUSE:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA CAUSE len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif
        }
        //IE = APN*
        else if ((int)*(gtp_pld+byte_offset) == 71) { 
            gtp_data.gtpv2.ie_apn_en = true;
            gtp_data.gtpv2.fapn = 1;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_apn, (gtp_pld + byte_offset), length + 4);  
            byte_offset = byte_offset + length + 4;                 //point to the next msg type 
            if (length%8 > 0) {
                gtp_data.gtpv2.length = gtp_data.gtpv2.length + 1 + (length/8) + 1;
            }
            else {
                gtp_data.gtpv2.length = gtp_data.gtpv2.length + 1 + (length/8);
            }                       

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA APN:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA APN len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif
        }
        //IE = AMBR*
        else if ((int)*(gtp_pld+byte_offset) == 72) {
            gtp_data.gtpv2.ie_ambr_en = true;
            gtp_data.gtpv2.fambr = 1;
            gtp_data.gtpv2.length++;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_ambr, (gtp_pld + byte_offset), length + 4);  
            byte_offset = byte_offset + length + 4;                 //point to the next msg type           

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA AMBR:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA AMBR len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif               
        }
        //IE = EBI*
        else if ((int)*(gtp_pld+byte_offset) == 73) {       
            gtp_data.gtpv2.ie_ebi_en = true;
            gtp_data.gtpv2.febi = 1;
            gtp_data.gtpv2.length++;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_ebi, (gtp_pld + byte_offset), length + 4);  
            byte_offset = byte_offset + length + 4;                 //point to the next msg type   

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA EBI:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA EBI len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif                         
        }
        //IE = IP Addr* 
        else if ((int)*(gtp_pld+byte_offset) == 74) {   
            gtp_data.gtpv2.ie_ipaddr_en = true;
            gtp_data.gtpv2.fipaddr = 1;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_ipaddr[gtp_data.gtpv2.ie_ipaddr_cnt], (gtp_pld + byte_offset), length + 4); 
            byte_offset = byte_offset + length + 4;                 //point to the next msg type
            gtp_data.gtpv2.ie_ipaddr_index = gtp_data.gtpv2.ie_ipaddr_cnt;
            if (length == 4) {
                gtp_data.gtpv2.length = gtp_data.gtpv2.length + 1;
            }
            else if (length == 16) {
                gtp_data.gtpv2.length = gtp_data.gtpv2.length + 2;
            }  
            gtp_data.gtpv2.ie_ipaddr_cnt++; 

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA IP Addr:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA IP Addr len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif                            
        }
        //IE = IMEI*
        else if ((int)*(gtp_pld+byte_offset) == 75) {       
            gtp_data.gtpv2.ie_imei_en = true;
            gtp_data.gtpv2.fimei = 1;
            gtp_data.gtpv2.length++;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_imei, (gtp_pld + byte_offset), length + 4);  
            byte_offset = byte_offset + length + 4;                 //point to the next msg type  

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA IMEI:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA IMEI len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif
        }
        //IE = MSISDN*   
        else if ((int)*(gtp_pld+byte_offset) == 76) {  
            gtp_data.gtpv2.ie_msisdn_en = true;
            gtp_data.gtpv2.fmsisdn = 1;
            gtp_data.gtpv2.length++;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_msisdn, (gtp_pld + byte_offset), length + 4);  
            byte_offset = byte_offset + length + 4;                 //point to the next msg type    

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA MSISDN:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA MSISDN len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif                   
        }
        //IE = BeQoS
        else if ((int)*(gtp_pld+byte_offset) == 80) {     
            gtp_data.gtpv2.ie_beqos_en = true;
            gtp_data.gtpv2.fbqos = 1;
            gtp_data.gtpv2.length = gtp_data.gtpv2.length + 4;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_beqos, (gtp_pld + byte_offset), length + 4);  
            byte_offset = byte_offset + length + 4;                 //point to the next msg type        

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA BeQoS:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA BeQoS len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif               
        }
        //IE = FlQoS*  
        else if ((int)*(gtp_pld+byte_offset) == 81) { 
            gtp_data.gtpv2.ie_flqos_en = true;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_flqos, (gtp_pld + byte_offset), length + 4);  
            byte_offset = byte_offset + length + 4;                 //point to the next msg type  

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA FlQoS:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA FlQoS len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif                             
        }
        //IE = RAT*  
        else if ((int)*(gtp_pld+byte_offset) == 82) { 
            gtp_data.gtpv2.ie_rat_en = true;
            gtp_data.gtpv2.frat = 1;
            gtp_data.gtpv2.length++;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_rat, (gtp_pld + byte_offset), length + 4);  
            byte_offset = byte_offset + length + 4;                 //point to the next msg type    

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA RAT:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA RAT len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif                          
        }
        //IE = ULI*  
        else if ((int)*(gtp_pld+byte_offset) == 86) { 
            gtp_data.gtpv2.ie_uli_en = true;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_uli, (gtp_pld + byte_offset), length + 4);  
            byte_offset = byte_offset + length + 4;                 //point to the next msg type    
            if (gtp_data.gtpv2.ie_uli.CGI) {
                gtp_data.gtpv2.fuli = 1;
                gtp_data.gtpv2.length++;
            }
            if (gtp_data.gtpv2.ie_uli.SAI) {
                gtp_data.gtpv2.fuli = gtp_data.gtpv2.fuli + 2;
                gtp_data.gtpv2.length++;
            }
            if (gtp_data.gtpv2.ie_uli.RAI) {
                gtp_data.gtpv2.fuli = gtp_data.gtpv2.fuli + 4;
                gtp_data.gtpv2.length++;
            }
            if (gtp_data.gtpv2.ie_uli.TAI) {
                gtp_data.gtpv2.fuli = gtp_data.gtpv2.fuli + 8;
                gtp_data.gtpv2.length++;
            }
            if (gtp_data.gtpv2.ie_uli.ECGI) {
                gtp_data.gtpv2.fuli = gtp_data.gtpv2.fuli + 16;
                gtp_data.gtpv2.length++;
            }
            if (gtp_data.gtpv2.ie_uli.LAI) {
                gtp_data.gtpv2.fuli = gtp_data.gtpv2.fuli + 32;
                gtp_data.gtpv2.length++;
            }  

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA ULI:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA ULI len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif                          
        }
        //IE = F-TEID* 
        else if ((int)*(gtp_pld+byte_offset) == 87) {   
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_fteid[gtp_data.gtpv2.ie_fteid_cnt], (gtp_pld + byte_offset), length + 4); 
            byte_offset = byte_offset + length + 4;                 //point to the next msg type
            if ((gtp_data.gtpv2.ie_fteid[gtp_data.gtpv2.ie_fteid_cnt].intf_typ == 10) | (gtp_data.gtpv2.ie_fteid[gtp_data.gtpv2.ie_fteid_cnt].intf_typ == 11)) {
                gtp_data.gtpv2.ie_fteid_c_en = true;
                gtp_data.gtpv2.fteidc = 1;
                gtp_data.gtpv2.length++;            //for TEID
                gtp_data.gtpv2.ie_fteid_c_index = gtp_data.gtpv2.ie_fteid_cnt;
                if (gtp_data.gtpv2.ie_fteid[gtp_data.gtpv2.ie_fteid_cnt].v4) {
                    gtp_data.gtpv2.fteidipcv4 = 1;
                    gtp_data.gtpv2.length++;
                }
                if (gtp_data.gtpv2.ie_fteid[gtp_data.gtpv2.ie_fteid_cnt].v6) {
                    gtp_data.gtpv2.fteidipcv6 = 1;
                    gtp_data.gtpv2.length = gtp_data.gtpv2.length + 2;
                }
            } 
            if ((gtp_data.gtpv2.ie_fteid[gtp_data.gtpv2.ie_fteid_cnt].intf_typ == 0) | (gtp_data.gtpv2.ie_fteid[gtp_data.gtpv2.ie_fteid_cnt].intf_typ == 1)) {
                gtp_data.gtpv2.ie_fteid_u_en = true;
                gtp_data.gtpv2.fteidu = 1;
                gtp_data.gtpv2.length++;            //for TEID
                gtp_data.gtpv2.ie_fteid_u_index = gtp_data.gtpv2.ie_fteid_cnt;
                if (gtp_data.gtpv2.ie_fteid[gtp_data.gtpv2.ie_fteid_cnt].v4) {
                    gtp_data.gtpv2.fteidipuv4 = 1;
                    gtp_data.gtpv2.length++;
                }
                if (gtp_data.gtpv2.ie_fteid[gtp_data.gtpv2.ie_fteid_cnt].v6) {
                    gtp_data.gtpv2.fteidipuv6 = 1;
                    gtp_data.gtpv2.length = gtp_data.gtpv2.length + 2;
                }
            }
            gtp_data.gtpv2.ie_fteid_cnt++; 

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA F-TEID:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA F-TEID len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif                            
        }
        //IE = Bearer context* 
        else if ((int)*(gtp_pld+byte_offset) == 93) {   
            int temp_byte_offset;
            int temp_cnt;
            int temp_length;

            memcpy(&gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt], (gtp_pld + byte_offset), 4); 
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            temp_byte_offset = byte_offset + 4;                     //skip the grouped IE hdr
            temp_cnt = 1;
            byte_offset = byte_offset + length + 4;                 //point to the next msg type

            while (length > temp_cnt) {
                //IE = cause*
                if ((int)*(gtp_pld+temp_byte_offset) == 2) {    
                    gtp_data.gtpv2.ie_be_context_en = true;                 
                    gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_cause_en = true;
                    temp_length = 256*((int)*(gtp_pld+temp_byte_offset+1)) + (int)*(gtp_pld+temp_byte_offset+2);
                    memcpy(&gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_cause, (gtp_pld + temp_byte_offset), temp_length + 4);  
                    temp_byte_offset = temp_byte_offset + temp_length + 4;                 //point to the next msg type 
                    if (!gtp_data.gtpv2.ie_cause_en) {  //if cause at main is not hit
                        gtp_data.gtpv2.fcause = 1;
                        gtp_data.gtpv2.length++;
                    }
                    gtp_data.gtpv2.ie_be_context_cause_index = gtp_data.gtpv2.ie_be_context_cnt; 

                    #ifdef TEMP_PRTINT
                        std::cout << "TEMP DATA Bearer context CAUSE:- " << (int)*(gtp_pld+temp_byte_offset) << " " << (int)*(gtp_pld+temp_byte_offset+1) << std::endl;
                        std::cout << "TEMP DATA Bearer context CAUSE len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
                    #endif
                }
                //IE = EBI*
                else if ((int)*(gtp_pld+temp_byte_offset) == 73) {       
                    gtp_data.gtpv2.ie_be_context_en = true; 
                    gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_ebi_en = true;
                    temp_length = 256*((int)*(gtp_pld+temp_byte_offset+1)) + (int)*(gtp_pld+temp_byte_offset+2);
                    memcpy(&gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_ebi, (gtp_pld + temp_byte_offset), temp_length + 4);  
                    temp_byte_offset = temp_byte_offset + temp_length + 4;                 //point to the next msg type
                    if (!gtp_data.gtpv2.ie_ebi_en) {  //if ebi at main is not hit
                        gtp_data.gtpv2.febi = 1;
                        gtp_data.gtpv2.length++;
                    }
                    gtp_data.gtpv2.ie_be_context_ebi_index = gtp_data.gtpv2.ie_be_context_cnt;

                    #ifdef TEMP_PRTINT
                        std::cout << "TEMP DATA Bearer context EBI:- " << (int)*(gtp_pld+temp_byte_offset) << " " << (int)*(gtp_pld+temp_byte_offset+1) << std::endl;
                        std::cout << "TEMP DATA Bearer context EBI len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
                    #endif                         
                }
                //IE = BeQoS*
                else if ((int)*(gtp_pld+temp_byte_offset) == 80) {    
                    gtp_data.gtpv2.ie_be_context_en = true;                 
                    gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_beqos_en = true;
                    temp_length = 256*((int)*(gtp_pld+temp_byte_offset+1)) + (int)*(gtp_pld+temp_byte_offset+2);
                    memcpy(&gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_beqos, (gtp_pld + temp_byte_offset), temp_length + 4);  
                    temp_byte_offset = temp_byte_offset + temp_length + 4;                 //point to the next msg type
                    if (!gtp_data.gtpv2.ie_beqos_en) {  //if BQoS at main is not hit
                        gtp_data.gtpv2.fbqos = 1;
                        gtp_data.gtpv2.length = gtp_data.gtpv2.length + 4;
                    }
                    gtp_data.gtpv2.ie_be_context_bqos_index = gtp_data.gtpv2.ie_be_context_cnt;

                    #ifdef TEMP_PRTINT
                        std::cout << "TEMP DATA Bearer context QoS:- " << (int)*(gtp_pld+temp_byte_offset) << " " << (int)*(gtp_pld+temp_byte_offset+1) << std::endl;
                        std::cout << "TEMP DATA Bearer context QoS len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
                    #endif
                }
                //IE = F-TEID* 
                else if ((int)*(gtp_pld+temp_byte_offset) == 87) {    
                    temp_length = 256*((int)*(gtp_pld+temp_byte_offset+1)) + (int)*(gtp_pld+temp_byte_offset+2);
                    memcpy(&gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid[gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt], (gtp_pld + temp_byte_offset), temp_length + 4); 
                    temp_byte_offset = temp_byte_offset + temp_length + 4;                 //point to the next msg type
                    if ((gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid[gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt].intf_typ == 10) | (gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid[gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt].intf_typ == 11)) {
                        gtp_data.gtpv2.ie_be_context_en = true; 
                        gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_c_en = true;
                        gtp_data.gtpv2.ie_be_context_teidc_index = gtp_data.gtpv2.ie_be_context_cnt; 
                        gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_c_index = gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt;
                        if (!gtp_data.gtpv2.ie_fteid_c_en) {
                            gtp_data.gtpv2.fteidc = 1;                                      //this is correct, flag at the header
                            gtp_data.gtpv2.length++;
                            if (gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid[gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt].v4) {
                                gtp_data.gtpv2.fteidipcv4 = 1;                                 //this is correct, flag at the header
                                gtp_data.gtpv2.length++;                                    //this is correct, flag at the header
                            }
                            if (gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid[gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt].v6) {
                                gtp_data.gtpv2.fteidipcv6 = 1;        //this is correct, flag at the header
                                gtp_data.gtpv2.length = gtp_data.gtpv2.length + 2;          //this is correct, flag at the header
                            }
                        }
                    } 

                    if ((gtp_data.gtp_hdr.msg_typ == 34) | (gtp_data.gtp_hdr.msg_typ == 96)) {
                        if (gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid[gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt].intf_typ == 0) {
                            gtp_data.gtpv2.ie_be_context_en = true; 
                            gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_u_en = true;
                            gtp_data.gtpv2.ie_be_context_teidu_index = gtp_data.gtpv2.ie_be_context_cnt; 
                            gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_u_index = gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt;
                            if (!gtp_data.gtpv2.ie_fteid_u_en) { 
                                gtp_data.gtpv2.fteidu = 1;                                      //this is correct, flag at the header
                                gtp_data.gtpv2.length++;
                                if (gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid[gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt].v4) {
                                    gtp_data.gtpv2.fteidipuv4 = 1;
                                    gtp_data.gtpv2.length++;
                                }
                                if (gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid[gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt].v6) {
                                    gtp_data.gtpv2.fteidipuv6 = 1;        //this is correct, flag at the header
                                    gtp_data.gtpv2.length = gtp_data.gtpv2.length + 2;          //this is correct, flag at the header
                                }
                            }
                        }
                    }
                    else {
                        if ((gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid[gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt].intf_typ == 0) | (gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid[gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt].intf_typ == 1)) {
                            gtp_data.gtpv2.ie_be_context_en = true; 
                            gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_u_en = true;
                            gtp_data.gtpv2.ie_be_context_teidu_index = gtp_data.gtpv2.ie_be_context_cnt; 
                            gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_u_index = gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt;
                            if (!gtp_data.gtpv2.ie_fteid_u_en) { 
                                gtp_data.gtpv2.fteidu = 1;                                      //this is correct, flag at the header
                                gtp_data.gtpv2.length++;
                                if (gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid[gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt].v4) {
                                    gtp_data.gtpv2.fteidipuv4 = 1;
                                    gtp_data.gtpv2.length++;
                                }
                                if (gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid[gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt].v6) {
                                    gtp_data.gtpv2.fteidipuv6 = 1;        //this is correct, flag at the header
                                    gtp_data.gtpv2.length = gtp_data.gtpv2.length + 2;          //this is correct, flag at the header
                                }
                            }
                        }  
                    }
                    
                    gtp_data.gtpv2.ie_be_context[gtp_data.gtpv2.ie_be_context_cnt].ie_fteid_cnt++;  
                    

                    #ifdef TEMP_PRTINT
                        std::cout << "TEMP DATA Bearer context F-TEID:- " << (int)*(gtp_pld+temp_byte_offset) << " " << (int)*(gtp_pld+temp_byte_offset+1) << std::endl;
                        std::cout << "TEMP DATA Bearer context F-TEID len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
                    #endif                 
                }
                //for all other IE to skips
                else {      
                    temp_length = 256*((int)*(gtp_pld+temp_byte_offset+1)) + (int)*(gtp_pld+temp_byte_offset+2);                   
                    temp_byte_offset = temp_byte_offset + temp_length + 4; 
        
                    #ifdef TEMP_PRTINT
                        std::cout << "TEMP DATA variable:- " << (int)*(gtp_pld+temp_byte_offset) << " " << (int)*(gtp_pld+temp_byte_offset+1) << std::endl;
                        std::cout << "TEMP DATA variable len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
                    #endif                             
                }
                temp_cnt = temp_cnt + temp_length + 4;
            }

            gtp_data.gtpv2.ie_be_context_cnt++;
            
            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA Bearer Context:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA Bearer Context len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif                            
        }
        //IE = UE time zone*  
        else if ((int)*(gtp_pld+byte_offset) == 114) { 
            gtp_data.gtpv2.ie_ue_time_zone_en = true;
            gtp_data.gtpv2.fmstime = 1;
            gtp_data.gtpv2.length++;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_ue_time_zone, (gtp_pld + byte_offset), length + 4);  
            byte_offset = byte_offset + length + 4;                 //point to the next msg type    

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA UE Time Zone:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA UE Time Zone len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif                          
        }
        //IE = Port Number* 
        else if ((int)*(gtp_pld+byte_offset) == 126) {   
            gtp_data.gtpv2.ie_port_no_en = true;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_port_no[gtp_data.gtpv2.ie_port_no_cnt], (gtp_pld + byte_offset), length + 4); 
            byte_offset = byte_offset + length + 4;                 //point to the next msg type
            gtp_data.gtpv2.ie_port_no_cnt++;  

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA Port Number:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA Port Number len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif                            
        }
        //IE = ULI time stamp*  
        else if ((int)*(gtp_pld+byte_offset) == 170) { 
            gtp_data.gtpv2.ie_uli_timestamp_en = true;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_uli_timestamp, (gtp_pld + byte_offset), length + 4);  
            byte_offset = byte_offset + length + 4;                 //point to the next msg type    

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA ULI time stamp:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
                std::cout << "TEMP DATA ULI time stamp len:- " << (int)(gtp_data.gtpv2.length) << std::endl;
            #endif                          
        }
        //IE = overload ctrl info* 
        else if ((int)*(gtp_pld+byte_offset) == 180) {   
            int temp_byte_offset;
            int temp_cnt;
            int temp_length;

            memcpy(&gtp_data.gtpv2.ie_overload_ctrl_info[gtp_data.gtpv2.ie_overload_ctrl_info_cnt], (gtp_pld + byte_offset), 4); 
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            temp_byte_offset = byte_offset + 4;                     //skip the grouped IE hdr
            temp_cnt = 1;
            byte_offset = byte_offset + length + 4;                 //point to the next msg type
            

            while (length > temp_cnt) {
                //IE = APN*
                if ((int)*(gtp_pld+temp_byte_offset) == 71) {    
                    gtp_data.gtpv2.ie_overload_ctrl_info_en = true;                 
                    gtp_data.gtpv2.ie_overload_ctrl_info[gtp_data.gtpv2.ie_overload_ctrl_info_cnt].ie_apn_en = true;
                    temp_length = 256*((int)*(gtp_pld+temp_byte_offset+1)) + (int)*(gtp_pld+temp_byte_offset+2);
                    memcpy(&gtp_data.gtpv2.ie_overload_ctrl_info[gtp_data.gtpv2.ie_overload_ctrl_info_cnt].ie_apn, (gtp_pld + temp_byte_offset), temp_length + 4);  
                    temp_byte_offset = temp_byte_offset + temp_length + 4;                 //point to the next msg type 
        
                    #ifdef TEMP_PRTINT
                        std::cout << "TEMP DATA overload ctrl info APN:- " << (int)*(gtp_pld+temp_byte_offset) << " " << (int)*(gtp_pld+temp_byte_offset+1) << std::endl;
                    #endif
                }
                //for all other IE to skips
                else {      
                    temp_length = 256*((int)*(gtp_pld+temp_byte_offset+1)) + (int)*(gtp_pld+temp_byte_offset+2);                   
                    temp_byte_offset = temp_byte_offset + temp_length + 4; 
        
                    #ifdef TEMP_PRTINT
                        std::cout << "TEMP DATA variable:- " << (int)*(gtp_pld+temp_byte_offset) << " " << (int)*(gtp_pld+temp_byte_offset+1) << std::endl;
                    #endif                             
                }
                temp_cnt = temp_cnt + temp_length + 4;
            }

            gtp_data.gtpv2.ie_overload_ctrl_info_cnt++;
            
            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA overload ctrl info:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                            
        }
        //IE = load ctrl info* 
        else if ((int)*(gtp_pld+byte_offset) == 181) {   
            int temp_byte_offset;
            int temp_cnt;
            int temp_length;

            memcpy(&gtp_data.gtpv2.ie_load_ctrl_info[gtp_data.gtpv2.ie_load_ctrl_info_cnt], (gtp_pld + byte_offset), 4); 
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            temp_byte_offset = byte_offset + 4;                     //skip the grouped IE hdr
            temp_cnt = 1;
            byte_offset = byte_offset + length + 4;                 //point to the next msg type

            while (length > temp_cnt) {
                //IE = APN & relative capacity*
                if ((int)*(gtp_pld+temp_byte_offset) == 184) {    
                    gtp_data.gtpv2.ie_load_ctrl_info_en = true;                 
                    gtp_data.gtpv2.ie_load_ctrl_info[gtp_data.gtpv2.ie_load_ctrl_info_cnt].ie_apn_reltcap_en = true;
                    temp_length = 256*((int)*(gtp_pld+temp_byte_offset+1)) + (int)*(gtp_pld+temp_byte_offset+2);
                    memcpy(&gtp_data.gtpv2.ie_load_ctrl_info[gtp_data.gtpv2.ie_load_ctrl_info_cnt].ie_apn_reltcap, (gtp_pld + temp_byte_offset), temp_length + 4);  
                    temp_byte_offset = temp_byte_offset + temp_length + 4;                 //point to the next msg type 
        
                    #ifdef TEMP_PRTINT
                        std::cout << "TEMP DATA load ctrl info APN_and_relative capacity:- " << (int)*(gtp_pld+temp_byte_offset) << " " << (int)*(gtp_pld+temp_byte_offset+1) << std::endl;
                    #endif
                }
                //for all other IE to skips
                else {      
                    temp_length = 256*((int)*(gtp_pld+temp_byte_offset+1)) + (int)*(gtp_pld+temp_byte_offset+2);                   
                    temp_byte_offset = temp_byte_offset + temp_length + 4; 
        
                    #ifdef TEMP_PRTINT
                        std::cout << "TEMP DATA variable:- " << (int)*(gtp_pld+temp_byte_offset) << " " << (int)*(gtp_pld+temp_byte_offset+1) << std::endl;
                    #endif                             
                }
                temp_cnt = temp_cnt + temp_length + 4;
            }

            gtp_data.gtpv2.ie_load_ctrl_info_cnt++;
            
            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA load ctrl info:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                            
        }
        //IE = APN & relative capacity*  
        else if ((int)*(gtp_pld+byte_offset) == 184) { 
            gtp_data.gtpv2.ie_apn_reltcap_en = true;
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);
            memcpy(&gtp_data.gtpv2.ie_apn_reltcap, (gtp_pld + byte_offset), length + 4);  
            byte_offset = byte_offset + length + 4;                 //point to the next msg type    

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA APN and relative capacity:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                          
        }
        //for all other IE to skips
        else {      
            length = 256*((int)*(gtp_pld+byte_offset+1)) + (int)*(gtp_pld+byte_offset+2);                   
            byte_offset = byte_offset + length + 4; 

            #ifdef TEMP_PRTINT
                std::cout << "TEMP DATA variable:- " << (int)*(gtp_pld+byte_offset) << " " << (int)*(gtp_pld+byte_offset+1) << std::endl;
            #endif                             
        }

        len_cnt = len_cnt + length + 4;

        #ifdef TEMP_PRTINT
            std::cout << "TEMP DATA len_cnt:- " << len_cnt << " dtp hdr length :-" << swap_uint16(gtp_data.gtp_hdr.msg_length) << std::endl;
        #endif
    }
}

void Pq_Hw_GTPDecoder::print_output (gtp_decoder_data &gtp_data) {
    if (gtp_data.gtp_hdr.version == 1) {    //GTPv1
        std::cout << std::endl;
        std::cout << "gtp_version:- " << (int)gtp_data.gtp_hdr.version << std::endl;
        std::cout << "gtp_protocol:- " << (int)gtp_data.gtp_hdr.pro_piggy << std::endl;
        std::cout << "gtp_msg_typ:- " << (int)gtp_data.gtp_hdr.msg_typ << std::endl;
        std::cout << "gtp_msg_length:- " << swap_uint16(gtp_data.gtp_hdr.msg_length) << std::endl;
        std::cout << "gtp_teid:- " << std::hex << gtp_data.gtp_hdr.teid << std::dec << std::endl;
        if (gtp_data.gtp_hdr.S) {
            std::cout << "gtp_sequence_number:- " << std::hex << swap_uint16(gtp_data.gtp_hdr.seq_no) << std::dec << std::endl;
        } 
        std::cout << "#######################################################################" << std::endl;

        if (gtp_data.ctrl_or_data == 1) {    //control plane
            std::cout << "total_length:- " << (int)gtp_data.gtpv1.length << std::endl;
            std::cout << "fseq:- " << (int)gtp_data.gtpv1.fseq << std::endl;
            std::cout << "fcause:- " << (int)gtp_data.gtpv1.fcause << std::endl;
            std::cout << "fteidc:- " << (int)gtp_data.gtpv1.fteidc << std::endl;
            std::cout << "fteidu:- " << (int)gtp_data.gtpv1.fteidu << std::endl;
            std::cout << "fue:- " << (int)gtp_data.gtpv1.fue << std::endl;
            std::cout << "fimei:- " << (int)gtp_data.gtpv1.fimei << std::endl;
            std::cout << "fimsi:- " << (int)gtp_data.gtpv1.fimsi << std::endl;
            std::cout << "fmsisdn:- " << (int)gtp_data.gtpv1.fmsisdn << std::endl;
            std::cout << "frat:- " << (int)gtp_data.gtpv1.frat << std::endl;
            std::cout << "fuli:- " << (int)gtp_data.gtpv1.fuli << std::endl;
            std::cout << "fqos:- " << (int)gtp_data.gtpv1.fqos << std::endl;
            std::cout << "fmstime:- " << (int)gtp_data.gtpv1.fmstime << std::endl;
            std::cout << "fgsnip:- " << (int)gtp_data.gtpv1.ie_gsn_cnt << std::endl;
            std::cout << "fapn:- " << (int)gtp_data.gtpv1.fapn << std::endl;
            std::cout << "#######################################################################" << std::endl;
            print_gtpv1_c_output(gtp_data);
        }
        else {   //data plane
            print_gtpv1_u_output(gtp_data);
        }
    }
    else if (gtp_data.gtp_hdr.version == 2) {    //GTPv2 only control plane
        std::cout << std::endl;
        std::cout << "gtp_version:- " << (int)gtp_data.gtp_hdr.version << std::endl;
        std::cout << "piggyback:- " << (int)gtp_data.gtp_hdr.pro_piggy << std::endl;
        std::cout << "gtp_msg_typ:- " << (int)gtp_data.gtp_hdr.msg_typ << std::endl;
        std::cout << "gtp_msg_length:- " << swap_uint16(gtp_data.gtp_hdr.msg_length) << std::endl;
        if (gtp_data.gtp_hdr.teid_en) {
            std::cout << "gtp_teid:- " << std::hex << gtp_data.gtp_hdr.teid << std::dec << std::endl;  
        }
        std::cout << "gtp_sequence_number:- " << std::hex << swap_uint16(gtp_data.gtp_hdr.seq_no) << std::dec << std::endl;
        std::cout << "gtp_sequence_number_remain:- " << std::hex << (int)gtp_data.gtp_hdr.seq_no_rem << std::dec << std::endl;
        std::cout << "#######################################################################" << std::endl;

        if (gtp_data.ctrl_or_data == 1) {    //control plane
            std::cout << "total_length:- " << (int)gtp_data.gtpv2.length << std::endl;
            std::cout << "fseq:- " << (int)gtp_data.gtpv2.fseq << std::endl;
            std::cout << "fcause:- " << (int)gtp_data.gtpv2.fcause << std::endl;
            std::cout << "fteidc:- " << (int)gtp_data.gtpv2.fteidc << std::endl;
            std::cout << "fteidu:- " << (int)gtp_data.gtpv2.fteidu << std::endl;
            std::cout << "fue:- " << (int)gtp_data.gtpv2.fipaddr << std::endl;
            std::cout << "fimei:- " << (int)gtp_data.gtpv2.fimei << std::endl;
            std::cout << "fimsi:- " << (int)gtp_data.gtpv2.fimsi << std::endl;
            std::cout << "fmsisdn:- " << (int)gtp_data.gtpv2.fmsisdn << std::endl;
            std::cout << "frat:- " << (int)gtp_data.gtpv2.frat << std::endl;
            std::cout << "fuli:- " << (int)gtp_data.gtpv2.fuli << std::endl;
            std::cout << "fqos:- " << (int)gtp_data.gtpv2.fbqos << std::endl;
            std::cout << "febi:- " << (int)gtp_data.gtpv2.febi << std::endl;
            std::cout << "fambr:- " << (int)gtp_data.gtpv2.fambr << std::endl;
            std::cout << "fmstime:- " << (int)gtp_data.gtpv2.fmstime << std::endl;
            std::cout << "fteidipcv4:- " << (int)gtp_data.gtpv2.fteidipcv4 << std::endl;
            std::cout << "fteidipcv6:- " << (int)gtp_data.gtpv2.fteidipcv6 << std::endl;
            std::cout << "fteidipuv4:- " << (int)gtp_data.gtpv2.fteidipuv4 << std::endl;
            std::cout << "fteidipuv6:- " << (int)gtp_data.gtpv2.fteidipuv6 << std::endl;
            std::cout << "fapn:- " << (int)gtp_data.gtpv2.fapn << std::endl;
            std::cout << "#######################################################################" << std::endl;
            print_gtpv2_c_output(gtp_data);
        }
    }
}

void Pq_Hw_GTPDecoder::print_gtpv1_c_output (gtp_decoder_data &gtp_data) {
    if (gtp_data.gtpv1.ie_cause_en) {
        std::cout << "IE_type is casue:- " << (int)gtp_data.gtpv1.ie_cause.type << std::endl;
        //std::cout << "IE_respe:- " << (int)gtp_data.gtpv1.ie_cause.resp_bit << std::endl;
        //std::cout << "IE_rejt:- " << (int)gtp_data.gtpv1.ie_cause.rejt_bit << std::endl;
        std::cout << "IE_cause:- " << (int)gtp_data.gtpv1.ie_cause.cause_value << std::endl;
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv1.ie_imsi_en) {
        std::cout << "IE_type is IMSI:- " << (int)gtp_data.gtpv1.ie_imsi.type << std::endl;
        std::cout << "IE_IMSI:- " << std::hex << (long)gtp_data.gtpv1.ie_imsi.IMSI << std::dec << std::endl;
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv1.ie_teid_d_en) {
        std::cout << "IE_type is TEID_D:- " << (int)gtp_data.gtpv1.ie_teid_d.type << std::endl;
        std::cout << "IE_TEID_D:- " << std::hex << (int)gtp_data.gtpv1.ie_teid_d.TEID << std::dec << std::endl;
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv1.ie_teid_c_en) {
        std::cout << "IE_type is TEID_C:- " << (int)gtp_data.gtpv1.ie_teid_c.type << std::endl;
        std::cout << "IE_TEID_D:- " << std::hex << (int)gtp_data.gtpv1.ie_teid_c.TEID << std::dec << std::endl;
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv1.ie_teardown_ind_en) {
        std::cout << "IE_type is teardown:- " << (int)gtp_data.gtpv1.ie_teardown_ind.type << std::endl;
        std::cout << "IE_teardown_ind:- " << (int)gtp_data.gtpv1.ie_teardown_ind.teardown_ind << std::endl;
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv1.ie_nsapi_en) {
        std::cout << "IE_type is NSAPI:- " << (int)gtp_data.gtpv1.ie_nsapi.type << std::endl;
        std::cout << "IE_NSAPI:- " << std::hex << (int)gtp_data.gtpv1.ie_nsapi.NSAPI << std::dec << std::endl;
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv1.ie_linked_nsapi_en) {
        std::cout << "IE_type is linked NSAPI:- " << (int)gtp_data.gtpv1.ie_linked_nsapi.type << std::endl;
        std::cout << "IE_linked_NSAPI:- " << std::hex << (int)gtp_data.gtpv1.ie_linked_nsapi.NSAPI << std::dec << std::endl;
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv1.ie_enduseraddr_en) {
        std::cout << "IE_type is UE:- " << (int)gtp_data.gtpv1.ie_enduseraddr.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv1.ie_enduseraddr.length) << std::endl;
        std::cout << "IE_PDP_type:- " << (int)gtp_data.gtpv1.ie_enduseraddr.PDP_typ << std::endl;
        std::cout << "IE_PDP_type_number:- " << (int)gtp_data.gtpv1.ie_enduseraddr.PDP_typ_number << std::endl;

        for (int i = 0; i < ((swap_uint16(gtp_data.gtpv1.ie_enduseraddr.length))-2); i++) {
            std::cout << "IE_PDP_addr:- " << std::hex << (int)gtp_data.gtpv1.ie_enduseraddr.PDP_addr[i] << std::dec << std::endl;
        }
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv1.ie_apn_en) {
        std::cout << "IE_type is APN:- " << (int)gtp_data.gtpv1.ie_apn.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv1.ie_apn.length) << std::endl;
        for (int i = 0; i < swap_uint16(gtp_data.gtpv1.ie_apn.length); i++) {
            std::cout << "IE_APN_value:- " << std::hex << (int)gtp_data.gtpv1.ie_apn.APN_value[i] << std::dec << std::endl;
        }   
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv1.ie_gsn_en) {  //?????????????????????
        for (int j =0; j < gtp_data.gtpv1.ie_gsn_cnt; j++) {
            std::cout << "IE_type is GSN:- " << (int)gtp_data.gtpv1.ie_gsn[j].type << std::endl;
            std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv1.ie_gsn[j].length) << std::endl;
            for (int i = 0; i < swap_uint16(gtp_data.gtpv1.ie_gsn[j].length); i++) {
                std::cout << "IE_GSN_address:- " << std::hex << (int)gtp_data.gtpv1.ie_gsn[j].GSN_address[i] << std::dec << std::endl;
            }
        }
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv1.ie_msisdn_en) {
        std::cout << "IE_type is MSISDN:- " << (int)gtp_data.gtpv1.ie_msisdn.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv1.ie_msisdn.length) << std::endl;
        for (int i = 0; i < swap_uint16(gtp_data.gtpv1.ie_msisdn.length); i++) {
            std::cout << "IE_MSISDN:- " << std::hex << (int)gtp_data.gtpv1.ie_msisdn.MSISDN[i] << std::dec << std::endl;
        }
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv1.ie_qos_en) {
        std::cout << "IE_type is QoS:- " << (int)gtp_data.gtpv1.ie_qos.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv1.ie_qos.length) << std::endl;
        std::cout << "IE_prority:- " << (int)gtp_data.gtpv1.ie_qos.prority << std::endl;
        for (int i = 0; i < (swap_uint16(gtp_data.gtpv1.ie_qos.length)-1); i++) {
            std::cout << "IE_qos_data:- " << std::hex << (int)gtp_data.gtpv1.ie_qos.qos_data[i] << std::dec << std::endl;
        }
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv1.ie_rat_en) {
        std::cout << "IE_type is RAT:- " << (int)gtp_data.gtpv1.ie_rat.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv1.ie_rat.length) << std::endl;
        std::cout << "IE_RAT_typ:- " << (int)gtp_data.gtpv1.ie_rat.RAT_typ << std::endl;
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv1.ie_uli_en) {
        for (int j =0; j < gtp_data.gtpv1.ie_uli_cnt; j++) {
            std::cout << "IE_type is ULI:- " << (int)gtp_data.gtpv1.ie_uli[j].type << std::endl;
            std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv1.ie_uli[j].length) << std::endl;
            std::cout << "IE_geo_loc_typ:- " << (int)gtp_data.gtpv1.ie_uli[j].geo_loc_typ << std::endl;
            for (int i = 0; i < (swap_uint16(gtp_data.gtpv1.ie_uli[j].length)-1); i++) {
                std::cout << "IE_geo_loc:- " << std::hex << (int)gtp_data.gtpv1.ie_uli[j].geo_loc[i] << std::dec << std::endl;
            }
            std::cout << "#######################################################################" << std::endl;
        }
    }
    if (gtp_data.gtpv1.ie_ms_time_zone_en) {
        std::cout << "IE_type is MS Time Zone:- " << (int)gtp_data.gtpv1.ie_ms_time_zone.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv1.ie_ms_time_zone.length) << std::endl;
        std::cout << "IE_RAT_time_zone:- " << (int)gtp_data.gtpv1.ie_ms_time_zone.time_zone << std::endl;
        std::cout << "IE_RAT_daylight_saving:- " << (int)gtp_data.gtpv1.ie_ms_time_zone.dayalight_saving << std::endl;
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv1.ie_imei_en) {
        std::cout << "IE_type is IMEI:- " << (int)gtp_data.gtpv1.ie_imei.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv1.ie_imei.length) << std::endl;
        std::cout << "IE_IMEI:- " << std::hex << (long)gtp_data.gtpv1.ie_imei.IMEI << std::dec << std::endl;
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv1.ie_dtf_en) {
        std::cout << "IE_type is DTF:- " << (int)gtp_data.gtpv1.ie_dtf.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv1.ie_dtf.length) << std::endl;
        std::cout << "IE_DTI:- " << (int)gtp_data.gtpv1.ie_dtf.DTI << std::endl;
        std::cout << "#######################################################################" << std::endl;
    }


    std::cout << std::endl;
    std::cout << "#######################################################################" << std::endl;
    std::cout << "#######################################################################" << std::endl;
}

void Pq_Hw_GTPDecoder::print_gtpv1_u_output (gtp_decoder_data &gtp_data) {
    std::cout << "total byte offset:- " << (int)gtp_data.gtpv1u.byte_offset << std::endl;
    for (int i = 0; i < 4; i++) {
        std::cout << (int)(i+1) << "-> 64bits :- " << std::hex << (long int)gtp_data.gtpv1u.data[i] << std::dec << std::endl;
    }
    std::cout << std::endl;
    std::cout << "#######################################################################" << std::endl;
    std::cout << "#######################################################################" << std::endl;
}

void Pq_Hw_GTPDecoder::print_gtpv2_c_output (gtp_decoder_data &gtp_data) {
    if (gtp_data.gtpv2.ie_imsi_en) {
        std::cout << "IE_type is IMSI:- " << (int)gtp_data.gtpv2.ie_imsi.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_imsi.length) << std::endl;
        /*for (int i = 0; i < swap_uint16(gtp_data.gtpv2.ie_imsi.length); i++) {
            std::cout << "IE_IMSI_value:- " << std::hex << (int)gtp_data.gtpv2.ie_imsi.IMSI[i] << std::dec << std::endl;
        }*/ 
        std::cout << "IE_IMSI:- " << std::hex << (long)gtp_data.gtpv2.ie_imsi.IMSI << std::dec << std::endl;  
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv2.ie_cause_en) {
        std::cout << "IE_type is cause:- " << (int)gtp_data.gtpv2.ie_cause.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_cause.length) << std::endl;
        std::cout << "cause value:- " << (int)gtp_data.gtpv2.ie_cause.cause_value << std::endl;
        for (int i = 0; i < (swap_uint16(gtp_data.gtpv2.ie_cause.length)-2); i++) {
            std::cout << "IE_cause:- " << std::hex << (int)gtp_data.gtpv2.ie_cause.data[i] << std::dec << std::endl;
        }   
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv2.ie_apn_en) {
        std::cout << "IE_type is APN:- " << (int)gtp_data.gtpv2.ie_apn.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_apn.length) << std::endl;
        for (int i = 0; i < swap_uint16(gtp_data.gtpv2.ie_apn.length); i++) {
            std::cout << "IE_APN_value:- " << std::hex << (int)gtp_data.gtpv2.ie_apn.APN_value[i] << std::dec << std::endl;
        }   
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv2.ie_ambr_en) {
        std::cout << "IE_type is AMBR:- " << (int)gtp_data.gtpv2.ie_ambr.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_ambr.length) << std::endl;
        std::cout << "uplink:- " << (unsigned int)gtp_data.gtpv2.ie_ambr.uplink << std::endl;           //reverse the order of the 32bits
        std::cout << "downlink:- " << (unsigned int)gtp_data.gtpv2.ie_ambr.downlink << std::endl;
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv2.ie_ebi_en) {
        std::cout << "IE_type is EBI:- " << (int)gtp_data.gtpv2.ie_ebi.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_ebi.length) << std::endl;
        std::cout << "EBI_ID:- " << (int)gtp_data.gtpv2.ie_ebi.EBI_ID << std::endl;  
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv2.ie_ipaddr_en) {
        for (int j =0; j < gtp_data.gtpv2.ie_ipaddr_cnt; j++) {
            std::cout << "IE_type is IP Addr:- " << (int)gtp_data.gtpv2.ie_ipaddr[j].type << std::endl;
            std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_ipaddr[j].length) << std::endl;
            for (int i = 0; i < swap_uint16(gtp_data.gtpv2.ie_ipaddr[j].length); i++) {
                std::cout << "IE_IP_address:- " << std::hex << (int)gtp_data.gtpv2.ie_ipaddr[j].ip_address[i] << std::dec << std::endl;
            }
        }
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv2.ie_imei_en) {
        std::cout << "IE_type is IMEI:- " << (int)gtp_data.gtpv2.ie_imei.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_imei.length) << std::endl;
        /*for (int i = 0; i < swap_uint16(gtp_data.gtpv2.ie_imei.length); i++) {
            std::cout << "IE_IMEI:- " << std::hex << (int)gtp_data.gtpv2.ie_imei.IMEI[i] << std::dec << std::endl;
        }*/ 
        std::cout << "IE_IMEI:- " << std::hex << (long)gtp_data.gtpv2.ie_imei.IMEI << std::dec << std::endl;    
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv2.ie_msisdn_en) {
        std::cout << "IE_type is MSISDN:- " << (int)gtp_data.gtpv2.ie_msisdn.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_msisdn.length) << std::endl;
        for (int i = 0; i < swap_uint16(gtp_data.gtpv2.ie_msisdn.length); i++) {
            std::cout << "IE_MSISDN:- " << std::hex << (int)gtp_data.gtpv2.ie_msisdn.MSISDN[i] << std::dec << std::endl;
        }   
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv2.ie_beqos_en) {
        std::cout << "IE_type is Bearer QoS:- " << (int)gtp_data.gtpv2.ie_beqos.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_beqos.length) << std::endl;
        std::cout << "IE_PVI, PL, PCI:- " << gtp_data.gtpv2.ie_beqos.PVI << " " << gtp_data.gtpv2.ie_beqos.PL << " " << gtp_data.gtpv2.ie_beqos.PCI << std::endl;
        std::cout << "IE_QCI:- " << gtp_data.gtpv2.ie_beqos.QCI << std::endl;
        for (int i = 0; i < (swap_uint16(gtp_data.gtpv2.ie_beqos.length)-2); i++) {
            std::cout << "IE_Bearer QoS:- " << std::hex << (int)gtp_data.gtpv2.ie_beqos.qos_data[i] << std::dec << std::endl;
        }   
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv2.ie_flqos_en) {
        std::cout << "IE_type is Flow QoS:- " << (int)gtp_data.gtpv2.ie_flqos.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_flqos.length) << std::endl;
        std::cout << "IE_QCI:- " << gtp_data.gtpv2.ie_flqos.QCI << std::endl;
        for (int i = 0; i < (swap_uint16(gtp_data.gtpv2.ie_flqos.length)-1); i++) {
            std::cout << "IE_Flow QoS:- " << std::hex << (int)gtp_data.gtpv2.ie_flqos.qos_data[i] << std::dec << std::endl;
        }   
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv2.ie_rat_en) {
        std::cout << "IE_type is RAT:- " << (int)gtp_data.gtpv2.ie_rat.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_rat.length) << std::endl;
        std::cout << "IE_RAT_typ:- " << (int)gtp_data.gtpv2.ie_rat.RAT_typ << std::endl;
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv2.ie_uli_en) {
        std::cout << "IE_type is ULI:- " << (int)gtp_data.gtpv2.ie_uli.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_uli.length) << std::endl;
        std::cout << "CGI, SAI, RAI, TAI, ECGI, LAI:- " << (int)gtp_data.gtpv2.ie_uli.CGI << " " << (int)gtp_data.gtpv2.ie_uli.SAI << " " << (int)gtp_data.gtpv2.ie_uli.RAI << " " << (int)gtp_data.gtpv2.ie_uli.TAI << " " << (int)gtp_data.gtpv2.ie_uli.ECGI << " " << (int)gtp_data.gtpv2.ie_uli.LAI << std::endl;
        for (int i = 0; i < (swap_uint16(gtp_data.gtpv2.ie_uli.length)-1); i++) {
            std::cout << "geo_loc_data:- " << std::hex << (int)gtp_data.gtpv2.ie_uli.geo_loc[i] << std::dec << std::endl;
        }   
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv2.ie_fteid_c_en | gtp_data.gtpv2.ie_fteid_u_en) {
        for (int j =0; j < gtp_data.gtpv2.ie_fteid_cnt; j++) {
            std::cout << "IE_type is FTEID:- " << (int)gtp_data.gtpv2.ie_fteid[j].type << std::endl;
            std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_fteid[j].length) << std::endl;
            std::cout << "IE_IF_type:- " << (int)gtp_data.gtpv2.ie_fteid[j].intf_typ << std::endl;
            std::cout << "IE_V6, V4:- " << (int)gtp_data.gtpv2.ie_fteid[j].v6 << " " << (int)gtp_data.gtpv2.ie_fteid[j].v4 << std::endl;
            std::cout << "IE_TEID:- " << std::hex << (unsigned int)gtp_data.gtpv2.ie_fteid[j].teid << std::dec << std::endl;
            if ((int)gtp_data.gtpv2.ie_fteid[j].v4 == 1) {   //IPv4 addr
                for (int i = 0; i < 4; i++) {
                    std::cout << "IE_TEID IPv4 Addr:- " << (int)gtp_data.gtpv2.ie_fteid[j].data[i] << std::endl;
                }
            }
            if ((int)gtp_data.gtpv2.ie_fteid[j].v6 == 1) {
                if ((int)gtp_data.gtpv2.ie_fteid[j].v4 == 1) {   //if has IPv4 addr
                    for (int i = 4; i < 20; i++) {
                        std::cout << "IE_TEID IPv6 Addr:- " << (int)gtp_data.gtpv2.ie_fteid[j].data[i] << std::endl;
                    }
                }
                else {
                    for (int i = 0; i < 16; i++) {
                        std::cout << "IE_TEID IPv6 Addr:- " << (int)gtp_data.gtpv2.ie_fteid[j].data[i] << std::endl;
                    }
                }
            }
        }
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv2.ie_be_context_en) {
        for (int j =0; j < gtp_data.gtpv2.ie_be_context_cnt; j++) {
            std::cout << "IE_type is bearer context:- " << (int)gtp_data.gtpv2.ie_be_context[j].type << std::endl;
            std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_be_context[j].length) << std::endl;

            if (gtp_data.gtpv2.ie_be_context[j].ie_cause_en) {
                std::cout << "Bearer Context IE_type is cause:- " << (int)gtp_data.gtpv2.ie_be_context[j].ie_cause.type << std::endl;
                std::cout << "Bearer Context IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_be_context[j].ie_cause.length) << std::endl;
                std::cout << "Bearer Context cause value:- " << (int)gtp_data.gtpv2.ie_be_context[j].ie_cause.cause_value << std::endl;
                for (int i = 0; i < (swap_uint16(gtp_data.gtpv2.ie_be_context[j].ie_cause.length)-2); i++) {
                    std::cout << "Bearer Context IE_cause:- " << std::hex << (int)gtp_data.gtpv2.ie_be_context[j].ie_cause.data[i] << std::dec << std::endl;
                }   
                std::cout << "#######################################################################" << std::endl;
            } 
            if (gtp_data.gtpv2.ie_be_context[j].ie_ebi_en) {
                std::cout << "Bearer Context IE_type is EBI:- " << (int)gtp_data.gtpv2.ie_be_context[j].ie_ebi.type << std::endl;
                std::cout << "Bearer Context IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_be_context[j].ie_ebi.length) << std::endl;
                std::cout << "Bearer Context EBI_ID:- " << (int)gtp_data.gtpv2.ie_be_context[j].ie_ebi.EBI_ID << std::endl; 
                std::cout << "#######################################################################" << std::endl;
            } 
            if (gtp_data.gtpv2.ie_be_context[j].ie_beqos_en) {
                std::cout << "Bearer Context IE_type is Bearer QoS:- " << (int)gtp_data.gtpv2.ie_be_context[j].ie_beqos.type << std::endl;
                std::cout << "Bearer Context IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_be_context[j].ie_beqos.length) << std::endl;
                std::cout << "Bearer Context IE_PVI, PL, PCI:- " << (int)gtp_data.gtpv2.ie_be_context[j].ie_beqos.PVI << " " << (int)gtp_data.gtpv2.ie_be_context[j].ie_beqos.PL << " " << (int)gtp_data.gtpv2.ie_be_context[j].ie_beqos.PCI << std::endl;
                std::cout << "Bearer Context IE_QCI:- " << (int)gtp_data.gtpv2.ie_be_context[j].ie_beqos.QCI << std::endl;
                for (int i = 0; i < (swap_uint16(gtp_data.gtpv2.ie_be_context[j].ie_beqos.length)-2); i++) {
                    std::cout << "Bearer Context IE_Bearer QoS:- " << std::hex << (int)gtp_data.gtpv2.ie_be_context[j].ie_beqos.qos_data[i] << std::dec << std::endl;
                }   
                std::cout << "#######################################################################" << std::endl;
            }
            if (gtp_data.gtpv2.ie_be_context[j].ie_fteid_c_en | gtp_data.gtpv2.ie_be_context[j].ie_fteid_u_en) {
                for (int n =0; n < gtp_data.gtpv2.ie_be_context[j].ie_fteid_cnt; n++) {
                    std::cout << "Bearer Context IE_type is FTEID:- " << (int)gtp_data.gtpv2.ie_be_context[j].ie_fteid[n].type << std::endl;
                    std::cout << "Bearer Context IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_be_context[j].ie_fteid[n].length) << std::endl;
                    std::cout << "Bearer Context IE_IF_type:- " << (int)gtp_data.gtpv2.ie_be_context[j].ie_fteid[n].intf_typ << std::endl;
                    std::cout << "Bearer Context IE_V6, V4:- " << (int)gtp_data.gtpv2.ie_be_context[j].ie_fteid[n].v6 << " " << (int)gtp_data.gtpv2.ie_be_context[j].ie_fteid[n].v4 << std::endl;
                    std::cout << "Bearer Context IE_TEID:- " << std::hex << (unsigned int)gtp_data.gtpv2.ie_be_context[j].ie_fteid[n].teid << std::dec << std::endl;
                    if ((int)gtp_data.gtpv2.ie_be_context[j].ie_fteid[n].v4 == 1) {   //IPv4 addr
                        for (int i = 0; i < 4; i++) {
                            std::cout << "Bearer Context IE_TEID IPv4 Addr:- " << (int)gtp_data.gtpv2.ie_be_context[j].ie_fteid[n].data[i] << std::endl;
                        }
                    }
                    else if ((int)gtp_data.gtpv2.ie_be_context[j].ie_fteid[n].v6 == 1) {
                        if ((int)gtp_data.gtpv2.ie_be_context[j].ie_fteid[n].v4 == 1) {   //if has IPv4 addr
                            for (int i = 4; i < 20; i++) {
                                std::cout << "Bearer Context IE_TEID IPv6 Addr:- " << (int)gtp_data.gtpv2.ie_be_context[j].ie_fteid[n].data[i] << std::endl;
                            }
                        }
                        else {
                            for (int i = 0; i < 16; i++) {
                                std::cout << "Bearer Context IE_TEID IPv6 Addr:- " << (int)gtp_data.gtpv2.ie_be_context[j].ie_fteid[n].data[i] << std::endl;
                            }
                        }
                    }
                }
                std::cout << "#######################################################################" << std::endl;
            }
        }
    }
    if (gtp_data.gtpv2.ie_ue_time_zone_en) {
        std::cout << "IE_type is UE time zone:- " << (int)gtp_data.gtpv2.ie_ue_time_zone.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_ue_time_zone.length) << std::endl;
        std::cout << "IE_time_zone:- " << (int)gtp_data.gtpv2.ie_ue_time_zone.time_zone << std::endl;
        std::cout << "IE_day_light_saving:- " << (int)gtp_data.gtpv2.ie_ue_time_zone.dayalight_saving << std::endl;
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv2.ie_port_no_en) {
        for (int j =0; j < gtp_data.gtpv2.ie_port_no_cnt; j++) {
            std::cout << "IE_type is FTEID:- " << (int)gtp_data.gtpv2.ie_port_no[j].type << std::endl;
            std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_port_no[j].length) << std::endl;
            std::cout << "IE_Port_No:- " << swap_uint16(gtp_data.gtpv2.ie_port_no[j].port_no) << std::endl;
        }
    }
    if (gtp_data.gtpv2.ie_uli_timestamp_en) {
        std::cout << "IE_type is ULI time stamp:- " << (int)gtp_data.gtpv2.ie_uli_timestamp.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_uli_timestamp.length) << std::endl;
        std::cout << "IE_ULI_time_stamp_value:- " << gtp_data.gtpv2.ie_uli_timestamp.uli_timestamp_value << std::endl;
        std::cout << "#######################################################################" << std::endl;
    }
    if (gtp_data.gtpv2.ie_overload_ctrl_info_en) {
        for (int j =0; j < gtp_data.gtpv2.ie_overload_ctrl_info_cnt; j++) {
            if (gtp_data.gtpv2.ie_overload_ctrl_info[j].ie_apn_en) {
                std::cout << "overload ctrl info IE_type is APN:- " << (int)gtp_data.gtpv2.ie_overload_ctrl_info[j].ie_apn.type << std::endl;
                std::cout << "overload ctrl info IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_overload_ctrl_info[j].ie_apn.length) << std::endl;
                for (int i = 0; i < swap_uint16(gtp_data.gtpv2.ie_overload_ctrl_info[j].ie_apn.length); i++) {
                    std::cout << "overload ctrl info IE_APN_value:- " << std::hex << (int)gtp_data.gtpv2.ie_overload_ctrl_info[j].ie_apn.APN_value[i] << std::dec << std::endl;
                }   
                std::cout << "#######################################################################" << std::endl;
            } 
        }
    }
    if (gtp_data.gtpv2.ie_load_ctrl_info_en) {
        for (int j =0; j < gtp_data.gtpv2.ie_load_ctrl_info_cnt; j++) {
            if (gtp_data.gtpv2.ie_load_ctrl_info[j].ie_apn_reltcap_en) {
                std::cout << "load ctrl info IE_type is APN and relative capacity:- " << (int)gtp_data.gtpv2.ie_load_ctrl_info[j].ie_apn_reltcap.type << std::endl;
                std::cout << "load ctrl info IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_load_ctrl_info[j].ie_apn_reltcap.length) << std::endl;
                std::cout << "load ctrl info IE_rel_cap:- " << (int)gtp_data.gtpv2.ie_load_ctrl_info[j].ie_apn_reltcap.relt_cap << std::endl;
                std::cout << "load ctrl info IE_apn_len:- " << (int)gtp_data.gtpv2.ie_load_ctrl_info[j].ie_apn_reltcap.apn_len << std::endl;
                for (int i = 0; i < (swap_uint16(gtp_data.gtpv2.ie_load_ctrl_info[j].ie_apn_reltcap.length)-2); i++) {
                    std::cout << "load ctrl info IE_APN_value:- " << std::hex << (int)gtp_data.gtpv2.ie_load_ctrl_info[j].ie_apn_reltcap.APN_value[i] << std::dec << std::endl;
                }   
                std::cout << "#######################################################################" << std::endl;
            }
        }
    }
    if (gtp_data.gtpv2.ie_apn_reltcap_en) {
        std::cout << "IE_type is APN and relative capacity:- " << (int)gtp_data.gtpv2.ie_apn_reltcap.type << std::endl;
        std::cout << "IE_length:- " << swap_uint16(gtp_data.gtpv2.ie_apn_reltcap.length) << std::endl;
        std::cout << "IE_rel_cap:- " << (int)gtp_data.gtpv2.ie_apn_reltcap.relt_cap << std::endl;
        std::cout << "IE_apn_len:- " << (int)gtp_data.gtpv2.ie_apn_reltcap.apn_len << std::endl;
        for (int i = 0; i < (swap_uint16(gtp_data.gtpv2.ie_apn_reltcap.length)-2); i++) {
            std::cout << "IE_APN_value:- " << std::hex << (int)gtp_data.gtpv2.ie_apn_reltcap.APN_value[i] << std::dec << std::endl;
        }   
        std::cout << "#######################################################################" << std::endl;
    }

    std::cout << std::endl;
    std::cout << "#######################################################################" << std::endl;
    std::cout << "#######################################################################" << std::endl;
}

void Pq_Hw_GTPDecoder::AddHdr(packet &pkt) {   //, uint32_t pkt_id

    uint64_t Newlength = 0;
    
    std::vector<uint64_t>::iterator it;
    Newlength = (uint64_t) pkt.frame_set.size(); 
    it = pkt.frame_set.begin();
    it = pkt.frame_set.insert(it, Newlength); 
}