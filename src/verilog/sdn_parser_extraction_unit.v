//*********************************************************************************************************************
//
// Copyright(C) 2015 ParaQum Technologies Pvt Ltd.
// All rights reserved.
//
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF
// PARAQUM TECHNOLOGIES PVT LIMITED.
//
// This copy of the Source Code is intended for ParaQum's internal use only and is
// intended for view by persons duly authorized by the management of ParaQum. No
// part of this file may be reproduced or distributed in any form or by any
// means without the written approval of the Management of ParaQum.
//
// Paraqum Technologies (Pvt) Ltd.
// 106, 1st Floor, Bernards' Business Park,
// Dutugemunu Street,
// Kohuwala, Sri Lanka.
//
// ********************************************************************************************************************
//
// PROJECT      :   
// PRODUCT      :   
// FILE         :   
// AUTHOR       :  	Mahesh Dananjaya
// DESCRIPTION  :   Top Module of the GTP V1 Control
//
//
// ********************************************************************************************************************
//
// REVISIONS:
//
//  Date        Developer       Description
//  ----        ---------       -----------
//  
//
//
//
// ********************************************************************************************************************

`timescale 1ns / 1ps

module sdn_parser_extraction_unit
#(
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    parameter                                   EXT_UNIT_ID             = 0,
                        
    parameter                                   PRS_DATA_W              = 512,
    parameter                                   PRS_OFFSET_W            = 32,
    parameter                                   PRS_LENGTH_W            = 32,
    parameter                                   PRS_LOOKUP_W            = 32,
    parameter                                   PRS_COUNT_W             = 32,

    parameter                                   PRS_EXT_BUFF_DATA_W     = 4096,
    parameter                                   PRS_EXT_BUFF_ADDR_W     = 12,

    parameter                                   PRS_FIELD_BUFF_DATA_W   = 4096,
    parameter                                   PRS_FIELD_BUFF_ADDR_W   = 12,

    parameter                                   PRS_HEAD_ADDR_W         = 5,
    parameter                                   PRS_HEAD_FIELD_ADDR_W   = 5,  //These two felds are depending on othe rparameters, Therefore please check parameter before generate
                        
    parameter                                   PRS_OFFSET_BUFF_DATA_W  = (1<<(PRS_HEAD_ADDR_W+PRS_HEAD_FIELD_ADDR_W))*PRS_FIELD_BUFF_ADDR_W,
    parameter                                   PRS_OFFSET_BUFF_ADDR_W  = 32,
                            
    parameter                                   HEAD_LEN_W              = 0,
    parameter                                   HEAD_FIELD_LEN_W        = 10,
    parameter                                   HEAD_FIELD_W            = 16,
    parameter                                   NUM_OF_EXT_UNITS        = 32,
    parameter                                   HEAR_LOOKUP_DATA_W      = 64

)(
//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------
    
    input                                               clk,
    input                                               resetn,

    input                                               ext_unit_en_i,
    input                                               ext_unit_flush_i,

    input                                               ext_unit_header_valid_i,
    input           [PRS_COUNT_W-1:0]                   ext_unit_header_id_i,

   // input                                               ext_unit_hold_extdata_i,

    input                                               ext_unit_data_valid_i,
    input           [PRS_DATA_W-1:0]                    ext_unit_data_i,
    input           [PRS_COUNT_W-1:0]                   ext_unit_data_count_i,
    input           [PRS_OFFSET_W-1:0]                  ext_unit_word_addr_i,  //Can be derived from the counter

    input           [PRS_OFFSET_W-1:0]                  ext_unit_addr_start_i, //Absolute
    input           [HEAD_FIELD_W-1:0]                  ext_unit_field_info_i,
    output          [PRS_OFFSET_W-1:0]                  ext_unit_addr_finish_o,   

    //
    output          [PRS_OFFSET_W-1:0]                  ext_unit_field_offset_o, 
    output          [PRS_DATA_W-1:0]                    ext_unit_field_data_o,
    output          [PRS_LENGTH_W-1:0]                  ext_unit_field_len_o,  
    output                                              ext_unit_field_data_valid_o,

    input                                               ext_unit_hold_en_i,
    output                                              ext_unit_hold_en_o,
   //Field For Dynamic Length
    output                                              ext_unit_dylen_en_o,
    output          [PRS_LENGTH_W-1:0]                  ext_unit_dylen_o,

    input                                               ext_unit_dylen_en_i,
    input           [PRS_LENGTH_W-1:0]                  ext_unit_dylen_i,
   //LookUp Value
    output                                              ext_unit_lookup_en_o,
    output          [PRS_LOOKUP_W-1:0]                  ext_unit_lookup_o,

    input                                               ext_unit_lookup_en_i,
    input           [PRS_LOOKUP_W-1:0]                  ext_unit_lookup_i,

    output                                              ext_unit_ext_finished_o ,

////////////////////////////////////////////////////////////////////////////////////

    input   [PRS_FIELD_BUFF_DATA_W-1:0]                 parser_field_buff_data_i,
    input   [PRS_FIELD_BUFF_ADDR_W-1:0]                 parser_field_buff_len_i,

    output  [PRS_FIELD_BUFF_DATA_W-1:0]                 parser_field_buff_data_o,
    output  [PRS_FIELD_BUFF_ADDR_W-1:0]                 parser_field_buff_len_o//,
    

//Extraction Buffer Partial Output
    /*
    input   [PRS_EXT_BUFF_DATA_W-1:0]                   parser_ext_buff_data_i,
    input   [PRS_EXT_BUFF_ADDR_W-1:0]                   parser_ext_buff_len_i,

    output  [PRS_EXT_BUFF_DATA_W-1:0]                   parser_ext_buff_data_o,
    output  [PRS_EXT_BUFF_ADDR_W-1:0]                   parser_ext_buff_len_o//,
    */

    //Extraction Offset Buffer
    //Extraction Buffer Partial Output
    /*
    input   [PRS_OFFSET_BUFF_DATA_W-1:0]                parser_offset_buff_data_i,
    input   [PRS_OFFSET_BUFF_ADDR_W-1:0]                parser_offset_buff_len_i,

    output  [PRS_OFFSET_BUFF_DATA_W-1:0]                parser_offset_buff_data_o,
    output  [PRS_OFFSET_BUFF_ADDR_W-1:0]                parser_offset_buff_len_o
    */

    ///////////////////////////////////////////////////////////////////////////////////

);

//---------------------------------------------------------------------------------------------------------------------
// Global constant headers
//---------------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------
 
//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------
    reg   [PRS_LENGTH_W-1:0]                    ext_unit_data_count;
    reg                                         ext_unit_data_start_addr;    
    reg                                         ext_unit_hdr_started;
    reg                                         ext_unit_hdr_finished;
    wire                                        ext_unit_header_valid;
    
    wire                                        flag_enable;
    wire                                        flag_pkt_hdr_len;
    wire                                        flag_dyn_fld_len;
    wire                                        flag_lookup; 
    wire                                        flag_extract;                       
    wire                                        flag_dynamic;
    wire [HEAD_FIELD_LEN_W-1:0]                 field_length_original;
    wire [HEAD_FIELD_LEN_W-1:0]                 field_length;

    //Extraction Core
    wire  [PRS_DATA_W-1:0]                      ext_unit_field_data_shifted;
    wire                                        ext_unit_field_within_word;
    wire                                        ext_unit_err;

    wire [PRS_DATA_W-1:0]                       ext_unit_field_data;

    //reg [PRS_DATA_W-1:0]  
    wire                                        v_ext_length;
    wire [HEAD_FIELD_LEN_W-1:0]                 v_field_length; 
    wire                                        v_hold_on;
    wire [PRS_DATA_W-1:0]                       v_data;
    wire [PRS_OFFSET_W-1:0]                     v_offset;

    wire                                        data_underflow;
    wire                                        hold_pipeline;
    wire                                        data_overflow; 
    wire [PRS_DATA_W-1:0]                       ext_data;


    //FIELD LENGTH break for hold on conditions
    wire [PRS_OFFSET_W-1:0]                     v_ext_unit_field_offset;
    wire [PRS_OFFSET_W-1:0]                     v_ext_unit_addr_start;
    reg  [HEAD_FIELD_LEN_W-1:0]                 dynamic_len = 0;
    //Buffer Data
    reg                                         hold_en_reg;
    reg  [PRS_DATA_W-1:0]                       hold_data_reg;
    reg  [PRS_COUNT_W-1:0]                      hold_count_reg;

    reg  [PRS_DATA_W-1:0]                       hold_ext_data_for_future;

    wire [PRS_FIELD_BUFF_DATA_W-1:0]            ext_field_data_BUFF_WIDTH;
    wire [PRS_EXT_BUFF_DATA_W-1:0]              ext_ext_data_BUFF_WIDTH;


//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
   
    assign flag_enable                          = ext_unit_field_info_i [HEAD_FIELD_LEN_W+5 +: 1];
    assign flag_pkt_hdr_len                     = ext_unit_field_info_i [HEAD_FIELD_LEN_W+4 +: 1];
    assign flag_dyn_fld_len                     = ext_unit_field_info_i [HEAD_FIELD_LEN_W+3 +: 1];
    assign flag_lookup                          = ext_unit_field_info_i [HEAD_FIELD_LEN_W+2 +: 1];
    assign flag_extract                         = ext_unit_field_info_i [HEAD_FIELD_LEN_W+1 +: 1];
    assign flag_dynamic                         = ext_unit_field_info_i [HEAD_FIELD_LEN_W   +: 1];
    
  /*  assign flag_enable                          = ext_unit_field_info_i [HEAD_FIELD_LEN_W+5];
    assign flag_pkt_hdr_len                     = ext_unit_field_info_i [HEAD_FIELD_LEN_W+4];
    assign flag_dyn_fld_len                     = ext_unit_field_info_i [HEAD_FIELD_LEN_W+3];
    assign flag_lookup                          = ext_unit_field_info_i [HEAD_FIELD_LEN_W+2];
    assign flag_extract                         = ext_unit_field_info_i [HEAD_FIELD_LEN_W+1];
    assign flag_dynamic                         = ext_unit_field_info_i [HEAD_FIELD_LEN_W  ];
   */ 
    assign field_length_original                = ext_unit_field_info_i [0   +: HEAD_FIELD_LEN_W];

    assign field_length                         = (flag_dynamic)? ext_unit_dylen_i : field_length_original;
    //assign  

    assign ext_unit_field_len_o                 = ext_unit_field_info_i [0   +: HEAD_FIELD_LEN_W];

    assign ext_unit_lookup_o                    = (flag_lookup)? ext_data : ((ext_unit_lookup_en_i) ? ext_unit_lookup_i : 0);
    assign ext_unit_lookup_en_o                 = (flag_lookup)? 1 : ((ext_unit_lookup_en_i) ? 1 : 0);

    assign ext_unit_dylen_o                     = (flag_dyn_fld_len)? ext_data: ((ext_unit_dylen_en_i)? ((flag_dynamic)?0:ext_unit_dylen_i):0);
    assign ext_unit_dylen_en_o                  = (flag_dyn_fld_len)? ext_data: ((ext_unit_dylen_en_i)? ((flag_dynamic)?0:ext_unit_dylen_i):0);

    assign data_underflow                       = ((ext_unit_addr_start_i + field_length -1) <= (ext_unit_data_count_i*PRS_DATA_W -1)) ? 1:0;
    assign hold_pipeline                        = ~data_underflow;
    assign data_overflow                        = ~data_underflow;

    assign ext_unit_field_offset_o              = ext_unit_addr_start_i;
    assign ext_unit_addr_finish_o               = (flag_enable) ? (ext_unit_addr_start_i + field_length) : ext_unit_addr_start_i;

    //  ((hold_en_reg)?: 0)
//Should be protected from
    assign v_ext_length                         = (ext_unit_data_count_i * PRS_DATA_W) - ext_unit_addr_start_i ;
    assign v_field_length                       = field_length - v_ext_length ; 
    assign v_ext_unit_addr_start                = ext_unit_data_count_i * PRS_DATA_W;

//Need some trim for 
    assign ext_unit_field_data_shifted          = (data_underflow)? ((hold_en_reg) ? ((ext_unit_data_i >> (PRS_DATA_W - (ext_unit_addr_finish_o % PRS_DATA_W) /*-1 */))) : (ext_unit_data_i >> (PRS_DATA_W - (ext_unit_addr_finish_o % PRS_DATA_W) /*-1 */))  ): ext_unit_data_i ;
    assign ext_unit_field_data                  = (data_underflow)? ((hold_en_reg) ? (ext_unit_field_data_shifted & ((1 << v_field_length)-1)) :(ext_unit_field_data_shifted & ((1 << field_length)-1)) ): ((ext_unit_field_data_shifted & ((1 << v_ext_length)-1)) << v_field_length); 
    assign ext_unit_field_data_o                = (data_underflow)? ((hold_en_reg) ? ext_unit_field_data & hold_data_reg :ext_unit_field_data): 0;



    assign ext_data                             = (data_underflow)? ((hold_en_reg) ? ext_unit_field_data & hold_data_reg :ext_unit_field_data): 0;
    assign ext_unit_field_data_valid_o          = (data_underflow)? ((hold_en_reg) ? 1'b1:1'b1): 1'b0; 
    assign ext_unit_ext_finished_o              = ext_unit_field_data_valid_o;

    //Check the flag

 
    //At OverFlow Stages
    //Buffer previous Stages
    assign v_hold_on                            = (data_overflow)? 1 : 0; 
    assign v_data                               = (data_overflow)? (ext_unit_field_data_shifted & ((1 << v_ext_length)-1)):0;


    assign ext_unit_hold_en_o                   = data_overflow;


    assign ext_field_data_BUFF_WIDTH            = {{(PRS_FIELD_BUFF_DATA_W-PRS_DATA_W){1'b0}}, ext_unit_field_data_o};
   /*
    assign ext_ext_data_BUFF_WIDTH              = {{(PRS_EXT_BUFF_DATA_W-PRS_DATA_W){1'b0}}, ext_unit_field_data_o};

    assign parser_ext_buff_data_o              = (flag_enable && flag_extract )? ((ext_unit_field_data_valid_o)?  ((ext_ext_data_BUFF_WIDTH << (PRS_EXT_BUFF_DATA_W-parser_field_buff_len_i-field_length)) | parser_ext_buff_data_i)  : parser_ext_buff_data_i) : parser_ext_buff_data_i; 
    assign parser_ext_buff_len_o               = (flag_enable && flag_extract)? ((ext_unit_field_data_valid_o)? (parser_ext_buff_len_i + field_length) : parser_ext_buff_len_i) : parser_ext_buff_len_i;
*/
    assign parser_field_buff_data_o            = (flag_enable)? ((ext_unit_field_data_valid_o)?   ((ext_field_data_BUFF_WIDTH << (PRS_EXT_BUFF_DATA_W-parser_field_buff_len_i-field_length)) | parser_field_buff_data_i)  : parser_field_buff_data_i) : parser_field_buff_data_i; 
    assign parser_field_buff_len_o             = (flag_enable)? ((ext_unit_field_data_valid_o)? (parser_field_buff_len_i + field_length) : parser_field_buff_len_i) : parser_field_buff_len_i;


//Make the Address First
//need
  // assign parser_offset_buff_data_o [(ext_unit_data_count_i+EXT_UNIT_ID)*PRS_FIELD_BUFF_ADDR_W +: PRS_FIELD_BUFF_ADDR_W]  = (flag_enable)? ((ext_unit_field_data_valid_o) ? ext_unit_addr_start_i : 0) : 0;
 //  assign parser_offset_buff_data_o          =  (flag_enable)? ((ext_unit_field_data_valid_o) ? ((ext_unit_addr_start_i << (1)) | parser_offset_buff_data_i): parser_offset_buff_data_i) : parser_offset_buff_data_i;
always@(posedge clk)begin 
    if(!resetn)begin
        //Reset Logic
    end
    else begin
        if(hold_pipeline)begin
            hold_en_reg     <= v_hold_on;
            //hold_data_reg   <= v_data; 
            hold_data_reg   <= ext_unit_field_data;
            hold_count_reg  <= ext_unit_data_count_i;
        end
        else begin
            hold_en_reg     <= 1'b0;
            hold_data_reg   <= 0;
            hold_count_reg  <= 0;

        end
    end
end

always@(posedge clk)begin

    if(!resetn)begin
        if(ext_unit_field_data_valid_o)
                hold_ext_data_for_future <= ext_unit_field_data_o;
    end
    else begin

    end
end

endmodule
