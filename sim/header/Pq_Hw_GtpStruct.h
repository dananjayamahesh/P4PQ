/*
 * Pq_Hw_GtpStruct.h
 *
 * created:- 2016/05/04
 * author:- Indunil Wanigasooriya
*/ 

#ifndef HEADER_PQ_HW_GTPSTRUCT_H_
#define HEADER_PQ_HW_GTPSTRUCT_H_

#include "Pq_Hw_GtpStructV1.h"
#include "Pq_Hw_GtpStructV2.h"

#define ALLINGED

struct gtp_header { //only mandotary field, 1st 8 octet
    //3rd bits at flag :- GTPv1 - protocol, GTPv2 - pyggibacking
    //4th bits at flag :- GTPv1 - reserved, GTPv2 - TEID
    //GTPv2, TEDI is optional so teid can contain the seq no as well
    uint8_t     PN : 1, S : 1, E : 1, teid_en : 1, pro_piggy : 1, version : 3;
    uint8_t     msg_typ;
    uint16_t    msg_length;
    uint32_t    teid;
    uint16_t    seq_no;
    uint8_t     seq_no_rem;
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct gtp_v1 {
    uint8_t ie_gsn_cnt;
    uint8_t ie_uli_cnt;
    //*************************************
    uint16_t length;        //length of all the trasmit data, based on the data has set the flag
    uint32_t reservd :13, fapn :1, fgsnip :3, fmstime :1, fqos :1, fuli :3, frat :1, fmsisdn :1, fimsi :1, fimei :1, fue :2, fteidu :1, fteidc :1, fcause :1, fseq :1;         //header of trasmit data, based on the data has set the flag

    bool ie_cause_en;
    bool ie_imsi_en;
    bool ie_teid_d_en;
    bool ie_teid_c_en;
    bool ie_teardown_ind_en;
    bool ie_nsapi_en;
    bool ie_linked_nsapi_en;  
    bool ie_enduseraddr_en;
    bool ie_apn_en;

    bool ie_gsn_en;
    //bool ie_gsn_c_en;
    //bool ie_gsn_d_en;
    //bool ie_alternative_gsn_c_en;
    //bool ie_alternative_gsn_d_en;
    bool ie_msisdn_en;
    bool ie_qos_en;
    bool ie_rat_en;
    bool ie_uli_en;
    bool ie_ms_time_zone_en;
    bool ie_imei_en;
    bool ie_dtf_en;

    IE_CAUSE        ie_cause;
    IE_IMSI         ie_imsi;
    IE_TEID         ie_teid_d;
    IE_TEID         ie_teid_c;
    IE_TEARDOWN_IND ie_teardown_ind;
    IE_NSAPI        ie_nsapi;
    IE_NSAPI        ie_linked_nsapi;
    IE_EndUserAddr  ie_enduseraddr;
    IE_APN          ie_apn;

    IE_GSN          ie_gsn[4];           
    //IE_GSN          ie_gsn_c;           
    //IE_GSN          ie_gsn_d;
    //IE_GSN          ie_alternative_gsn_c;
    //IE_GSN          ie_alternative_gsn_d;
    IE_MSISDN       ie_msisdn;
    IE_QOS          ie_qos;
    IE_RAT          ie_rat;
    IE_ULI          ie_uli[3];
    IE_MS_TIME_ZONE ie_ms_time_zone;
    IE_IMEI         ie_imei;
    IE_DTF          ie_dtf;

#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif


//////////////////
//multiple instance of the IE for same msg as 
//uint8_t ie_gsn_cnt;
//uint8_t ie_uli_cnt;

struct gtp_v2 {
    uint8_t ie_ipaddr_cnt;
    uint8_t ie_fteid_cnt;
    uint8_t ie_be_context_cnt;
    uint8_t ie_port_no_cnt;
    uint8_t ie_overload_ctrl_info_cnt;
    uint8_t ie_load_ctrl_info_cnt;

    uint8_t ie_ipaddr_index;
    uint8_t ie_fteid_c_index;
    uint8_t ie_fteid_u_index;
    uint8_t ie_be_context_cause_index;
    uint8_t ie_be_context_ebi_index;
    uint8_t ie_be_context_bqos_index;
    uint8_t ie_be_context_teidc_index;
    uint8_t ie_be_context_teidu_index;
    
    //*************************************
    uint16_t length;        //length of all the trasmit data, based on the data has set the flag
    uint32_t reservd :7, fapn :1, fteidipuv6 :1, fteidipuv4 :1, fteidipcv6 :1, fteidipcv4 :1, fmstime :1, fambr:1, febi:1, fbqos :1, fuli :6, frat :1, fmsisdn :1, fimsi :1, fimei :1, fipaddr :2, fteidu :1, fteidc :1, fcause :1, fseq :1;         //header of trasmit data, based on the data has set the flag

    bool ie_imsi_en;
    bool ie_cause_en;
    bool ie_apn_en;
    bool ie_ambr_en;
    bool ie_ebi_en;                 //has many if bearer resource cmd (68) is used
    bool ie_ipaddr_en;              //many  ???? i don't think there can be many
    bool ie_imei_en;
    bool ie_msisdn_en;
    bool ie_beqos_en;
    bool ie_flqos_en;
    bool ie_rat_en;
    bool ie_uli_en;
    bool ie_fteid_c_en;               
    bool ie_fteid_u_en;               
    bool ie_be_context_en;          //many
    bool ie_ue_time_zone_en;
    bool ie_port_no_en;             //many
    bool ie_uli_timestamp_en;
    bool ie_overload_ctrl_info_en;  //many
    bool ie_load_ctrl_info_en;      //many
    bool ie_apn_reltcap_en;

    IE1_IMSI                 ie_imsi;
    IE1_CAUSE                ie_cause;
    IE1_APN                  ie_apn;
    IE1_AMBR                 ie_ambr;
    IE1_EBI                  ie_ebi;
    IE1_IPADDR               ie_ipaddr[5];
    IE1_IMEI                 ie_imei;
    IE1_MSISDN               ie_msisdn;
    IE1_BEQOS                ie_beqos;
    IE1_FLQOS                ie_flqos;
    IE1_RAT                  ie_rat;
    IE1_ULI                  ie_uli; 
    IE1_FTEID                ie_fteid[8];           //???? how much
    IE1_BEARER_CONTEXT       ie_be_context[2];  //created and removed
    IE1_UE_TIME_ZONE         ie_ue_time_zone;
    IE1_PORT_NO              ie_port_no[5];       
    IE1_ULI_TIMESTAMP        ie_uli_timestamp;
    IE1_OVERLOAD_CTRL_INFO   ie_overload_ctrl_info[5];  
    IE1_LOAD_CTRL_INFO       ie_load_ctrl_info[5];
    IE1_APN_RELTCAP          ie_apn_reltcap;

#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct gtp_v1u {
    uint64_t data[4];
    uint16_t byte_offset;       //only for gtpv1-U
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct gtp_decoder_data {
    bool gtp_en;    //used this
    uint8_t ctrl_or_data;   //based on the udp port, if ctrl->ctrl_or_data = 1, if user->ctrl_or_data = 2
    
    gtp_header      gtp_hdr;
    gtp_v1          gtpv1;
    gtp_v2          gtpv2;

    gtp_v1u         gtpv1u;

#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

#endif