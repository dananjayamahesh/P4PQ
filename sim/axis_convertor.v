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
// FILE         :   axis_convertor.v
// AUTHOR       :   
// DESCRIPTION  :   
//
//
// ********************************************************************************************************************
//
// REVISIONS:
//
//  Date        Developer       Description
//  ----        ---------       -----------
//  31/05/2016  indunil         intital
//
//
//
// ********************************************************************************************************************

`timescale 1ns / 1ps

module axis_convertor
#(
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    parameter       DATA_W      = 512,
    parameter       KEEP_W      = DATA_W / 8,
    parameter       ADDR_W      = 10,
    parameter       EN_W        = DATA_W / 8
)(
//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------
    input                                   clk,
    input                                   resetn,

    input       [ADDR_W-1:0]                wr_ptr_i,

    input                                   en_a_i,
    input       [EN_W-1:0]                  wren_a_i,
    input       [ADDR_W-1:0]                wraddr_a_i,
    input       [DATA_W-1:0]                wrdata_a_i,

    output reg                              m_axis_tx_tvalid_o,
    input                                   m_axis_tx_tready_i,
    output reg  [DATA_W-1:0]                m_axis_tx_tdata_o,
    output reg  [KEEP_W-1:0]                m_axis_tx_tkeep_o,
    output reg                              m_axis_tx_tlast_o 
);

//---------------------------------------------------------------------------------------------------------------------
// Global constant headers
//---------------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------
    
    localparam      STATE_INIT          = 0;
    localparam      STATE_WAIT          = 1;
    localparam      STATE_RD_LEN        = 2;
    localparam      STATE_RD_1          = 3;
    localparam      STATE_RD_2          = 4;
    localparam      STATE_RD_3          = 5;
    localparam      STATE_SD_1          = 6;
    localparam      STATE_LAST          = 7;

    localparam      NO_OF_STATE         = 8;

//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------
    
    //rd interface
    reg                                         rden_b;
    reg             [ADDR_W-1:0]                rdaddr_b;
    wire            [DATA_W-1:0]                rddata;
    
    reg             [NO_OF_STATE-1:0]           state;
    
    reg             [ADDR_W-1:0]                frame_count;
    reg             [ADDR_W-1:0]                rd_ptr;

    reg             [DATA_W-1:0]                temp_data_1;
    reg             [DATA_W-1:0]                temp_data_2;

    reg             [1:0]                       sel;
    reg             [1:0]                       count;

    reg                                         first_time;

//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
    
    always @ (posedge clk) begin
        if (!resetn) begin
            state                                   <= STATE_INIT;

            m_axis_tx_tvalid_o                      <= 1'b0;
            m_axis_tx_tdata_o                       <= {DATA_W{1'b0}};
            m_axis_tx_tkeep_o                       <= {KEEP_W{1'b0}};
            m_axis_tx_tlast_o                       <= 1'b0;
                
            rd_ptr                                  <= {ADDR_W{1'b0}};
            rden_b                                  <= 1'b0;
        end
        else begin
            case (state)
                STATE_INIT : begin  //0
                    if (wr_ptr_i != rd_ptr) begin
                        state                       <= STATE_WAIT;
        
                        rden_b                      <= 1'b1;
                        rdaddr_b                    <= rd_ptr;
                    end
                end

                STATE_WAIT : begin  //1
                    state                           <= STATE_RD_LEN;
        
                    rdaddr_b                        <= rdaddr_b + 1'b1;
                end

                STATE_RD_LEN : begin //2    //read the 1st data which has length
                    state                           <= STATE_RD_1;

                    frame_count                     <= rddata;
                    rdaddr_b                        <= rdaddr_b + 1'b1;
                    rd_ptr                          <= rd_ptr + 1'b1;       //rd_ptr only updated when u finished asssign data
                
                end

                STATE_RD_1 : begin //3
                    if (frame_count == 1) begin 
                        state                       <= STATE_LAST;

                        m_axis_tx_tvalid_o          <= 1'b1;
                        m_axis_tx_tlast_o           <= 1'b1;

                        //MOdified By Mahesh
                        m_axis_tx_tkeep_o               <= {KEEP_W{1'b1}};

                    end
                    else begin 
                        state                       <= STATE_RD_2;
                    end

                    rdaddr_b                        <= rdaddr_b + 1'b1;
                    frame_count                     <= frame_count - 1'b1;
                    rd_ptr                          <= rd_ptr + 1'b1;
    
                    m_axis_tx_tdata_o               <= rddata;
                end

                STATE_RD_2 : begin //4
                    state                           <= STATE_RD_3;

                    temp_data_1                     <= rddata;
                    rden_b                          <= 1'b0;

                    /*m_axis_tx_tkeep_o               <= {KEEP_W{1'b1}};
                    m_axis_tx_tvalid_o              <= 1'b1;    */
                end

                STATE_RD_3 : begin //5
                    state                           <= STATE_SD_1;

                    temp_data_2                     <= rddata;
                    sel                             <= 2'd0;
                    count                           <= 2'd0;

                    first_time                      <= 1'b1;

                    m_axis_tx_tkeep_o               <= {KEEP_W{1'b1}};
                    m_axis_tx_tvalid_o              <= 1'b1;    
                end

                STATE_SD_1 : begin //6
                    if (m_axis_tx_tready_i) begin 
                        if (frame_count == 1) begin 
                            state                   <= STATE_LAST;  //should be last state

                            m_axis_tx_tlast_o       <= 1'b1;
                        end

                        if (sel == 2'd0) begin 
                            m_axis_tx_tdata_o       <= temp_data_1;
                            temp_data_1             <= temp_data_2;
                            sel                     <= sel + 1'b1;
                            count                   <= 2'd0;
                        end
                        else if (sel == 2'd1) begin 
                            m_axis_tx_tdata_o       <= temp_data_1;
                            
                            if (count == 2'd1) begin 
                                temp_data_1         <= rddata;
                                count               <= 2'd0;
                            end
                            else begin 
                                sel                 <= sel + 1'b1;
                            end
                        end
                        else if (sel == 2'd2) begin 
                            m_axis_tx_tdata_o       <= rddata;
                        end

                        rd_ptr                      <= rd_ptr + 1'b1;
                        rdaddr_b                    <= rdaddr_b + 1'b1;
                        rden_b                      <= 1'b1;
                        frame_count                 <= frame_count - 1'b1;

                        first_time                  <= 1'b0;    
                    end
                    else if (!first_time) begin 
                        if (sel == 2'd0) begin          //this can be used as first_time
                            //nothing
                        end
                        else if (sel == 2'd1) begin 
                            count                   <= count +1'b1;

                            if (count == 2'd1) begin 
                                temp_data_2         <= rddata;
                                sel                 <= 2'd0;    //new 8/8
                            end
                        end
                        else if (sel == 2'd2) begin 
                            count                   <= count +1'b1;

                            if (count == 2'd0) begin 
                                temp_data_1         <= rddata;
                                sel                 <= 2'd1;
                            end
                            else if (count == 2'd1) begin 
                                temp_data_2         <= rddata;
                                sel                 <= 2'd0;
                            end
                        end

                        rden_b                      <= 1'b0;
                    end
                end

                STATE_LAST : begin //7
                    if(m_axis_tx_tready_i) begin
                        state                       <= STATE_INIT;

                        m_axis_tx_tvalid_o          <= 1'b0;
                        m_axis_tx_tlast_o           <= 1'b0;
                    end
                end

                default : begin
                    state                           <= STATE_INIT;
                
                    m_axis_tx_tvalid_o              <= 1'b0;
                    m_axis_tx_tdata_o               <= {DATA_W{1'b0}};
                    m_axis_tx_tkeep_o               <= {KEEP_W{1'b0}};
                    m_axis_tx_tlast_o               <= 1'b0;
                        
                    rd_ptr                          <= {ADDR_W{1'b0}};
                    rden_b                          <= 1'b0;
                end
            endcase 
        end      
    end


    ram_r1w1
    #(
        .DATA_W         (DATA_W),
        .ADDR_W         (ADDR_W)
    )
    ram_r1w1_i
    (
        .clk            (clk),
        .rst_n          (resetn),

        .en_a_i         (en_a_i),    
        .wren_a_i       (wren_a_i),    
        .wraddr_a_i     (wraddr_a_i),        
        .wrdata_a_i     (wrdata_a_i), 

        .rden_b_i       (rden_b),    
        .rdaddr_b_i     (rdaddr_b),        
        .rddata_o       (rddata)    
    );

endmodule
