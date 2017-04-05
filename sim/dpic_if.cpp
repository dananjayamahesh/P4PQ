#include "dpic_if.h"

#include "header/AllHeaders.h"
#include "san/headers/Parser.h"
#include "san/headers/Parser1.h"

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <queue>


#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <queue>
#include <stdlib.h> 
#include <stdio.h>
#include <string.h>


PacketReader *pkt_reader;                                    
PktPreProcessor *pkt_preprocessor;
ActConfProg *act_conf_programmer;
CamConfProg *cam_conf_programmer;
Parser *myparser;
//Pq_Hw_GTPDecoder *gtp_decoder;

bool rd_pcap_file = false;
unsigned int rdpkt_count = 1;   //start from 1
//myparser    =   new Parser();

//std::queue<gtp_decoder_data> gtp_decoder_resultq;
std::queue<packet> pktq;

DPI_LINK_DECL DPI_DLLESPEC
void
svReadPkts(
    unsigned int svCount,
    unsigned int* svError)
{
    int i_ret;
    *svError = 0;
    //gtp_decoder_data gtpdecoder;                        //struct Pq_Hw_GTPDecoder.h to store extraction data

    //act_conf_programmer = new ActConfProg();
    //cout << "Start Program"<< endl;
    //act_conf_programmer->Prog();


    if (!rd_pcap_file) {
        pkt_reader = new PacketReader();
        pkt_preprocessor = new PktPreProcessor();

        //gtp_decoder = new Pq_Hw_GTPDecoder();

        i_ret = pkt_reader->open_file("../sim/san/packetdumps/ICMP_across_dot1q.cap"); //name of the pcap file
        if (i_ret != SUCCESS) {
            *svError = 1;
            return;
        }
        else {
            rd_pcap_file = true;
            *svError = 0;
        }
    }

    for (uint i = 0; i < (uint) svCount; i++) {
        rd_pkt rp;                                      //struct PacketReader.h
        packet p;                                       //struct NetworkPkts.h ,vector
        
        pkt_reader->GetNextPacket(rp);                  //read the next packet in the pcap file
        i_ret = pkt_preprocessor->ConvertPkt(rp, p);    //convert according to we needed(as hardwear), and packet is stored in the vector packet
        if (i_ret != SUCCESS) {
            *svError = 1;
            return;
        }

        //gtp_decoder->proce_frame(p, gtpdecoder);
        //gtp_decoder_resultq.push(gtpdecoder);

        ////add modification to the p
        //gtp_decoder->AddHdr(p);
        
        rdpkt_count++;                                      //pkt_id = count of the packet (number)
        pktq.push(p);                                       //push the vector packet into the queue
    }
}

DPI_LINK_DECL DPI_DLLESPEC
void
svGetPktCount(
    unsigned int* svPktCount,
    unsigned int* svError)
{
    if (rd_pcap_file){                  //execute after reading a packet from svReadPkts
        *svPktCount = pktq.size();
        *svError = 0;
    }
    else{
        *svPktCount = 0;
        *svError = 1;
    }
}

DPI_LINK_DECL DPI_DLLESPEC
void
svGetPktFrame(
    unsigned int svFrameAddr,
    uint64_t* svFrame,
    unsigned int* svPktLen,
    unsigned int* svError)
{
    if (svFrameAddr > (pktq.front().frame_set.size()+1) ) {      //if addr is greater than packet size
        *svError = 1;
        *svPktLen = 0;
        *svFrame = 0;
    }
    else if(svFrameAddr==0){
        *svError = 0;
        *svPktLen = pktq.front().frame_set.size() +1;
         *svFrame = pktq.front().frame_set.size();

    }
    else{
        *svError = 0;
        *svPktLen = pktq.front().frame_set.size() +1;
        *svFrame = pktq.front().frame_set[svFrameAddr-1];
    }

    if (svFrameAddr == (pktq.front().frame_set.size() /* -1*/)) {   //after read the packet pop that
        pktq.pop();
    }
}

DPI_LINK_DECL DPI_DLLESPEC
void
svActConf(
    unsigned int svActCount,
    unsigned int* svActError)
{

    //act_conf_programmer = new ActConfProg();
    //cout << "Start Program"<< endl;
    //act_conf_programmer.Prog();

        svActCount = 0;
        *svActError = 0;
        act_conf_programmer = new ActConfProg();


}


DPI_LINK_DECL DPI_DLLESPEC
void
svGetPktHead(
    unsigned int svHeadAddr,
    uint64_t* svHead,
    unsigned int* svHeadLen,
    unsigned int* svHeadError)
{

    *svHeadError = 0;
    *svHeadLen = 2;
    *svHead = 1;    
}


DPI_LINK_DECL DPI_DLLESPEC
void
svGetNumHeads(
    unsigned int* svNum
)
{
   *svNum = act_conf_programmer->GetNumHeads();
}

 DPI_LINK_DECL DPI_DLLESPEC
void
svGetHeadWord(
    unsigned int* svHeadWord)
{
    *svHeadWord = act_conf_programmer->GetNextHeadWord();
}


DPI_LINK_DECL DPI_DLLESPEC
void
svCamConf(
    unsigned int svCamCount,
    unsigned int* svCamError)
{

    //act_conf_programmer = new ActConfProg();
    //cout << "Start Program"<< endl;
    //act_conf_programmer.Prog();

        svCamCount = 0;
        *svCamError = 0;
        cam_conf_programmer = new CamConfProg();
}

DPI_LINK_DECL DPI_DLLESPEC
void
svGetNumCamEntries(
    unsigned int* svNum
)
{
   *svNum = cam_conf_programmer->GetNumHeads();
}

DPI_LINK_DECL DPI_DLLESPEC
void
svGetCamEntry(
    uint64_t* svCamEntry
)
{
    *svCamEntry = cam_conf_programmer->GetNextHeadWord();
}

DPI_LINK_DECL DPI_DLLESPEC
void
svRunParser()
{
    myparser->run();   
}

DPI_LINK_DECL DPI_DLLESPEC
void
svGet_field_buffer_word(
    uint64_t* field_buffer_word
)
{
    *field_buffer_word = myparser->get_field_buffer_word();
}

DPI_LINK_DECL DPI_DLLESPEC
void
svGet_offset_queue_word(
    uint64_t* offset_queue_word
)
{
    *offset_queue_word = myparser->get_offset_queue_word();
}

DPI_LINK_DECL DPI_DLLESPEC
void
svGet_ext_queue_word(
    uint64_t* ext_queue_word
)
{
    *ext_queue_word = myparser->get_ext_queue_word();
}

DPI_LINK_DECL DPI_DLLESPEC
void
svGet_hdr_Seq_queue_word(
    uint64_t* hdr_Seq_queue_word
)
{
    *hdr_Seq_queue_word = myparser->get_hdr_Seq_queue_word();
}
