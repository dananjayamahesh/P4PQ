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
// FILE         :   pqsdn_ram_wr.v
// AUTHOR       :   Indunil Wanigasuriya
// DESCRIPTION  :   
//
//
// ********************************************************************************************************************
//
// REVISIONS:
//
//  Date        Developer       Description
//  ----        ---------       -----------
//  23/07/2016  indunil         initial 
//  23/07/2016  mahesh          initial 
//
//
// ********************************************************************************************************************

`timescale 1ns / 1ps

module pqsdn_ram_wr
#(
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    
    parameter           ADDR_W              = 10,
    parameter           DATA_W              = 512,
    parameter           KEEP_W              = DATA_W / 8  //do not modify

)(
//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------
    
    input                           clk,               
    input                           resetn,
    
    input                           s_axis_rx_tvalid_i,
    input           [DATA_W-1:0]    s_axis_rx_tdata_i, 
    input           [KEEP_W-1:0]    s_axis_rx_tkeep_i, 
    input                           s_axis_rx_tlast_i,
    output reg                      s_axis_rx_tready_o,
    
    input                           rden_i,            
    input           [ADDR_W-1:0]    rdaddr_i,          
    output          [DATA_W-1:0]    rddata_o, 
    
    output reg      [ADDR_W-1:0]    wr_ptr_o,          
    input           [ADDR_W-1:0]    rd_ptr_i          
);

//---------------------------------------------------------------------------------------------------------------------
// Global constant headers
//---------------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------
    
    localparam      STATE_INIT      = 0;
    localparam      STATE_WAIT_0    = 1;
    localparam      STATE_WRITE     = 2;
    localparam      STATE_LEN_WR    = 3;
    localparam      STATE_WAIT_1    = 4;
    localparam      STATE_END       = 5;

    localparam      NO_OF_STATES    = 6;

    localparam      MAX_PKT_SIZE    = 10'd256;

//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------
    
    reg         [NO_OF_STATES-1:0]  state;

    reg                             en;
    reg         [KEEP_W-1:0]        wren;
    reg         [ADDR_W-1:0]        wraddr;
    reg         [DATA_W-1:0]        wrdata;

    reg         [ADDR_W-1:0]        wr_ptr_tmp;
    wire        [ADDR_W-1:0]        rdwr_diff;

    ///////////////////////////////////////////////
    reg         [ADDR_W-1:0]        base_wr_ptr_tmp = 0;
    reg         [ADDR_W-1:0]        pkt_len_count_tmp = 0;

    ///////////////////////////////////////////////

//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
    
    assign rdwr_diff = rd_ptr_i - wr_ptr_o + 1'b1;

    always @ (posedge clk) begin
        if (!resetn) begin
            state                                   <= STATE_INIT;
                        
            en                                      <= 1'b0;
            wren                                    <= {KEEP_W{1'b0}};
            wraddr                                  <= {ADDR_W{1'b0}};
            wrdata                                  <= {DATA_W{1'b0}};
            
            wr_ptr_o                                <= {ADDR_W{1'b0}};
            wr_ptr_tmp                              <= {ADDR_W{1'b0}};
        
            s_axis_rx_tready_o                      <= 1'b0;
        end
        else begin
            case (state) 
                STATE_INIT : begin
                    if ((rdwr_diff >= MAX_PKT_SIZE) || (rd_ptr_i == wr_ptr_o)) begin
                        state                       <= STATE_WAIT_0;
        
                        //s_axis_rx_tready_o          <= 1'b1;
                        s_axis_rx_tready_o          <= 1'b0;

                        //Mahesh - 2017/02/01////////////////////////////
                        
                        /*
                        base_wr_ptr_tmp             <= wr_ptr_tmp;
                        wr_ptr_tmp                  <= wr_ptr_tmp + 1'b1;
                        pkt_len_count_tmp           <= 0;
                        */

                        ////////////////////////////////////////////////
                    end        
            
                    en                              <= 1'b0;
                end

                STATE_WAIT_0 : begin
                    if (s_axis_rx_tvalid_i) begin

                        s_axis_rx_tready_o          <= 1'b1;
                        state                       <= STATE_WRITE;

                        base_wr_ptr_tmp             <= wr_ptr_tmp;
                        wr_ptr_tmp                  <= wr_ptr_tmp + 1'b1;
                        pkt_len_count_tmp           <= 0;
            
                        /*
                        en                          <= 1'b1;
                        wren                        <= s_axis_rx_tkeep_i;
                        wraddr                      <= wr_ptr_tmp;
                        wrdata                      <= s_axis_rx_tdata_i;
                        pkt_len_count_tmp           <= pkt_len_count_tmp +1;
            
                        wr_ptr_tmp                  <= wr_ptr_tmp + 1'b1;

                        if (s_axis_rx_tlast_i) begin                            
                            state                     <= STATE_LEN_WR;
                            s_axis_rx_tready_o        <= 1'b0;
                        end
                        else begin
                            state                     <= STATE_WRITE;
                            s_axis_rx_tready_o        <= 1'b1;
                        end

                        */

                    end
                end

                STATE_WRITE : begin
                    if (s_axis_rx_tvalid_i) begin
                        if (s_axis_rx_tlast_i) begin

                            ///////////////////////////////////////////////
                            //state                   <= STATE_INIT;
                            state                     <= STATE_LEN_WR;
                            ///////////////////////////////////////////////
    
                            //wr_ptr_o                <= wr_ptr_tmp + 1'b1;
                            s_axis_rx_tready_o      <= 1'b0;
                        end

                        en                          <= 1'b1;
                        wren                        <= s_axis_rx_tkeep_i;
                        wraddr                      <= wr_ptr_tmp;
                        wrdata                      <= s_axis_rx_tdata_i;            
                        wr_ptr_tmp                  <= wr_ptr_tmp + 1'b1;
                        pkt_len_count_tmp           <= pkt_len_count_tmp +1;
                    end
                end

                STATE_LEN_WR: begin

                   //state                       <= STATE_INIT;
                    //state                       <= STATE_END;
                    state                       <= STATE_WAIT_1;
                    en                          <= 1'b1;
                    wren                        <= 64'hffffffffffffffff;
                    wraddr                      <= base_wr_ptr_tmp;
                    wrdata                      <= pkt_len_count_tmp;

                   // wr_ptr_o                    <= wr_ptr_tmp;


                end

                STATE_WAIT_1: begin
                     state                       <= STATE_END;      

                end

                STATE_END: begin
                    state                       <= STATE_INIT;
                    wr_ptr_o                    <= wr_ptr_tmp;

                    en                          <= 1'b0;
                    //wren                        <= 64'h0000000000000000;
                    //wraddr                      <= 0;
                    //wrdata                      <= 0;
                end

                default : begin
                    state                           <= STATE_INIT;
                        
                    en                              <= 1'b0;
                    wren                            <= {KEEP_W{1'b0}};
                    wraddr                          <= {ADDR_W{1'b0}};
                    wrdata                          <= {DATA_W{1'b0}};
                    
                    wr_ptr_o                        <= {ADDR_W{1'b0}};
                    wr_ptr_tmp                      <= {ADDR_W{1'b0}};

                    s_axis_rx_tready_o              <= 1'b0;
                end

            endcase
        end
    end




    pqsdn_ram_r1w1
    #(
        .ADDR_W             (ADDR_W),
        .DATA_W             (DATA_W)
    )
    gtpc_ram_r1w1_i
    (
        .clk                (clk),
        .rst_n              (resetn),

        .en_a_i             (en),   
        .wren_a_i           (wren),
        .wraddr_a_i         (wraddr),       
        .wrdata_a_i         (wrdata),   

        .rden_b_i           (rden_i),   
        .rdaddr_b_i         (rdaddr_i),     
        .rddata_o           (rddata_o)  
    );

    

endmodule
