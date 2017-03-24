/*
 * Pq_Hw_GtpStructV2.h
 *
 * created:- 2016/05/04
 * author:- Indunil Wanigasooriya
*/ 

#ifndef HEADER_PQ_HW_GTPSTRUCTV2_H_
#define HEADER_PQ_HW_GTPSTRUCTV2_H_

#define ALLINGED

struct IE1_IMSI {
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    //uint8_t IMSI[20];
    uint64_t IMSI;
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_CAUSE {
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    uint8_t cause_value;
    uint8_t CS : 1, BCE : 1, PCE : 1, spare1 : 5;
    uint8_t data[10];
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_APN {         
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    uint8_t APN_value[40];   
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_AMBR {         
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    uint32_t uplink; 
    uint32_t downlink; 
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_EBI {         
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    uint8_t EBI_ID : 4, spare1 : 4; 
    uint8_t data[20]; 
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_IPADDR{          
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    uint8_t ip_address[20];  
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_IMEI {
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    //uint8_t IMEI[20];
    uint64_t IMEI;
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_MSISDN {      
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    uint8_t MSISDN[20];    
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_BEQOS {         
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    uint8_t PVI : 1, spare2 : 1, PL : 4, PCI : 1, spare1 : 1;
    uint8_t QCI; 
    uint8_t qos_data[20];
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_FLQOS {         
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    uint8_t QCI; 
    uint8_t qos_data[20];
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_RAT {
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    uint8_t RAT_typ;
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_ULI {         
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    uint8_t CGI : 1, SAI : 1, RAI : 1, TAI : 1, ECGI : 1, LAI : 1, spare1 : 2;  //data is on right to left direction
    uint8_t geo_loc[50];   
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_FTEID {    //can hv many
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    uint8_t intf_typ : 6, v6 : 1, v4 : 1;
    uint32_t teid;
    uint8_t data[20];
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_UE_TIME_ZONE {      
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    uint8_t time_zone;
    uint8_t dayalight_saving : 2, spare1 : 6;   
    uint8_t data[20];
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_PORT_NO {      
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    uint16_t port_no;  
    uint8_t data[20];
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_ULI_TIMESTAMP {         
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    uint32_t uli_timestamp_value;
    uint8_t data[20];   
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_APN_RELTCAP {         
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    uint8_t relt_cap;
    uint8_t apn_len;
    uint8_t APN_value[20];   
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_BEARER_CONTEXT {         //grouped IE
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    
    ////////////////////////////
    uint8_t ie_fteid_cnt;

    uint8_t ie_fteid_c_index;
    uint8_t ie_fteid_u_index;

    bool ie_cause_en;
    bool ie_ebi_en;
    bool ie_beqos_en;
    bool ie_fteid_c_en;
    bool ie_fteid_u_en; 

    IE1_CAUSE    ie_cause;
    IE1_EBI      ie_ebi;
    IE1_BEQOS    ie_beqos;
    IE1_FTEID    ie_fteid[8]; 

#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_OVERLOAD_CTRL_INFO {         //grouped IE
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    
    bool ie_apn_en;
    IE1_APN  ie_apn; 

#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE1_LOAD_CTRL_INFO {         //grouped IE
    uint8_t type;
    uint16_t length;
    uint8_t instance : 4, spare : 4;
    
    bool ie_apn_reltcap_en;
    IE1_APN_RELTCAP  ie_apn_reltcap;

#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif


#endif