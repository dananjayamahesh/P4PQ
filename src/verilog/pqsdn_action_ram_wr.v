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
// FILE         :   pqsdn_action_ram_wr.v
// AUTHOR       :   Mahesh Dananjaya
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
// ********************************************************************************************************************

`timescale 1ns / 1ps

module pqsdn_action_ram_wr
#(
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    
    parameter           ADDR_W              = 10,
    parameter           DATA_W              = 32,
    parameter           KEEP_W              = DATA_W / 8,  //do not modify,

    parameter           ACT_LEN_W           = 32,
    parameter           ACT_WORD_W          = 512,
    parameter           ACT_DATA_W          = ACT_WORD_W + ACT_LEN_W,
    parameter           ACT_ADDR_W          = 8,
    parameter           ACT_KEEP_W          = ACT_DATA_W / 8


)(
//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------
    
    input                               clk,               
    input                               resetn,
    
    input                               s_axis_rx_tvalid_i,
    input           [DATA_W-1:0]        s_axis_rx_tdata_i, 
    input           [KEEP_W-1:0]        s_axis_rx_tkeep_i, 
    input                               s_axis_rx_tlast_i,
    output reg                          s_axis_rx_tready_o,
    
    input                               rden_i,            
    input           [ACT_ADDR_W-1:0]    rdaddr_i,          
    output          [ACT_DATA_W-1:0]    rddata_o, 
    
    output reg      [ACT_ADDR_W-1:0]    wr_ptr_o,          
    input           [ACT_ADDR_W-1:0]    rd_ptr_i    ,

    output   reg                        prog_en        
);

//---------------------------------------------------------------------------------------------------------------------
// Global constant headers
//---------------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------
    
    localparam      STATE_INIT    = 0;
    localparam      STATE_LEN     = 1;
    localparam      STATE_FLD     = 2;
    localparam      STATE_ACT     = 3;
    localparam      STATE_WRITE   = 4;
    localparam      STATE_END     = 5;

    localparam      NO_OF_STATES    = 3;

    localparam      MAX_PKT_SIZE    = 10'd256;

//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------
    
    reg         [NO_OF_STATES-1:0]      state;

    reg                                 en;
    reg         [ACT_KEEP_W-1:0]        wren;
    reg         [ACT_ADDR_W-1:0]        wraddr;
    reg         [ACT_DATA_W-1:0]        wrdata;

    reg         [ACT_ADDR_W-1:0]        wr_ptr_tmp;
    wire        [ACT_ADDR_W-1:0]        rdwr_diff;

    ///////////////////////////////////////////////
    reg         [ACT_ADDR_W-1:0]        base_wr_ptr_tmp = 0;
    reg         [ACT_ADDR_W-1:0]        pkt_len_count_tmp = 0;

    reg         [ACT_ADDR_W-1:0]        act_ram_addr_tmp = 0;

    integer                             act_ram_field_count_tmp = 0;

    reg         [ACT_DATA_W-1:0]        act_data_tmp  = 0;
    integer                             act_count_tmp = 0;
    
    integer                             act_num_field_tmp = 0;
    integer                             act_num_head_tmp = 0;

    ///////////////////////////////////////////////

//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
    
    assign rdwr_diff = rd_ptr_i - wr_ptr_o + 1'b1;

    always @ (posedge clk) begin
        if (!resetn) begin
            state                                   <= STATE_INIT;
                        
            en                                      <= 1'b0;
            wren                                    <= {ACT_KEEP_W{1'b0}};
            wraddr                                  <= {ACT_ADDR_W{1'b0}};
            wrdata                                  <= {ACT_DATA_W{1'b0}};
            
            wr_ptr_o                                <= {ACT_ADDR_W{1'b0}};
            wr_ptr_tmp                              <= {ACT_ADDR_W{1'b0}};
        
            s_axis_rx_tready_o                      <= 1'b0;
            prog_en                                 <= 1'b1;
            
        end
        else begin
            case (state) 
                STATE_INIT : begin
                    if(s_axis_rx_tvalid_i) begin
                        s_axis_rx_tready_o          <= 1'b1;
                        state                       <= STATE_LEN;
                        act_num_head_tmp            <= act_num_head_tmp +1; 
                        prog_en                     <= 1'b1;
                        //wr_ptr_tmp                  <= 0;                                           
                    end
                end

                STATE_LEN : begin
                    if (s_axis_rx_tvalid_i) begin
                        s_axis_rx_tready_o          <= 1'b1;
                        state                       <= STATE_FLD; 
                        act_ram_addr_tmp            <= s_axis_rx_tdata_i;  
                        act_count_tmp               <= 0;
                    end
                end

                STATE_FLD : begin
                    if (s_axis_rx_tvalid_i) begin
                        act_ram_field_count_tmp    <= s_axis_rx_tdata_i; //Number of Valid Header Fields
                        s_axis_rx_tready_o          <= 1'b1;
                        state                       <= STATE_ACT; 
                        
                        act_count_tmp               <= act_count_tmp + 1; 
                        act_data_tmp [act_count_tmp * 32 +: DATA_W ] <= s_axis_rx_tdata_i;

                        s_axis_rx_tready_o          <= 1'b1;
                    end
                end

                STATE_ACT : begin
                    if (s_axis_rx_tvalid_i) begin

                        if(s_axis_rx_tlast_i)begin
                            state                       <= STATE_WRITE;
                            s_axis_rx_tready_o          <= 1'b0;
                        end
                        else begin
                            s_axis_rx_tready_o          <= 1'b1;
                        end
                        //PUT DATA INTO ONE WORD
                            act_count_tmp               <= act_count_tmp + 1;    
                            act_data_tmp [act_count_tmp * 32 +: DATA_W ] <= s_axis_rx_tdata_i;  
                            act_num_field_tmp           <= act_num_field_tmp +1 ;                  
                
                            //en                          <= 1'b1;
                            //wren                        <= s_axis_rx_tkeep_i;
                            //wraddr                      <= wr_ptr_tmp;
                            //wrdata                      <= s_axis_rx_tdata_i;
                            pkt_len_count_tmp           <= pkt_len_count_tmp +1;   
    
                            wr_ptr_tmp                  <= wr_ptr_tmp + 1'b1;

                    end
                end

                STATE_WRITE : begin                   

                        en                          <= 1'b1;
                        wren                        <= 68'hfffffffffffffffff; // earlier s_axis_rx_tkeep_i
                        wraddr                      <= act_ram_addr_tmp;
                        wrdata                      <= act_data_tmp;
                        state                       <= STATE_INIT;
                        prog_en                     <= 1'b0; 

                        s_axis_rx_tready_o          <= 1'b0;                    
                    
                end

                default : begin
                    state                           <= STATE_INIT;
                        
                    en                              <= 1'b0;
                    wren                            <= {ACT_KEEP_W{1'b0}};
                    wraddr                          <= {ACT_ADDR_W{1'b0}};
                    wrdata                          <= {ACT_DATA_W{1'b0}};
                    
                    wr_ptr_o                        <= {ACT_ADDR_W{1'b0}};
                    wr_ptr_tmp                      <= {ACT_ADDR_W{1'b0}};

                    s_axis_rx_tready_o              <= 1'b0;

                    prog_en                         <= 1'b1;

                end

            endcase
        end
    end

    pqsdn_ram_r1w1
    #(
        .ADDR_W             (ACT_ADDR_W),
        .DATA_W             (ACT_DATA_W)
    )
    sdn_ram_r1w1_i
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
