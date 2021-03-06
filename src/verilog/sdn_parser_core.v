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
// FILE         :   sdn_parser_top.v //PRS-PARSER
// AUTHOR       :  	Mahesh Dananjaya
// DESCRIPTION  :   Programmable Parser Engine
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

module sdn_parser_core
#(
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    parameter           PRS_RX_DATA_W           = 512,
    parameter           PRS_RX_KEEP_W           = PRS_RX_DATA_W / 8, 

    parameter           PRS_TX_DATA_W           = 512,
    parameter           PRS_TX_KEEP_W           = PRS_TX_DATA_W / 8,

    parameter           ACT_CONF_DATA_W         = 32,
    parameter           ACT_CONF_KEEP_W         = ACT_CONF_DATA_W / 8,
    parameter           ACT_CONF_ADDR_W         = 10,

    parameter           CAM_CONF_DATA_W         = 64,
    parameter           CAM_CONF_KEEP_W         = CAM_CONF_DATA_W / 8,
    parameter           CAM_CONF_ADDR_W         = 10,

    parameter           PRS_PROG_DATA_W         = 512,
    parameter           PRS_PROG_KEEP_W         = PRS_PROG_DATA_W / 8,
	//Tuple Parameters
    parameter           PRS_TPL_DATA_W          = 512,
    parameter           PRS_TPL_KEEP_W          = PRS_TPL_DATA_W / 8,

    //parameter           PRS_FIELD_BUFF_DATA_W   = 4096,
    //parameter           PRS_FIELD_BUFF_ADDR_W   = 12,
    parameter           PRS_FIELD_BUFF_DATA_W   = 4096,
    parameter           PRS_FIELD_BUFF_ADDR_W   = 12,    

    parameter           PRS_EXT_BUFF_DATA_W     = 4096,
    parameter           PRS_EXT_BUFF_ADDR_W     = 12,

    parameter           PRS_HEAD_ADDR_W         = 5,
    parameter           PRS_HEAD_FIELD_ADDR_W   = 5,  //These two felds are depending on othe rparameters, Therefore please check parameter before generate

    parameter           PRS_OFFSET_BUFF_DATA_W  = (1<<(PRS_HEAD_ADDR_W+PRS_HEAD_FIELD_ADDR_W))*PRS_FIELD_BUFF_ADDR_W,
    parameter           PRS_OFFSET_BUFF_ADDR_W  = 32,

    parameter           PRS_DATA_W              = 512,
    parameter 			PRS_OFFSET_W 			= 32,
    parameter           PRS_LENGTH_W            = 32,
    parameter           PRS_LOOKUP_W            = 32,

    parameter           ACTION_RAM_DATA_W       = 512,
    parameter           ACTION_RAM_ADDR_W       = 8,
    parameter           ACTION_RAM_LEN_W        = 32,

    //CAM parameters
    parameter           CAM_DATA_W              = 64,
    parameter           CAM_ADDR_W              = 6,

    parameter           PRS_ACTION_DATA_W       = 512,
    parameter           PRS_EXT_UNIT_N          = 32,
    parameter           PRS_ACTION_HEAD_W       = 0,
    parameter           PRS_ACTION_FIELD_W      = 16,
    parameter           PRS_EXT_SEG_EN          = 1,
    parameter           PRS_OPTION              = 1,

    parameter           HEAD_FIELD_FLAG_W       = 6,
    parameter           HEAD_LEN_W              = 0,
    parameter           HEAD_FIELD_LEN_W        = 10,
    parameter           HEAD_FIELD_W            = 32,
    parameter           NUM_OF_EXT_UNITS        = 32,
    parameter           HEAD_LOOKUP_DATA_W      = 64,
    parameter           NUM_OF_PIPELINE_STAGES  = 1,
    parameter           MAX_NUM_HEAD_FIELDS     = 32,

    parameter           PKT_ADDR_W              = 10,
    parameter           PKT_DATA_W              = 512,
    parameter           PKT_KEEP_W              = PKT_DATA_W / 8,  //do not modify,

//Overlapping : Remove later
    parameter           ACT_LEN_W               = 32,
    parameter           ACT_WORD_W              = 512,
    parameter           ACT_DATA_W              = ACT_WORD_W + ACT_LEN_W,
    parameter           ACT_ADDR_W              = 8,
    parameter           ACT_KEEP_W              = ACT_DATA_W / 8,

    parameter           PKT_NUM_W               = 64


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
    //output                                      parser_axis_rx_tdrop_o,
    //Field Buffer Stream
    output      [PKT_NUM_W-1:0]                 parser_pkt_id_o,
    output                                      parser_pkt_valid_o,
    output                                      parser_pkt_err_o,  

    output      [PRS_FIELD_BUFF_DATA_W-1:0]     parser_field_buff_data_o,
    output      [PRS_FIELD_BUFF_ADDR_W-1:0]     parser_field_buff_len_o,
    output                                      parser_field_buff_valid_o,

    output      [PRS_EXT_BUFF_DATA_W-1:0]       parser_ext_buff_data_o,
    output      [PRS_EXT_BUFF_ADDR_W-1:0]       parser_ext_buff_len_o,
    output                                      parser_ext_buff_valid_o,

    output      [PRS_OFFSET_BUFF_DATA_W-1:0]    parser_offset_buff_data_o,
    output      [PRS_OFFSET_BUFF_ADDR_W-1:0]    parser_offset_buff_len_o,
    output                                      parser_offset_buff_valid_o,

    //packetizer interface
    output                                      parser_axis_tx_tvalid_o,
    output          [PRS_TX_DATA_W-1:0]         parser_axis_tx_tdata_o,
    output          [PRS_TX_KEEP_W-1:0]         parser_axis_tx_tkeep_o,
    output                                      parser_axis_tx_tlast_o,
    input                                       parser_axis_tx_tready_i,
    //Header Tuple Stream
    output                                      parser_axis_tuple_tvalid_o,
    output          [PRS_TPL_DATA_W-1:0]        parser_axis_tuple_tdata_o,
    output          [PRS_TPL_KEEP_W-1:0]        parser_axis_tuple_tkeep_o,
    output                                      parser_axis_tuple_tlast_o,
    input                                       parser_axis_tuple_tready_i,

    //Configuration Interface - Action Ram
    input                                       programming,

    input                                       actconf_axis_rx_tvalid_i,
    input           [ACT_CONF_DATA_W-1:0]       actconf_axis_rx_tdata_i,
    input           [ACT_CONF_KEEP_W-1:0]       actconf_axis_rx_tkeep_i,
    input                                       actconf_axis_rx_tlast_i,
    output                                      actconf_axis_rx_tready_o,

    //Configuration Interface - CAM
    input                                       camconf_axis_rx_tvalid_i,
    input           [CAM_CONF_DATA_W-1:0]       camconf_axis_rx_tdata_i,
    input           [CAM_CONF_KEEP_W-1:0]       camconf_axis_rx_tkeep_i,
    input                                       camconf_axis_rx_tlast_i,
    output                                      camconf_axis_rx_tready_o,

    output                                      ext_core_exception_o
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
    wire                                                        parser_axis_rx_tvalid;
    wire           [PRS_RX_DATA_W-1:0]                          parser_axis_rx_tdata;
    wire           [PRS_RX_KEEP_W-1:0]                          parser_axis_rx_tkeep;
    wire                                                        parser_axis_rx_tlast;
    wire                                                        parser_axis_rx_tready;

    wire                                                        pkt_buf_rd_en;
    wire           [PKT_ADDR_W-1:0]                             pkt_buf_rd_addr;
    wire           [PKT_DATA_W-1:0]                             pkt_buf_rd_data;
    wire           [PKT_ADDR_W-1:0]                             pkt_wr_ptr_buf;
    wire           [PKT_ADDR_W-1:0]                             pkt_rd_ptr_buf;

    wire            [PRS_FIELD_BUFF_DATA_W-1:0]                 parser_field_buff_data;
    wire            [PRS_FIELD_BUFF_ADDR_W-1:0]                 parser_field_buff_len;
    wire                                                        parser_field_buff_valid;

    //External ActionRAM Interface - Asynchronous
    wire                                                        action_ram_rd_data_en;
    wire            [ACTION_RAM_ADDR_W-1:0]                     action_ram_rd_data_addr;
    //reg           [ACTION_RAM_DATA_W-1:0]                     action_ram_rd_data = 0;
    //reg           [ACTION_RAM_LEN_W-1:0]                      action_ram_rd_len = 0;
    wire            [ACTION_RAM_DATA_W-1:0]                     action_ram_rd_word;
    wire            [ACTION_RAM_LEN_W-1:0]                      action_ram_rd_len;
    wire            [ACTION_RAM_DATA_W + ACTION_RAM_LEN_W -1:0] action_ram_rd_data;

    wire                                                        prog_en;
    wire                                                        cam_prog_en;

    assign {action_ram_rd_word,action_ram_rd_len }            = action_ram_rd_data;


    //Parser Grapg CAM Lookup Interface
    wire                                                         cam_lookup_en;
    wire             [CAM_DATA_W-ACTION_RAM_ADDR_W-1:0]          cam_lookup_data;
    wire             [CAM_ADDR_W-1:0]                            cam_lookup_addr;
    wire             [ACTION_RAM_ADDR_W-1:0]                     cam_lookup_value;
//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
    sdn_parser_extraction_top
    #(
        .PRS_RX_DATA_W            (PRS_RX_DATA_W          ),
        .PRS_RX_KEEP_W            (PRS_RX_KEEP_W          ),
        .PRS_PROG_DATA_W          (PRS_PROG_DATA_W        ),
        .PRS_PROG_KEEP_W          (PRS_PROG_KEEP_W        ),
        //.PRS_FIELD_BUFF_DATA_W    (PRS_FIELD_BUFF_DATA_W  ),
        //.PRS_FIELD_BUFF_ADDR_W    (PRS_FIELD_BUFF_ADDR_W  ),
        .PRS_EXT_BUFF_DATA_W     (PRS_EXT_BUFF_DATA_W      ),
        .PRS_EXT_BUFF_ADDR_W     (PRS_EXT_BUFF_ADDR_W      ),

        .PRS_FIELD_BUFF_DATA_W   (PRS_FIELD_BUFF_DATA_W   ),
        .PRS_FIELD_BUFF_ADDR_W   (PRS_FIELD_BUFF_ADDR_W   ),
        .PRS_HEAD_ADDR_W         (PRS_HEAD_ADDR_W         ),
        .PRS_HEAD_FIELD_ADDR_W   (PRS_HEAD_FIELD_ADDR_W   ),
        .PRS_OFFSET_BUFF_DATA_W  (PRS_OFFSET_BUFF_DATA_W  ),


        .PRS_DATA_W               (PRS_DATA_W             ),
        .PRS_OFFSET_W             (PRS_OFFSET_W           ),
        .PRS_LENGTH_W             (PRS_LENGTH_W           ),
        .PRS_LOOKUP_W             (PRS_LOOKUP_W           ),
        .ACTION_RAM_DATA_W        (ACTION_RAM_DATA_W      ),
        .ACTION_RAM_ADDR_W        (ACTION_RAM_ADDR_W      ),
        .CAM_DATA_W               (CAM_DATA_W             ),
        .CAM_ADDR_W               (CAM_ADDR_W             ),

        .HEAD_FIELD_FLAG_W       (HEAD_FIELD_FLAG_W       ),
        .HEAD_LEN_W               (HEAD_LEN_W             ),
        .HEAD_FIELD_LEN_W         (HEAD_FIELD_LEN_W       ),
        .HEAD_FIELD_W             (HEAD_FIELD_W           ),
        .NUM_OF_EXT_UNITS         (NUM_OF_EXT_UNITS       ),
        .HEAD_LOOKUP_DATA_W       (HEAD_LOOKUP_DATA_W     ),
        .NUM_OF_PIPELINE_STAGES   (NUM_OF_PIPELINE_STAGES ),
        .MAX_NUM_HEAD_FIELDS      (MAX_NUM_HEAD_FIELDS    ),

        .PKT_ADDR_W                 (PKT_ADDR_W) ,
        .PKT_DATA_W                 (PKT_DATA_W) ,      
        .PKT_KEEP_W                 (PKT_KEEP_W) ,

        .PKT_NUM_W                  (PKT_NUM_W)
    )
    ext_top_block
    (
        .clk                        (clk),
        .resetn                     (resetn),
    
        .pkt_buf_rd_en_o            (pkt_buf_rd_en),
        .pkt_buf_rd_addr_o          (pkt_buf_rd_addr),
        .pkt_buf_rd_data_i          (pkt_buf_rd_data),
        .pkt_wr_ptr_buf_i           (pkt_wr_ptr_buf),
        .pkt_rd_ptr_buf_o           (pkt_rd_ptr_buf),
    
        .parser_pkt_id_o            (parser_pkt_id_o),
        .parser_pkt_valid_o         (parser_pkt_valid_o),
        .parser_pkt_err_o           (parser_pkt_err_o),

        .parser_field_buff_data_o   (parser_field_buff_data_o),
        .parser_field_buff_len_o    (parser_field_buff_len_o),
        .parser_field_buff_valid_o  (parser_field_buff_valid_o),

        .parser_ext_buff_data_o     (parser_ext_buff_data_o),
        .parser_ext_buff_len_o      (parser_ext_buff_len_o),
        .parser_ext_buff_valid_o    (parser_ext_buff_valid_o),
        
        .parser_offset_buff_data_o  (parser_offset_buff_data_o),
        .parser_offset_buff_len_o   (parser_offset_buff_len_o),
        .parser_offset_buff_valid_o (parser_offset_buff_valid_o),

        .programming                (programming),
    
        .action_ram_rd_data_en_o    (action_ram_rd_data_en),
        .action_ram_rd_data_addr_o  (action_ram_rd_data_addr),
        .action_ram_rd_data_i       (action_ram_rd_word),
        .action_ram_rd_len_i        (action_ram_rd_len),
        
        .cam_lookup_en_o            (cam_lookup_en),
        .cam_lookup_data_o          (cam_lookup_data),
        .cam_lookup_addr_i          (cam_lookup_addr),
        .cam_lookup_value_i         (cam_lookup_value)  ,

        .prog_en                    (prog_en)  ,
        .cam_prog_en                (cam_prog_en),
        .ext_core_exception_o       (ext_core_exception_o)
    );


    pqsdn_ram_wr
    #
    (
        .ADDR_W                 (PKT_ADDR_W) ,
        .DATA_W                 (PKT_DATA_W) ,      
        .KEEP_W                 (PKT_KEEP_W) 
    )
    pqsdn_ram_wr_block
    (
        .clk                                (clk), 
        .resetn                             (resetn),

        .s_axis_rx_tvalid_i                 (parser_axis_rx_tvalid_i),                
        .s_axis_rx_tdata_i                  (parser_axis_rx_tdata_i),            
        .s_axis_rx_tkeep_i                  (parser_axis_rx_tkeep_i),            
        .s_axis_rx_tlast_i                  (parser_axis_rx_tlast_i),
        .s_axis_rx_tready_o                 (parser_axis_rx_tready_o),

        .rden_i                             (pkt_buf_rd_en),               
        .rdaddr_i                           (pkt_buf_rd_addr),               
        .rddata_o                           (pkt_buf_rd_data),               
        .wr_ptr_o                           (pkt_wr_ptr_buf),               
        .rd_ptr_i                           (pkt_rd_ptr_buf)               
    );

    pqsdn_action_ram_wr
    #
    (
        .ADDR_W                 (ACT_CONF_ADDR_W) ,
        .DATA_W                 (ACT_CONF_DATA_W) ,      
        .KEEP_W                 (ACT_CONF_KEEP_W) ,
        .ACT_LEN_W              (ACT_LEN_W ),
        .ACT_WORD_W             (ACT_WORD_W),
        .ACT_DATA_W             (ACT_DATA_W),
        .ACT_ADDR_W             (ACT_ADDR_W),
        .ACT_KEEP_W             (ACT_KEEP_W)


    )
    pqsdn_action_ram_wr_block
    (
        .clk                                (clk), 
        .resetn                             (resetn),

        .s_axis_rx_tvalid_i                 (actconf_axis_rx_tvalid_i),                
        .s_axis_rx_tdata_i                  (actconf_axis_rx_tdata_i),            
        .s_axis_rx_tkeep_i                  (actconf_axis_rx_tkeep_i),            
        .s_axis_rx_tlast_i                  (actconf_axis_rx_tlast_i),
        .s_axis_rx_tready_o                 (actconf_axis_rx_tready_o),

        .rden_i                             (action_ram_rd_data_en),               
        .rdaddr_i                           (action_ram_rd_data_addr),               
        .rddata_o                           (action_ram_rd_data),               
        .wr_ptr_o                           (),               
        .rd_ptr_i                           (),

        .prog_en                            (prog_en)               
    );


 pqsdn_cam_wr
    #
    (
        .ADDR_W                 (CAM_CONF_ADDR_W) ,
        .DATA_W                 (CAM_CONF_DATA_W) ,      
        .KEEP_W                 (CAM_CONF_KEEP_W) ,
        
        .CAM_VAL_W              (ACTION_RAM_ADDR_W),
        .CAM_DATA_W             (CAM_DATA_W),
        .CAM_ADDR_W             (CAM_ADDR_W)

    )
    pqsdn_cam_wr_block
    (
        .clk                                (clk), 
        .resetn                             (resetn),

        .s_axis_rx_tvalid_i                 (camconf_axis_rx_tvalid_i),                
        .s_axis_rx_tdata_i                  (camconf_axis_rx_tdata_i),            
        .s_axis_rx_tkeep_i                  (camconf_axis_rx_tkeep_i),            
        .s_axis_rx_tlast_i                  (camconf_axis_rx_tlast_i),
        .s_axis_rx_tready_o                 (camconf_axis_rx_tready_o),

        .rden_i                             (cam_lookup_en),               
        .rdaddr_o                           (cam_lookup_addr),
        .rdval_o                            (cam_lookup_value),              
        .rddata_i                           (cam_lookup_data),               
        .wr_ptr_o                           (),               
        .rd_ptr_i                           (),

        .cam_prog_en                            (cam_prog_en)               
    );

//Action RAM configuration module
//AXI to conversion


// CAM lookup configuration module


endmodule
