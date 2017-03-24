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

module pqsdn_cam_wr
#(
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    
    parameter           ADDR_W              = 10,
    parameter           DATA_W              = 64,
    parameter           KEEP_W              = DATA_W / 8,  //do not modify,

    parameter           CAM_VAL_W           = 9,  //Header Length //ACTION_RAM_ADDR_W
    parameter           CAM_DATA_W          = 64,
    parameter           CAM_ADDR_W          = 8,
    parameter           CAM_KEEP_W          = CAM_DATA_W / 8

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
    output          [CAM_ADDR_W-1:0]    rdaddr_o,          
    input           [CAM_DATA_W-1:0]    rddata_i, 
    output          [CAM_VAL_W-1:0]     rdval_o,
    output                              rdvalid_o,
    
    output reg      [CAM_ADDR_W-1:0]    wr_ptr_o,          
    input           [CAM_ADDR_W-1:0]    rd_ptr_i,

    output   reg                        cam_prog_en        
);

//---------------------------------------------------------------------------------------------------------------------
// Global constant headers
//---------------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------
    
    localparam      STATE_INIT      = 0;
    localparam      STATE_LEN       = 1;
    localparam      STATE_FLD       = 2;
    localparam      STATE_ACT       = 3;
    localparam      STATE_WRITE     = 4;
    localparam      STATE_END       = 5;

    localparam      NO_OF_STATES    = 3;

    localparam      MAX_PKT_SIZE    = 10'd256;

//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------
    
    reg         [NO_OF_STATES-1:0]      state;

    reg                                 en;
    reg         [CAM_KEEP_W-1:0]        wren;
    reg         [CAM_ADDR_W-1:0]        wraddr;
    reg         [CAM_DATA_W-1:0]        wrdata;

    reg         [CAM_ADDR_W-1:0]        wr_ptr_tmp;
    wire        [CAM_ADDR_W-1:0]        rdwr_diff;

    ///////////////////////////////////////////////
    reg         [CAM_ADDR_W-1:0]        base_wr_ptr_tmp         = 0;
    reg         [CAM_ADDR_W-1:0]        pkt_len_count_tmp       = 0;

    reg         [CAM_ADDR_W-1:0]        cam_addr_tmp            = 0;

    integer                             cam_field_count_tmp     = 0;

    reg         [CAM_DATA_W-1:0]        cam_data_tmp            = 0;
    integer                             cam_count_tmp           = 0;
    
    integer                             cam_num_field_tmp       = 0;
    integer                             cam_num_head_tmp        = 0;

    ///////////////////////////////////////////////
    reg                                             en_2;
    reg         [CAM_KEEP_W-1:0]                    wren_2;
    reg         [CAM_ADDR_W-1:0]                    wraddr_2;
    reg         [CAM_VAL_W-1:0]                     wrdata_2;

    wire        [CAM_DATA_W-CAM_VAL_W-1:0]          wrdata_lkup;
    wire        [CAM_VAL_W-1:0]                     wrdata_val;

    assign wrdata_lkup = wrdata [CAM_VAL_W +: (CAM_DATA_W-CAM_VAL_W)];
    assign wrdata_val  = wrdata [0 +: CAM_VAL_W] ;

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
            cam_prog_en                             <= 1'b1;

        end
        else begin
            case (state) 
                STATE_INIT : begin
                    if(s_axis_rx_tvalid_i) begin
                        s_axis_rx_tready_o          <= 1'b1;
                        state                       <= STATE_ACT;
                        cam_num_head_tmp            <= cam_num_head_tmp +1; 
                        cam_prog_en                 <= 1'b1;
                        cam_addr_tmp                <= 0;  
                        cam_count_tmp               <= 0;                                         
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
                        //////////////////////////
                        
                        en                          <= 1'b1;
                        wren                        <= s_axis_rx_tkeep_i;
                        wraddr                      <= cam_addr_tmp;
                        wrdata                      <= s_axis_rx_tdata_i;            
                        cam_addr_tmp                <= cam_addr_tmp + 1'b1;
                        pkt_len_count_tmp           <= pkt_len_count_tmp +1;

                    end
                end

                STATE_WRITE : begin             
                       
                        state                       <= STATE_INIT;
                        cam_prog_en                 <= 1'b0; 
                        s_axis_rx_tready_o          <= 1'b0;                    
                    
                end

                default : begin
                    state                           <= STATE_INIT;
                        
                    en                              <= 1'b0;
                    wren                            <= {CAM_KEEP_W{1'b0}};
                    wraddr                          <= {CAM_ADDR_W{1'b0}};
                    wrdata                          <= {CAM_DATA_W{1'b0}};
                    
                    wr_ptr_o                        <= {CAM_ADDR_W{1'b0}};
                    wr_ptr_tmp                      <= {CAM_ADDR_W{1'b0}};

                    s_axis_rx_tready_o              <= 1'b0;

                    cam_prog_en                     <= 1'b1;
                    cam_addr_tmp                    <= 0;

                end

            endcase
        end
    end

   /* pqsdn_cam
    #(
        .ADDR_W             (CAM_ADDR_W),
        .DATA_W             (CAM_DATA_W)
    )
    cam_conf_block
    (
        .clk                (clk),
        .rst_n              (resetn),

        .en_a_i             (en),   
        .wren_a_i           (wren),
        .wraddr_a_i         (wraddr),       
        .wrdata_a_i         (wrdata),   

        .rden_b_i           (rden_i),   
        .rdaddr_b_o         (rdaddr_o),     
        .rddata_b_i         (rddata_i)  
    );
    */

    //Value Storing RAM
   pqsdn_cam_new
    #(
        .ADDR_W             (CAM_ADDR_W),
        .DATA_W             (CAM_DATA_W-CAM_VAL_W)
    )
    pqsdn_lookup_table
    (
        .clk                (clk),
        .rst_n              (resetn),

        .en_a_i             (en),   
        //.wren_a_i           (wren),
        .wraddr_a_i         (wraddr),       
        .wrdata_a_i         (wrdata_lkup),   

        .rden_b_i           (rden_i),   
        .rdaddr_b_o         (rdaddr_o),
        .rdvalid_b_o        (rdvalid_b_o),  
        .rddata_b_i         (rddata_i)
    );
    

    pqsdn_ram_async_rd
    #(
        .ADDR_W             (CAM_ADDR_W),
        .DATA_W             (CAM_VAL_W)
    )
    pqsdn_cam_value_ram
    (
        .clk                (clk),
        .rst_n              (resetn),

        .en_a_i             (en),   
        //.wren_a_i           (wren),
        .wraddr_a_i         (wraddr),       
        .wrdata_a_i         (wrdata_val),   

        .rden_b_i           (rdvalid_b_o),   
        .rdaddr_b_i         (rdaddr_o),     
        .rddata_o           (rdval_o)  

    );

endmodule
