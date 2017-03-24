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

module sdn_parser_extraction_core_test
#(
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    parameter           PRS_DATA_W              = 512,
    parameter           PRS_OFFSET_W            = 32,
    parameter           PRS_LENGTH_W            = 32,
    parameter           PRS_LOOKUP_W            = 32,
    parameter           PRS_COUNT_W             = 32,

    parameter           ACTION_RAM_DATA_W       = 512,
    parameter           ACTION_RAM_ADDR_W       = 10,
    
    parameter           HEAD_LEN_W              = 0,
    parameter           HEAD_FIELD_LEN_W        = 9,
    parameter           HEAD_FIELD_W            = 32,
    parameter           NUM_OF_EXT_UNITS        = 1,
    parameter           HEAD_LOOKUP_DATA_W      = 64

)(
//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------
    
    input                                       clk,
    input                                       resetn,

    input                                       ext_core_head_valid,

    input   [PRS_DATA_W-1:0]                    ext_core_data_word_i,
    input                                       ext_core_data_valid_i,

    input   [PRS_OFFSET_W-1:0]                  ext_core_start_addr_i,
    output  [PRS_OFFSET_W-1:0]                  ext_core_finish_addr_o,

    input   [ACTION_RAM_DATA_W-1:0]             ext_core_action_field_i, 
    input                                       ext_core_action_valid_i, 

    input   [PRS_LOOKUP_W-1:0]                  ext_core_lookup_value_i,
    input                                       ext_core_lookup_valid_i,

    output  [PRS_LOOKUP_W-1:0]                  ext_core_lookup_value_o,
    output                                      ext_core_lookup_valid_o, 

    input   [PRS_LENGTH_W-1:0]                  ext_core_dylen_value_i,
    input                                       ext_core_dylen_valid_i,

    output  [PRS_LENGTH_W-1:0]                  ext_core_dylen_value_o,
    output                                      ext_core_dylen_valid_o,

    output                                      ext_core_hold_en_o,
    output                                      ext_core_head_finished_o
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
    reg                                                 ext_hold_pipeline_en = 0;
    reg                                                 ext_hold_pkt_data_en = 0;
    reg                                                 ext_pkt_started      = 0;
    reg                                                 ext_pkt_finished     = 0;

    wire      [NUM_OF_EXT_UNITS-1:1]                    ext_start_address;
    wire      [NUM_OF_EXT_UNITS-1:1]                    ext_finish_address;
    wire      [NUM_OF_EXT_UNITS-1:1]                    ext_field_offset;   
    wire      [NUM_OF_EXT_UNITS-1:1]                    ext_field_hold_en;  
    wire      [NUM_OF_EXT_UNITS-1:1]                    ext_field_lookup_en;  
    wire      [NUM_OF_EXT_UNITS-1:1]                    ext_field_dylen_en;
    wire      [NUM_OF_EXT_UNITS-1:1]                    ext_unit_en;         


    wire                                                ext_en;
    wire                                                ext_head_valid;
    wire      [PRS_COUNT_W-1:0]                         ext_header_id;

    //Flip ?
    wire                                                ext_unit_flip;
    wire                                                ext_unit_hold_extdata;

    wire                                                ext_unit_data_valid;
    wire      [PRS_DATA_W-1:0]                          ext_unit_data;
    wire      [PRS_COUNT_W-1:0]                         ext_unit_data_count;
    wire      [PRS_OFFSET_W-1:0]                        ext_unit_word_addr;  //Can be derived from the counter

    // Address Flow
    //wir [(PRS_OFFSET_W * (NUM_OF_EXT_UNITS + 1)-1):0]   ext_unit_addr_start;

    wire      [PRS_OFFSET_W * (NUM_OF_EXT_UNITS+1)-1:0] ext_unit_addr_start; //Absolute
    wire      [HEAD_FIELD_W * NUM_OF_EXT_UNITS-1:0]     ext_unit_field_info;
    wire      [PRS_OFFSET_W * (NUM_OF_EXT_UNITS+1)-1:0] ext_unit_addr_finish;  //
      

    wire      [NUM_OF_EXT_UNITS-1:0]                      ext_unit_hold_en;
    wire      [NUM_OF_EXT_UNITS-1:0]                      ext_unit_hold_en_out;
    wire      [NUM_OF_EXT_UNITS-1:0]                      ext_unit_hold_pipe_en;    

   //Tuples Extracted for Field Buffer
    wire      [PRS_DATA_W * NUM_OF_EXT_UNITS-1 :0]      ext_unit_field_data;
    wire      [PRS_LENGTH_W * NUM_OF_EXT_UNITS-1:0]     ext_unit_field_len;
    wire      [NUM_OF_EXT_UNITS-1:0]                    ext_unit_field_data_valid;
    wire      [PRS_OFFSET_W *NUM_OF_EXT_UNITS -1 :0]    ext_unit_field_offset; 

   //Field For Dynamic Length
    wire      [NUM_OF_EXT_UNITS -1 :0]                  ext_unit_dylen_en;
    wire      [PRS_LENGTH_W * (NUM_OF_EXT_UNITS +1)-1:0]ext_unit_dylen;

   //LookUp Value
    wire      [NUM_OF_EXT_UNITS-1:0]                    ext_unit_lookup_en;
    wire      [PRS_LOOKUP_W * (NUM_OF_EXT_UNITS+1)-1:0] ext_unit_lookup;
//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------

assign ext_unit_data        = ext_core_data_word_i;
assign ext_unit_data_valid = ext_core_data_valid_i;
//ext_core_data_enable_i,
assign ext_unit_addr_start [0 * PRS_OFFSET_W  +: PRS_OFFSET_W ] = ext_core_start_addr_i;
assign ext_core_finish_addr_o = ext_unit_addr_start [(NUM_OF_EXT_UNITS )* PRS_OFFSET_W +:  PRS_OFFSET_W] ;
assign ext_unit_field_info = ext_core_action_field_i; 
  
assign ext_unit_lookup [0 * PRS_LOOKUP_W  +: PRS_LOOKUP_W ] = ext_core_lookup_value_i;
assign ext_unit_lookup_en [0] = ext_core_lookup_valid_i;

assign ext_core_lookup_value_o = ext_unit_lookup [(NUM_OF_EXT_UNITS  )* PRS_LOOKUP_W +:  PRS_LOOKUP_W];
assign ext_core_lookup_valid_o = ext_unit_lookup_en [NUM_OF_EXT_UNITS ];

assign ext_unit_dylen [0 * PRS_LENGTH_W  +: PRS_LENGTH_W ] = ext_core_dylen_value_i;
assign ext_unit_dylen_en [0] = ext_core_dylen_valid_i;

assign ext_core_dylen_value_o = ext_unit_dylen [(NUM_OF_EXT_UNITS  )* PRS_LOOKUP_W +:  PRS_LOOKUP_W];
assign ext_core_dylen_valid_o = ext_unit_dylen_en [NUM_OF_EXT_UNITS ];

assign ext_core_hold_en_o = ext_unit_hold_en[0];

            
            sdn_parser_extraction_unit
                #(
                    .EXT_UNIT_ID             (0                        ),
                    .PRS_DATA_W              (PRS_DATA_W              ),
                    .PRS_OFFSET_W            (PRS_OFFSET_W            ),
                    .PRS_LENGTH_W            (PRS_LENGTH_W            ),
                    .PRS_LOOKUP_W            (PRS_LOOKUP_W            ),
                    .PRS_COUNT_W             (PRS_COUNT_W             ),
                    .HEAD_LEN_W              (HEAD_LEN_W              ),
                    .HEAD_FIELD_LEN_W        (HEAD_FIELD_LEN_W        ),
                    .HEAD_FIELD_W            (HEAD_FIELD_W            ),
                    .NUM_OF_EXT_UNITS        (NUM_OF_EXT_UNITS        ),
                    .HEAR_LOOKUP_DATA_W      (HEAD_LOOKUP_DATA_W      )
                )

                 ext_unit

                (
                    
                    .clk                            (clk),
                    .resetn                         (resetn),
                    .ext_unit_en_i                  (ext_unit_en [ext_unit]),
                    //.ext_unit_header_start_i        (ext_unit_header_start[ext_unit]),
                    //.ext_unit_header_finish_i       (ext_unit_header_start[ext_unit+1]),
                    //.ext_unit_flip_state_i          (ext_unit_flip_state),
                    .ext_unit_header_valid_i        (ext_unit_header_valid),
                    .ext_unit_header_id_i           (ext_unit_header_id),
                    //.ext_unit_flip_i                (ext_unit_flip),
                    //.ext_unit_hold_extdata_i        (ext_unit_hold_extdata),

                    .ext_unit_data_valid_i          (ext_unit_data_valid),
                    .ext_unit_data_i                (ext_unit_data),
                    .ext_unit_data_count_i          (ext_unit_data_count),
                    .ext_unit_word_addr_i           (ext_unit_word_addr),

                    .ext_unit_addr_start_i          (ext_unit_addr_start    [0 * PRS_OFFSET_W +:  PRS_OFFSET_W]),
                    .ext_unit_field_info_i          (ext_unit_field_info    [0 * PRS_OFFSET_W +:  PRS_OFFSET_W]),
                    .ext_unit_addr_finish_o         (ext_unit_addr_start    [(0 +1 )* PRS_OFFSET_W +:  PRS_OFFSET_W]), //CHECK
                    .ext_unit_field_offset_o        (ext_unit_field_offset  [0 * PRS_OFFSET_W +:  PRS_OFFSET_W] ),

                    .ext_unit_hold_en_i             (ext_unit_hold_en [0]),
                    .ext_unit_hold_en_o             (ext_unit_hold_en_out [0]),
                    .ext_unit_hold_pipe_en_o        (ext_unit_hold_pipe_en [0]),

                    .ext_unit_field_data_o          (ext_unit_field_data [0 * PRS_DATA_W +: PRS_DATA_W]),
                    .ext_unit_field_len_o           (ext_unit_field_len [0 * PRS_LENGTH_W +: PRS_LENGTH_W]),
                    .ext_unit_field_data_valid_o    (ext_unit_field_data_valid[0]),

                    .ext_unit_dylen_en_o            (ext_unit_dylen_en [0 + 1]),
                    .ext_unit_dylen_o               (ext_unit_dylen [(0+1) * PRS_LENGTH_W +: PRS_LENGTH_W]),

                    .ext_unit_dylen_en_i            (ext_unit_dylen_en [0]),
                    .ext_unit_dylen_i               (ext_unit_dylen [0 * PRS_LENGTH_W +: PRS_LENGTH_W]),

                    .ext_unit_lookup_en_o           (ext_unit_lookup_en [0+1]),
                    .ext_unit_lookup_o              (ext_unit_lookup [(0+1) * PRS_LOOKUP_W +: PRS_LOOKUP_W]),

                    .ext_unit_lookup_en_i           (ext_unit_lookup_en [0]),
                    .ext_unit_lookup_i              (ext_unit_lookup [0 * PRS_LOOKUP_W +: PRS_LOOKUP_W])
                    
                );    
         
endmodule
