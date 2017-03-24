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
// FILE         :   gtp_v1_c_top.v
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

module sdn_parser_extraction_unit_sync
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
                            
    parameter                                   HEAD_LEN_W              = 0,
    parameter                                   HEAD_FIELD_LEN_W        = 9,
    parameter                                   HEAD_FIELD_W            = 32,
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

    input                                               ext_unit_header_start_i,
    output                                              ext_unit_header_finish_i,
    input                                               ext_unit_header_valid_i,
    input           [PRS_COUNT_W-1:0]                   ext_unit_header_id_i,

    input                                               ext_unit_hold_extdata_i,

    input                                               ext_unit_word_data_valid_i,
    input           [PRS_DATA_W-1:0]                    ext_unit_word_data_i,
    input           [PRS_COUNT_W-1:0]                   ext_unit_word_data_count_i,
    input           [PRS_OFFSET_W-1:0]                  ext_unit_word_addr_i,  //Can be derived from the counter

    input           [PRS_OFFSET_W-1:0]                  ext_unit_addr_start_i, //Absolute    
    output reg      [PRS_OFFSET_W-1:0]                  ext_unit_addr_finish_o,  
    input           [HEAD_FIELD_W-1:0]                  ext_unit_field_info_i,  

    output reg      [PRS_OFFSET_W-1:0]                  ext_unit_field_offset_o,   

    input                                               ext_unit_hold_en_i,
    output reg                                          ext_unit_hold_en_o,
    output reg                                          ext_unit_hold_pipe_en_o,

   //Tuples Extracted for Field Buffer
    output reg      [PRS_DATA_W-1:0]                    ext_unit_field_data_o,
    output          [PRS_LENGTH_W-1:0]                  ext_unit_field_len_o,

   //Field For Dynamic Length
    output reg                                          ext_unit_dylen_en_o,
    output reg      [PRS_LENGTH_W-1:0]                  ext_unit_dylen_o,

    input                                               ext_unit_dylen_en_i,
    input           [PRS_LENGTH_W-1:0]                  ext_unit_dylen_i,

   //LookUp Value
    output  reg                                         ext_unit_lookup_en_o,
    output  reg     [PRS_LOOKUP_W-1:0]                  ext_unit_lookup_o,

    input                                               ext_unit_lookup_en_i,
    input           [PRS_LOOKUP_W-1:0]                  ext_unit_lookup_i

);

//---------------------------------------------------------------------------------------------------------------------
// Global constant headers
//---------------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------
    localparam                                  STATE_FETCH_FLIP_00 = 0;       
    localparam                                  STATE_FETCH_FLIP_01 = 1; 
    localparam                                  STATE_FETCH_FLIP_10 = 2; 
    localparam                                  STATE_FETCH_FLIP_11 = 3;  
    //  WORD FETCH - ACTION FLIP  
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
    reg  [PRS_DATA_W-1:0]                       ext_unit_field_data_shifted;
    wire                                        ext_unit_field_within_word;
    wire                                        ext_unit_err;

    //reg [PRS_DATA_W-1:0]  
    reg                                         v_ext_length;
    reg [HEAD_FIELD_LEN_W-1:0]                  v_field_length; 
    reg                                         v_hold_on;
    reg [PRS_DATA_W-1:0]                        v_data;
    reg [PRS_OFFSET_W-1:0]                      v_offset;

    //FIELD LENGTH break for hold on conditions
    reg [PRS_OFFSET_W-1:0]                      v_ext_unit_field_offset;
    reg [PRS_OFFSET_W-1:0]                      v_ext_unit_addr_start;


    reg [HEAD_FIELD_LEN_W-1:0]                  dynamic_len = 0;

//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
   
    assign flag_enable                          = ext_unit_field_info_i [HEAD_FIELD_LEN_W+5 +: 1];
    assign flag_pkt_hdr_len                     = ext_unit_field_info_i [HEAD_FIELD_LEN_W+4 +: 1];
    assign flag_dyn_fld_len                     = ext_unit_field_info_i [HEAD_FIELD_LEN_W+3 +: 1];
    assign flag_lookup                          = ext_unit_field_info_i [HEAD_FIELD_LEN_W+2 +: 1];
    assign flag_extract                         = ext_unit_field_info_i [HEAD_FIELD_LEN_W+1 +: 1];
    assign flag_dynamic                         = ext_unit_field_info_i [HEAD_FIELD_LEN_W   +: 1];
    assign field_length_original                = ext_unit_field_info_i [0   +: HEAD_FIELD_LEN_W];

    assign field_length                         = (flag_dynamic)?ext_unit_dylen_i:field_length_original;
    
     
    //assign ext_unit_addr_finish_o               = (flag_enable)? ext_unit_addr_start_i + field_length :ext_unit_addr_start_i;
    //assign ext_unit_field_within_word         = ((ext_unit_addr_start_i/PRS_DATA_W) == (ext_unit_addr_start_i/PRS_DATA_W))  && ((ext_unit_addr_start_i/PRS_DATA_W) == ext_unit_data_count_i)
    //assign ext_unit_field_offset_o            = ext_unit_addr_start_i;    
    assign ext_unit_field_len_o    = ext_unit_field_info_i [0   +: HEAD_FIELD_LEN_W];

    always@(posedge clk)begin
        if(!resetn)begin

        end
        else begin

            if()

        end
    end 


endmodule
