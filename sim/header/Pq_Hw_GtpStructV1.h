/*
 * Pq_Hw_GtpStructV1.h
 *
 * created:- 2016/05/04
 * author:- Indunil Wanigasooriya
*/ 

#ifndef HEADER_PQ_HW_GTPSTRUCTV1_H_
#define HEADER_PQ_HW_GTPSTRUCTV1_H_

#define ALLINGED

struct IE_CAUSE {
    uint8_t type;
    //uint8_t cause_value : 6, rejt_bit : 1, resp_bit : 1;
    uint8_t cause_value;
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE_IMSI {
    uint8_t type;
    uint64_t IMSI;
    //uint8_t IMSI[8];
    //uint16_t IMSI[4];
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE_TEID {
    uint8_t type;
    uint32_t TEID;
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

/*struct IE_TEID_C {
    uint8_t type;
    uint32_t TEID;
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif*/

struct IE_TEARDOWN_IND {
    uint8_t type;
    uint8_t spare : 7, teardown_ind : 1;
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE_NSAPI {
    uint8_t type;
    uint8_t NSAPI : 4, reserved : 4;
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE_EndUserAddr {  //variable length
    uint8_t type;
    uint16_t length;
    uint8_t PDP_typ : 4, spare : 4;
    uint8_t PDP_typ_number;
    uint8_t PDP_addr[20];   //IPv4 =4, IPv6 = 16
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE_APN {         //variable length
    uint8_t type;
    uint16_t length;
    uint8_t APN_value[20];   //???????
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE_GSN{          //variable length 
    uint8_t type;
    uint16_t length;
    uint8_t GSN_address[20];  //???????
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE_MSISDN {      //variable length
    uint8_t type;
    uint16_t length;
    uint8_t MSISDN[20];    //????????????????????
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE_QOS {         //variable length
    uint8_t type;
    uint16_t length;
    uint8_t prority;
    uint8_t qos_data[20];
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE_RAT {
    uint8_t type;
    uint16_t length;
    uint8_t RAT_typ;
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE_ULI {         //variable length
    uint8_t type;
    uint16_t length;
    uint8_t geo_loc_typ;
    uint8_t geo_loc[20];   //?????????????????
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE_MS_TIME_ZONE {      
    uint8_t type;
    uint16_t length;
    uint8_t time_zone;
    uint8_t dayalight_saving : 1, spare : 7;   
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE_IMEI {
    uint8_t type;
    uint16_t length;
    uint64_t IMEI;
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

struct IE_DTF {         //variable length, variable is fixed at the peresent, future can be varied
    uint8_t type;
    uint16_t length;
    uint8_t DTI : 1, GCSI : 1, EI : 1, spare : 5;
#ifdef ALLINGED
}__attribute__((__packed__));
#else
};
#endif

#endif