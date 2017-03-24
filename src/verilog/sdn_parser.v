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

module sdn_parser
#(
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    parameter           ADDR_W              = 10,
    parameter           DATA_W              = 64,
    parameter           KEEP_W              = DATA_W / 8  //do not modify

)(
//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------
    
    input                                       clk,
    input                                       resetn,

    //l2_buf BRAM wr interface
    output reg      [ADDR_W-1:0]                fwd_start_addr_o,
    output reg                                  hdr_valid_o,
    output reg      [DATA_W-1:0]                hdr_o,
    input                                       ready_i,
    
    //l2_buf BRAM rd interface
    output reg                                  pkt_buf_rd_en_o,
    output reg      [ADDR_W-1:0]                pkt_buf_rd_addr_o,
    input           [DATA_W-1:0]                pkt_buf_rd_data_i,
    input           [ADDR_W-1:0]                wr_ptr_buf_i,

    //packetizer interface
    output                                      m_axis_tx_tvalid_o,
    output          [DATA_W-1:0]                m_axis_tx_tdata_o,
    output          [KEEP_W-1:0]                m_axis_tx_tkeep_o,
    output                                      m_axis_tx_tlast_o,
    input                                       m_axis_tx_tready_i
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

//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------

endmodule
