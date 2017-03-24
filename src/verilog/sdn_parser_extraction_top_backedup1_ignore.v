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
// FILE         :   .v
// AUTHOR       :  Mahesh Dananjay
// DESCRIPTION  :   
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

module sdn_parser_extraction_top
#(
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    parameter           PRS_RX_DATA_W           = 512,
    parameter           PRS_RX_KEEP_W           = PRS_RX_DATA_W / 8,

    parameter           PRS_PROG_DATA_W         = 512,
    parameter           PRS_PROG_KEEP_W         = PRS_RX_DATA_W / 8,

    parameter           PRS_FIELD_BUFF_DATA_W   = 4096,
    parameter           PRS_FIELD_BUFF_ADDR_W   = 12,

    parameter           PRS_DATA_W              = 512,
    parameter           PRS_OFFSET_W            = 32,
    parameter           PRS_LENGTH_W            = 32,
    parameter           PRS_LOOKUP_W            = 32,

    parameter           ACTION_RAM_DATA_W       = 512,
    parameter           ACTION_RAM_ADDR_W       = 10,

  //CAM is for the Parser Tree Implementation
    parameter           CAM_DATA_W              = 64,
    parameter           CAM_ADDR_W              = 10,

    parameter           HEAD_LEN_W              = 0,
    parameter           HEAD_FIELD_LEN_W        = 9,
    parameter           HEAD_FIELD_W            = 16,
    parameter           NUM_OF_EXT_UNITS        = 32,
    parameter           HEAD_LOOKUP_DATA_W      = 64,

    parameter           ACTION_ADDR_W           = 10,
    parameter           ACTION_DATA_W           = 64,
    parameter           ACTION_KEEP_W           = DATA_W / 8  //do not modify

)(
//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------
    input                                       clk,
    input                                       resetn,
    //RX AXI Interface
    /* 
    input                                       parser_axis_rx_tvalid_i,
    input           [PRS_RX_DATA_W-1:0]         parser_axis_rx_tdata_i,
    input           [PRS_RX_KEEP_W-1:0]         parser_axis_rx_tkeep_i,
    input                                       parser_axis_rx_tlast_i,
    output  reg                                 parser_axis_rx_tready_o,
    output  reg                                 parser_axis_rx_tdrop_o,
    */
    output                                      pkt_buf_rd_en_o,
    output          [ACTION_ADDR_W-1:0]         pkt_buf_rd_addr_o,
    input           [ACTION_DATA_W-1:0]         pkt_buf_rd_data_i,    
    input           [ACTION_ADDR_W-1:0]         pkt_wr_ptr_buf_i,
    output          [ACTION_ADDR_W-1:0]         pkt_rd_ptr_buf_o,

	//Parser Field Buffer
	output  reg     [PRS_FIELD_BUFF_DATA_W-1:0] parser_field_buff_data_o,
    output 	reg		[PRS_FIELD_BUFF_ADDR_W-1:0] parser_field_buff_len_o,
    output 	reg									parser_field_buff_valid_o,

    //External ActionRAM Interface
    output  reg                                 action_ram_rd_data_en_o,
    output  reg     [ACTION_RAM_ADDR_W-1:0]     action_ram_rd_data_addr_o,
    input           [ACTION_RAM_DATA_W-1:0]     action_ram_rd_data_i,


    //Parser Grapg CAM Lookup Interface
    output                                      cam_lookup_en_o,
    output          [CAM_DATA_W-1:0]            cam_lookup_data_o,
    input           [CAM_ADDR_W-1:0]            cam_lookup_addr_i   
);

//---------------------------------------------------------------------------------------------------------------------
// Global constant headers

//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------
//External AXI RX Interface
localparam                      WORD_COUNT_W        = 32;

localparam                      STATE_EXT_W         = 4;
localparam                      STATE_EXT_IDLE      = 0;
localparam                      STATE_EXT_LISTEN    = 1;
localparam                      STATE_EXT_READ      = 2;
localparam                      STATE_EXT_END       = 4;
localparam                      STATE_EXT_DROP      = 5;

//ACTION RAM PIPELINE
localparam                      STATE_ACT_W         = 4;
localparam                      STATE_ACT_IDLE      = 0;
localparam                      STATE_ACT_LISTEN    = 1;
localparam                      STATE_ACT_READ      = 2;
localparam                      STATE_ACT_DROP      = 3;

localparam                      STATE_CORE_W         = 4;
localparam                      STATE_CORE_IDLE      = 0;
localparam                      STATE_CORE_LISTEN    = 1;
localparam                      STATE_CORE_READ      = 2;
localparam                      STATE_CORE_DROP      = 3;

//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------
//Data Word to be Parsed
reg     [STATE_EXT_W-1:0]                   state_prs_ext_core     = STATE_EXT_IDLE;
reg     [PRS_DATA_W-1:0]                    pkt_data_word          = 0;
reg     [PRS_RX_KEEP_W-1:0]                 pkt_data_keep          = 0;
reg     [WORD_COUNT_W-1:0]                  pkt_data_word_count    = 0;

//RX AXI Interface
reg                                         pkt_started            = 0;
reg                                         pkt_finished           = 0;
reg                                         pkt_header_started     = 0;
reg                                         pkt_field_started      = 0; 
reg     [31:0]                              pkt_count              = 0;
reg     [31:0]                              pkt_field_count        = 0;

reg                                         pkt_fetch_start        = 0;
reg                                         pkt_header_extracted   = 0;

//Action Unit Address
reg     [ACTION_RAM_ADDR_W-1:0]             action_ram_addr         = 0;
reg     [ACTION_RAM_DATA_W-1:0]             action_ram_data         = 0;
reg     [PRS_FIELD_BUFF_DATA_W-1:0]         parser_field_buffer     = 0;
//STATE
reg     [STATE_ACT_W-1:0]                   state_prs_act_ram       = STATE_ACT_IDLE;

//CORE FSM
reg     [STATE_CORE_W-1:0]                  state_prs_core          = STATE_CORE_IDLE;
reg     [PRS_LOOKUP_W-1:0]                  ext_lkup_val            = 0;
reg     [PRS_LENGTH_W-1:0]                  ext_dyn_val             = 0;

//NEW Extraction Core
reg   [PRS_DATA_W-1:0]                    ext_core_data_word;
reg                                       ext_core_data_valid;
reg   [PRS_OFFSET_W-1:0]                  ext_core_start_addr;
wire  [PRS_OFFSET_W-1:0]                  ext_core_finish_addr_out;
reg   [ACTION_RAM_DATA_W-1:0]             ext_core_action_field;
reg                                       ext_core_action_valid;
reg   [PRS_LOOKUP_W-1:0]                  ext_core_lookup_value;
reg                                       ext_core_lookup_valid;
wire  [PRS_LOOKUP_W-1:0]                  ext_core_lookup_value_out;
wire                                      ext_core_lookup_valid_out;
reg   [PRS_LENGTH_W-1:0]                  ext_core_dylen_value;
reg                                       ext_core_dylen_valid;
wire  [PRS_LENGTH_W-1:0]                  ext_core_dylen_value_out;
wire                                      ext_core_dylen_valid_out;
wire                                      ext_core_hold_en_out;
wire                                      ext_core_head_finished_out;
//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
 

sdn_parser_extraction_core 
#(

    .PRS_DATA_W                 (PRS_DATA_W         ),
    .PRS_OFFSET_W               (PRS_OFFSET_W       ),
    .PRS_LENGTH_W               (PRS_LENGTH_W       ),
    .PRS_LOOKUP_W               (PRS_LOOKUP_W       ),
    .ACTION_RAM_DATA_W          (ACTION_RAM_DATA_W  ),
    .ACTION_RAM_ADDR_W          (ACTION_RAM_ADDR_W  ),
    .HEAD_LEN_W                 (HEAD_LEN_W         ),
    .HEAD_FIELD_LEN_W           (HEAD_FIELD_LEN_W   ),
    .HEAD_FIELD_W               (HEAD_FIELD_W       ),
    .NUM_OF_EXT_UNITS           (NUM_OF_EXT_UNITS   ),
    .HEAD_LOOKUP_DATA_W         (HEAD_LOOKUP_DATA_W )

)
ext_core_blobk
(

    .clk                    (clk),
    .resetn                 (resetn),

    .ext_core_data_word_i   (ext_core_data_word),
    .ext_core_data_enable_i (ext_core_data_valid),

    .ext_core_start_addr_i  (ext_core_start_addr),
    .ext_core_finish_addr_o (ext_core_finish_addr_out),

    .ext_core_action_field_i (ext_core_action_field),
    .ext_core_action_valid_i (ext_core_action_valid),

    .ext_core_lookup_value_i (ext_core_lookup_value),
    .ext_core_lookup_valid_i (ext_core_lookup_valid),

    .ext_core_lookup_value_o (ext_core_lookup_value_out),
    .ext_core_lookup_valid_o (ext_core_lookup_valid_out), 

    .ext_core_dylen_value_i (ext_core_dylen_value),
    .ext_core_dylen_valid_i (ext_core_dylen_valid),

    .ext_core_dylen_value_o (ext_core_dylen_value_out),
    .ext_core_dylen_valid_o (ext_core_dylen_valid_out),

    .ext_core_hold_en_o     (ext_core_hold_en_out),
    .ext_core_head_finished_o (ext_core_head_finished_out)
);

//Accessing Action RAM
always@(posedge clk)begin
	if(resetn)begin
    	case(state_prs_act_ram)
    		STATE_ACT_IDLE: begin
                ext_core_action_field <= 0;
                ext_core_action_valid <= 0;
                state_prs_act_ram <= STATE_ACT_LISTEN;
    		end
    		STATE_ACT_LISTEN: begin
             if(ext_core_head_finished_out)begin
                state_prs_act_ram <= STATE_ACT_READ;
             end
    		end
    		STATE_ACT_READ: begin
                state_prs_act_ram <= STATE_ACT_IDLE;
    		end
    	endcase	
	end
	else begin
        //Reset Logic
        ext_core_action_field <= 0;
        ext_core_action_valid <= 0;
        state_prs_act_ram <= STATE_ACT_IDLE;
	end
end

always@(posedge clk)begin
    if(resetn)begin
        case(state_prs_core)
            
        endcase
    end
    else begin

    end
end


//Combinational Logic for Signals
always@(posedge clk)begin
	if(resetn)begin
        case(state_prs_ext_core)

            STATE_EXT_IDLE  : begin
                state_prs_ext_core      <= STATE_EXT_LISTEN ;
                pkt_data_word           <= 0; 

                ext_core_start_addr <= 0;

                ext_core_lookup_value <= 0;
                ext_core_lookup_valid <= 0; 

                ext_core_dylen_value <= 0;
                ext_core_dylen_valid <= 0;

            end

            STATE_EXT_LISTEN : begin
                if(parser_axis_rx_tvalid_i)begin
                    pkt_started             <= 1;
                    state_prs_ext_core      <= STATE_EXT_READ ;
                    pkt_data_word           <= parser_axis_rx_tdata_i;
                    //check
                    ext_core_data_word      <= parser_axis_rx_tdata_i;
                    ext_core_data_valid     <= 1'b1;

                    pkt_data_keep           <= parser_axis_rx_tkeep_i;
                    pkt_data_word_count     <= pkt_data_word_count + 1;
                    //parser_axis_rx_tready_o <= 0;
                    pkt_finished            <= (parser_axis_rx_tlast_i) ? 1 : 0 ;                                          
                end
            end

            STATE_EXT_READ  : begin
                if(parser_axis_rx_tlast_i ||  pkt_header_extracted) begin                    
                    pkt_finished                <= 1; 
                    state_prs_ext_core          <= STATE_EXT_END;
                    parser_axis_rx_tdrop_o      <= 1'b1;
                end

                if(parser_axis_rx_tready_o)begin
                    pkt_data_word           <= parser_axis_rx_tdata_i;
                    pkt_data_keep           <= parser_axis_rx_tkeep_i;
                    pkt_data_word_count     <= pkt_data_word_count + 1;
                end
            end

            STATE_EXT_END  : begin
                pkt_count                   <= pkt_count + 1;
                state_prs_ext_core          <= STATE_EXT_IDLE;
                parser_axis_rx_tdrop_o      <= 0;
                pkt_finished                <= 0;
                pkt_started                 <= 0;
                pkt_fetch_start             <= 0;
                
                pkt_data_word               <= 0;
                pkt_data_keep               <= 0;
               
            end
        endcase
	end
	else begin
	    pkt_count                   <= 0;
        state_prs_ext_core          <= STATE_EXT_IDLE;
        //parser_axis_rx_tready_o     <= 0;
        parser_axis_rx_tdrop_o      <= 0;
        pkt_finished                <= 0;
        pkt_started                 <= 0;
        pkt_fetch_start             <= 0;
        
        pkt_data_word               <= 0;
        pkt_data_keep               <= 0;  
	end
end
endmodule
