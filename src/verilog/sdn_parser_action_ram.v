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
// 21, 2nd Floor, Seibel Avenue,
// Colombo 00500,
// Sri Lanka.
//
// ********************************************************************************************************************
//
// PROJECT      :   
// PRODUCT      :   -
// FILE         :   gtp_v1_c_ram.v
// AUTHOR       :  	Mahesh Dananjaya
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

//Asynchronous Action RAM Block for Hardwired Logic
module sdn_parser_action_ram
#(
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    parameter       DATA_W              = 512,
    parameter       ADDR_W              = 10
)(
//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------
    input                                   clk,
    input                                   resetn,

    input                                   en_a_i,
    input       [ADDR_W-1:0]                wraddr_a_i,
    input       [DATA_W-1:0]                wrdata_a_i,

    input                                   rden_b_i,
    input       [ADDR_W-1:0]                rdaddr_b_i,
    output reg  [DATA_W-1:0]                rddata_b_o
);

//---------------------------------------------------------------------------------------------------------------------
// Global constant headers
//---------------------------------------------------------------------------------------------------------------------
    // None

//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------
    // None

//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------

    reg         [DATA_W-1:0]                ram_r1w1        [(2**ADDR_W) - 1:0];

    reg                                     wren;
    reg         [ADDR_W-1:0]                wraddr;
    reg         [DATA_W-1:0]                wrdata;

//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------

    always @(posedge clk) begin
        if (!resetn) begin
            wren        <= 1'b0;
        end
        else begin
            wren        <= en_a_i;
            wraddr      <= wraddr_a_i;
            wrdata      <= wrdata_a_i;
        end
    end

    always @(posedge clk) begin
        if (wren) begin
            ram_r1w1[wraddr]    <= wrdata;
        end
    end

    always @(resetn, rden_b_i, rdaddr_b_i) begin
        if (!resetn) begin
            rddata_o        <= {DATA_W{1'b0}};
        end
        else begin
            if (rden_b_i) begin
                rddata_b_o    <= ram_r1w1[rdaddr_b_i];
            end
        end
    end

endmodule