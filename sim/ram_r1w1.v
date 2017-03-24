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
// FILE         :   ram_r1w1.v
// AUTHOR       :   
// DESCRIPTION  :   One read and one write ram for the double buffer.
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
// ********************************************************************************************************************

`timescale 1ns / 1ps

module ram_r1w1
#(
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    parameter       DATA_W              = 512,
    parameter       ADDR_W              = 10,
    parameter       EN_W                = DATA_W / 8
)(
//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------

    input                                   clk,
    input                                   rst_n,

    input                                   en_a_i,
    input       [EN_W-1:0]                  wren_a_i,
    input       [ADDR_W-1:0]                wraddr_a_i,
    input       [DATA_W-1:0]                wrdata_a_i,

    input                                   rden_b_i,
    input       [ADDR_W-1:0]                rdaddr_b_i,
    output reg  [DATA_W-1:0]                rddata_o
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

    /*reg                                     rden;
    reg         [ADDR_W-1:0]                rdaddr;*/
    
    reg                                     wren;
    reg         [EN_W-1:0]                  wrbiten;
    reg         [ADDR_W-1:0]                wraddr;
    reg         [DATA_W-1:0]                wrdata;

//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------

    always @(posedge clk) begin
        if (!rst_n) begin
            wren        <= 1'b0;
        end
        else begin
            wren        <= en_a_i;
            wrbiten     <= wren_a_i;
            wraddr      <= wraddr_a_i;
            wrdata      <= wrdata_a_i;
        end
    end

    generate
    genvar g;
        for (g = 0; g < EN_W; g=g+1) begin : BIT_EN_WR
            always @(posedge clk) begin
                if (wren) begin
                    if (wrbiten[g]) begin
                        ram_r1w1[wraddr][(g*8) +: 8]    <= wrdata[(g*8) +: 8];
                    end
                end
            end
        end
    endgenerate

    /*always @(posedge clk) begin
        if (!rst_n) begin
            rden        <= 1'b0;
        end
        else begin
            rden        <= rden_b_i;
            rdaddr      <= rdaddr_b_i;
        end
    end 

    always @(posedge clk) begin
        if (!rst_n) begin
            rddata_o        <= {DATA_W{1'b0}};
        end
        else begin
            if (rden) begin
                rddata_o    <= ram_r1w1[rdaddr];
            end
        end
    end*/

    always @(posedge clk) begin
        if (!rst_n) begin
            rddata_o        <= {DATA_W{1'b0}};
        end
        else begin
            if (rden_b_i) begin
                rddata_o    <= ram_r1w1[rdaddr_b_i];
            end
        end
    end

endmodule
