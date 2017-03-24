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
// FILE         :   simple_packet_processor_tb.sv
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
//
// ********************************************************************************************************************

`timescale 1ns / 1ps

module sdn_parser_tb;

//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------
    
    import tb_defs::*;
    import dpic_if::*;


//---------------------------------------------------------------------------------------------------------------------
// wires and registers
//---------------------------------------------------------------------------------------------------------------------
    
    reg                                         clk;
    reg                                         resetn;
    
    //axis rx interface
    wire                                        s_axis_rx_tvalid_i;
    wire            [DATA_W-1:0]                s_axis_rx_tdata_i;
    wire            [KEEP_W-1:0]                s_axis_rx_tkeep_i;
    wire                                        s_axis_rx_tlast_i;
    wire                                        s_axis_rx_tready_o;

    //axis tx interface
    wire                                        m_axis_tx_tvalid_o;
    wire            [DATA_W-1:0]                m_axis_tx_tdata_o;
    wire            [KEEP_W-1:0]                m_axis_tx_tkeep_o;
    wire                                        m_axis_tx_tlast_o;
    reg                                         m_axis_tx_tready_i;

//---------------------------------------------------------------------------------------------------------------------  
// internal registers and wires
//---------------------------------------------------------------------------------------------------------------------
    
    reg                             ram_en;
    reg             [KEEP_W-1:0]    ram_wren;
    reg             [ADDR_W-1:0]    ram_wraddr;
    reg             [DATA_W-1:0]    ram_wrdata;
    reg             [ADDR_W-1:0]    ram_wrptr;
    reg             [ADDR_W-1:0]    ram_rdptr;

    reg             [ADDR_W-1:0]    buf_wr_ptr;  //local to the verilog module to convert to axis

    wire            [ADDR_W-1:0]    rd_wr_diff;

//---------------------------------------------------------------------------------------------------------------------
// Instantiate the Design Under Test (DUT)
//---------------------------------------------------------------------------------------------------------------------
    
    assign rd_wr_diff = (ram_rdptr - ram_wrptr + 1);        //remove +1 in l2_cp

    initial begin
        $vcdpluson;
        
        clk                         = 0;
        forever begin      
            #(HALF_CLK)   clk       = ~clk;
        end
    end

    initial begin
        // Initialize Registers
        resetn  = 1'b0;

        m_axis_tx_tready_i = 1'b0;

        ram_en     = 0;
        ram_wren   = 0;
        ram_wraddr = 0;
        ram_wrdata = 0;
        ram_wrptr  = 0;
        ram_rdptr  = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        @(negedge clk);
        resetn  = 1'b1;
        
        #(CLK*2);

        fork
            load_packets();
        join

        #15000;
        $finish;
    end

    // ------------------------------------------------------------------------
    // Load the packets to ram
    // ------------------------------------------------------------------------
    task load_packets();

        //automatic int unsigned a;
        automatic int unsigned pkt_len;
        automatic int unsigned pkt_count;
        automatic int unsigned error;
        automatic int unsigned temp_length;     //used for length return
        automatic longint unsigned data;        //used for data return for locally assign
        automatic int unsigned len_64bit;
        automatic int unsigned len_64bit_rem;
        
        //////////////////////////////////////////////////////////////////////////

        svReadPkts(MAX_PKT_HOLD, error);                                    //1.read packet
        $display("********************************FIRST TIME");
        if (error != 0) begin
            $display("Error at svReadPkts : %2d", error);
            $finish;
        end

        for (int i = 0; i < NUM_OF_ITR; i++) begin                          //NUM_OF_ITR = no of packet store in the ram
            $display("%2d", i);

            svGetPktCount(pkt_count, error);                                //2.get packet count,//return queue size
            if (error != 0) begin       //if error =1;
                $display("Error at svGetPktCount : %2d", error);
                $finish;
            end
            if (pkt_count < MAX_PKT_HOLD) begin
                svReadPkts((MAX_PKT_HOLD - pkt_count), error);
                $display("*****************************************CALL svReadPkts");
                if (error != 0) begin
                    $display("Error at svReadPkts : %2d", error);
                    $finish;
                end
            end

            if ((ram_rdptr == ram_wrptr) || (rd_wr_diff > 256)) begin  //if ram has enough space to write a packets
                //automatic int unsigned pkt_len;
                automatic longint unsigned frame;
                $display("indunil");

                svGetPktFrame(0, frame, pkt_len, error);                    //3.get a frame from a packet to write to the ram, here used to get the number of frames(64bits) with length+header
                if (error != 0) begin
                    $display("Error at svGetPktFrame : %2d", error);
                    $finish;
                end

                for (int unsigned addr = 0; addr < pkt_len; addr++) begin
                    svGetPktFrame(addr, frame, pkt_len, error);             //same as 3.
                    if (error != 0) begin
                        $display("Error at svGetPktFrame : %2d", error);
                        $finish;
                    end 

                    @(posedge clk) begin            //load packet into ram, try to change into negedge clk
                        ram_en = 1;
                        ram_wren = {KEEP_W{1'b1}};
                        ram_wraddr = (ram_wrptr + addr);
                        ram_wrdata = frame;
                        $display("FRAME : %x", frame);

                        /*if (addr == 1) begin
                            rd_hdr = frame;
                        end*/
                    end
                end
                @(posedge clk) begin
                    ram_wrptr += pkt_len;           
                    buf_wr_ptr = ram_wrptr;      //update the wr_ptr to buf reader
                    ram_en = 0;
                    ram_wren = 0;
                end
            end
            else begin
                i = i - 1;
                $display("indunil errorrrrrrrrrr");
            end          
            
            @ (negedge clk)
            m_axis_tx_tready_i = 1'b0;
            ram_rdptr += pkt_len;

            //svResultQueuePop();         //remove the last data hold
        end
    endtask : load_packets

axis_convertor
    #(
        .DATA_W                 (DATA_W),
        .ADDR_W                 (ADDR_W)
    )
    axis_convertor_i
    (
        .clk                    (clk),
        .resetn                 (resetn),

        .wr_ptr_i               (buf_wr_ptr),
                    
        .en_a_i                 (ram_en),
        .wren_a_i               (ram_wren),
        .wraddr_a_i             (ram_wraddr),
        .wrdata_a_i             (ram_wrdata),
        
        .m_axis_tx_tvalid_o     (s_axis_rx_tvalid_i),    
        .m_axis_tx_tready_i     (1'b1),    
        .m_axis_tx_tdata_o      (s_axis_rx_tdata_i),
        .m_axis_tx_tkeep_o      (s_axis_rx_tkeep_i),
        .m_axis_tx_tlast_o      (s_axis_rx_tlast_i)
);

simple_packet_processor
#(

    .PRS_RX_DATA_W           (PRS_RX_DATA_W           ),
    .PRS_RX_KEEP_W           (PRS_RX_KEEP_W           ),
    .PRS_TX_DATA_W           (PRS_TX_DATA_W           ),
    .PRS_TX_KEEP_W           (PRS_TX_KEEP_W           )
)

top_block

(
    .clk                        (clk),
    .resetn                     (resetn),

    .parser_axis_rx_tvalid_i    (s_axis_rx_tvalid_i),
    .parser_axis_rx_tdata_i     (s_axis_rx_tdata_i),
    .parser_axis_rx_tkeep_i     (s_axis_rx_tkeep_i),
    .parser_axis_rx_tlast_i     (s_axis_rx_tlast_i),
    .parser_axis_rx_tready_o    (s_axis_rx_ready_o),    

    .parser_axis_tx_tvalid_o    (m_axis_rx_tvalid_o),
    .parser_axis_tx_tdata_o     (m_axis_rx_tdata_o),
    .parser_axis_tx_tkeep_o     (m_axis_rx_tkeep_o),
    .parser_axis_tx_tlast_o     (m_axis_rx_tlast_o),
    .parser_axis_tx_tready_i    (m_axis_rx_ready_i)

);    

endmodule
