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

module sdn_parser_fetch_unit
#(
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    parameter           PRS_RX_DATA_W           = 512,
    parameter           PRS_RX_KEEP_W           = PRS_RX_DATA_W / 8,
    parameter           PRS_DATA_W              = 512

)(
//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------
    input                                       clk,
    input                                       resetn,

    //RX AXI Interface
    input                                       parser_axis_rx_tvalid_i,
    input           [PRS_RX_DATA_W-1:0]         parser_axis_rx_tdata_i,
    input           [PRS_RX_KEEP_W-1:0]         parser_axis_rx_tkeep_i,
    input                                       parser_axis_rx_tlast_i,
    output                                      parser_axis_rx_tready_o,
    output                                      parser_axis_rx_tdrop_o
);

//---------------------------------------------------------------------------------------------------------------------
// Global constant headers
//---------------------------------------------------------------------------------------------------------------------
localparam						STATE_RX_IDLE = 0;
localparam						STATE_RX_READ = 0;

//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------

always@(posedge clk)begin
	if(resetn)begin

	end
	else begin
	
	end
end
endmodule
