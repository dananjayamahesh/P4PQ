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

module sdn_parser_extraction_top
#(
//---------------------------------------------------------------------------------------------------------------------
// parameter definitions
//---------------------------------------------------------------------------------------------------------------------
    parameter           PRS_RX_DATA_W           = 512,
    parameter           PRS_RX_KEEP_W           = PRS_RX_DATA_W / 8,

    parameter           PRS_PROG_DATA_W         = 512,
    parameter           PRS_PROG_KEEP_W         = PRS_RX_DATA_W / 8,

    parameter           PRS_FIELD_BUFF_DATA_W   = 4096,
    parameter           PRS_FIELD_BUFF_ADDR_W   = 12,
    
    parameter           PRS_EXT_BUFF_DATA_W     = 4096,
    parameter           PRS_EXT_BUFF_ADDR_W     = 12,

    parameter           PRS_HEAD_ADDR_W         = 5,
    parameter           PRS_HEAD_FIELD_ADDR_W   = 5,  //These two felds are depending on othe rparameters, Therefore please check parameter before generate

    parameter           PRS_OFFSET_BUFF_DATA_W  = (1<<(PRS_HEAD_ADDR_W+PRS_HEAD_FIELD_ADDR_W))*PRS_FIELD_BUFF_ADDR_W,
    parameter           PRS_OFFSET_BUFF_ADDR_W  = 32,

    parameter           PRS_DATA_W              = 512,
    parameter           PRS_OFFSET_W            = 32,
    parameter           PRS_LENGTH_W            = 32,
    parameter           PRS_LOOKUP_W            = 32,
    parameter           PRS_COUNT_W             = 32,

    parameter           ACTION_RAM_DATA_W       = 512,
    parameter           ACTION_RAM_ADDR_W       = 10,
    parameter           ACTION_RAM_LEN_W        = 32,

  //CAM is for the Parser Tree Implementation
    parameter           CAM_DATA_W              = 64,
    parameter           CAM_ADDR_W              = 6,


    parameter           HEAD_FIELD_FLAG_W       = 6,
    parameter           HEAD_LEN_W              = 0,
    parameter           HEAD_FIELD_LEN_W        = 10,
    parameter           HEAD_FIELD_W            = 16,
    parameter           NUM_OF_EXT_UNITS        = 32,

    parameter           NUM_OF_ACT_FIELDS       = 32, //Can be derived from Action RAM field Width = 

    parameter           HEAD_LOOKUP_DATA_W      = 64,
    parameter           NUM_OF_PIPELINE_STAGES  = 1,
    parameter           MAX_NUM_HEAD_FIELDS     = 32, //per header

    parameter              PKT_ADDR_W           = 10,
    parameter              PKT_DATA_W           = 512, //64,
    parameter              PKT_KEEP_W           = PKT_DATA_W / 8,  //do not modify

    parameter               PKT_NUM_W           = 64

)(
//---------------------------------------------------------------------------------------------------------------------
// I/O signals
//---------------------------------------------------------------------------------------------------------------------
    input                                                   clk,
    input                                                   resetn,
            
    output                                                  pkt_buf_rd_en_o,
    output reg      [PKT_ADDR_W-1:0]                        pkt_buf_rd_addr_o,
    input           [PKT_DATA_W-1:0]                        pkt_buf_rd_data_i,  
    input           [PKT_ADDR_W-1:0]                        pkt_wr_ptr_buf_i,
    output reg      [PKT_ADDR_W-1:0]                        pkt_rd_ptr_buf_o,
            
	//Parser Field Buffer
    output  reg     [PKT_NUM_W-1:0]                         parser_pkt_id_o,
    output  reg                                             parser_pkt_valid_o,
    output  reg                                             parser_pkt_err_o,                                                                              

	output  reg     [PRS_FIELD_BUFF_DATA_W-1:0]             parser_field_buff_data_o,
    output 	reg		[PRS_FIELD_BUFF_ADDR_W-1:0]             parser_field_buff_len_o,
    output 	reg									            parser_field_buff_valid_o,

    output  reg     [PRS_EXT_BUFF_DATA_W-1:0]               parser_ext_buff_data_o,
    output  reg     [PRS_EXT_BUFF_ADDR_W-1:0]               parser_ext_buff_len_o,
    output  reg                                             parser_ext_buff_valid_o,

    output  reg     [PRS_OFFSET_BUFF_DATA_W-1:0]            parser_offset_buff_data_o,
    output  reg     [PRS_OFFSET_BUFF_ADDR_W-1:0]            parser_offset_buff_len_o,
    output  reg                                             parser_offset_buff_valid_o,

    //External ActionRAM Interface - Asynchronous
    input                                                   programming,
            
    output                                                  action_ram_rd_data_en_o,
    output  reg     [ACTION_RAM_ADDR_W-1:0]                 action_ram_rd_data_addr_o,
    input           [ACTION_RAM_DATA_W-1:0]                 action_ram_rd_data_i,
    input           [ACTION_RAM_LEN_W-1:0]                  action_ram_rd_len_i,

    //Parser Graph CAM Lookup Interface //data to search in CAM
    output                                                  cam_lookup_en_o,
    output reg      [CAM_DATA_W-ACTION_RAM_ADDR_W-1:0]      cam_lookup_data_o,
    input           [CAM_ADDR_W-1:0]                        cam_lookup_addr_i,
   // input           [HEAD_FIELD_LEN_W-1:0]                  cam_lookup_value_i,
    input           [ACTION_RAM_ADDR_W-1:0]                 cam_lookup_value_i,

    input                                                   prog_en,  // This is for the Action RAM,
    input                                                   cam_prog_en,
    output reg                                              ext_core_exception_o
);

//---------------------------------------------------------------------------------------------------------------------
// Global constant headers

//---------------------------------------------------------------------------------------------------------------------
// localparam definitions
//---------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------
//External AXI RX Interface
  
localparam                                  STATE_EXT_W         = 3;
localparam                                  STATE_EXT_IDLE      = 0;
localparam                                  STATE_EXT_INIT      = 1;
localparam                                  STATE_EXT_PKT       = 2;
localparam                                  STATE_EXT_PARS      = 3;
localparam                                  STATE_EXT_FINISH    = 4;
localparam                                  STATE_EXT_READ      = 5;


//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------
//Data Word to be Parsed

//NEW Extraction Core
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg                                         ext_core_flush;

//wire    [PRS_DATA_W-1:0]                    ext_core_data_word;
reg     [PRS_DATA_W-1:0]                    ext_core_data_word;
reg                                         ext_core_data_valid;
reg     [PRS_COUNT_W-1:0]                   ext_core_data_count;

reg     [PRS_OFFSET_W-1:0]                  ext_core_start_addr;
wire    [PRS_OFFSET_W-1:0]                  ext_core_finish_addr_out;

wire    [ACTION_RAM_DATA_W-1:0]             ext_core_action_field;
wire    [ACTION_RAM_LEN_W-1:0]              ext_core_action_length;
reg                                         ext_core_action_valid;
//Newly Added
reg     [PRS_FIELD_BUFF_DATA_W-1:0]         parser_field_buff_data_in;
reg     [PRS_FIELD_BUFF_ADDR_W-1:0]         parser_field_buff_len_in;
wire    [PRS_FIELD_BUFF_DATA_W-1:0]         parser_field_buff_data_out;
wire    [PRS_FIELD_BUFF_ADDR_W-1:0]         parser_field_buff_len_out;
//Extraction Buffer Partial Output
reg     [PRS_EXT_BUFF_DATA_W-1:0]           parser_ext_buff_data_in;
reg     [PRS_EXT_BUFF_ADDR_W-1:0]           parser_ext_buff_len_in;
wire    [PRS_EXT_BUFF_DATA_W-1:0]           parser_ext_buff_data_out;
wire    [PRS_EXT_BUFF_ADDR_W-1:0]           parser_ext_buff_len_out;

reg     [PRS_OFFSET_BUFF_DATA_W-1:0]        parser_offset_buff_data_in;
reg     [PRS_OFFSET_BUFF_ADDR_W-1:0]        parser_offset_buff_len_in;
wire    [PRS_OFFSET_BUFF_DATA_W-1:0]        parser_offset_buff_data_out;
wire    [PRS_OFFSET_BUFF_ADDR_W-1:0]        parser_offset_buff_len_out;

reg     [PRS_LOOKUP_W-1:0]                  ext_core_lookup_value;
reg                                         ext_core_lookup_valid;

wire    [PRS_LOOKUP_W-1:0]                  ext_core_lookup_value_out;
wire                                        ext_core_lookup_valid_out;

reg     [PRS_LENGTH_W-1:0]                  ext_core_dylen_value;
reg                                         ext_core_dylen_valid;

wire    [PRS_LENGTH_W-1:0]                  ext_core_dylen_value_out;
wire                                        ext_core_dylen_valid_out;

wire                                        ext_core_hold_en_out;
wire                                        ext_core_head_finished_out;

//CORE FSM
reg          [STATE_EXT_W-1:0]              state_prs_ext_core      = STATE_EXT_IDLE;
reg          [PKT_ADDR_W - 1:0]             wr_ptr                  = 0;
reg          [PKT_ADDR_W - 1:0]             rd_ptr                  = 0;

//Packet Processing
reg          [PKT_ADDR_W - 1:0]             pkt_wr_ptr_buf          = 0;
reg          [PKT_ADDR_W - 1:0]             pkt_rd_ptr_buf          = 0;
reg          [PKT_ADDR_W - 1:0]             pkt_rd_base_ptr         = 0;
//reg                                     pkt_started             = 0;
reg          [PRS_COUNT_W-1 :0]             pkt_length              = 0;
reg          [PRS_COUNT_W-1:0]              pkt_data_count          = 0;
reg                                         pkt_started             = 0;

//Header Processing
//reg         [PRS_COUNT_W-1:0]           pkt_head_count      = 0;
//reg                                     pkt_head_started    = 0;+++
//reg                                     pkt_head_finished   = 0; //Have to derived from core finished value

//EXT CORE STATES AND VARIABLES
reg                                         ext_core_en             = 0;
//Buffers
reg    [PRS_OFFSET_W-1:0]                   head_addr_buf           = 0;
reg    [PRS_LOOKUP_W-1:0]                   head_lookup_buf         = 0;
reg                                         head_lookup_valid_buf   = 0;
reg    [PRS_LENGTH_W-1:0]                   head_dylen_buf          = 0;
reg                                         head_dylen_valid_buf    = 0;
//reg                                         parsed                = 0;
wire                                        parsed                  = 0;

//Split Extraction Stages into pipelines
//reg  
wire                                        ext_core_pipe_split_en;
wire    [31:0]                              ext_core_pipe_split_threshold;
reg     [31:0]                              ext_core_pipe_split_count = 0;

//Field Buffer Operations
reg     [PRS_FIELD_BUFF_DATA_W-1:0]         parser_field_buff_data  = 0; 
reg     [PRS_FIELD_BUFF_ADDR_W-1:0]         parser_field_buff_len   = 0;
reg                                         parser_field_buff_valid = 0;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Core Logic Registers
//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
 
assign                                      pkt_buf_rd_en_o         = 1'b1;
assign                                      action_ram_rd_data_en_o = 1'b1;
assign                                      cam_lookup_en_o         = 1'b1;
    
//assign                                      ext_core_data_valid     = 1'b1;
//assign                                      ext_core_data_word      = pkt_buf_rd_data_i;
assign                                      ext_core_action_field   = action_ram_rd_data_i;
assign                                      ext_core_action_length  = action_ram_rd_len_i;

assign                                      parsed                  = (ext_core_head_finished_out)? ((ext_core_lookup_valid_out)? 1'b1: 1'b0) :1'b0;

////Conrol Pipeline Stages - Split Operations
assign ext_core_pipe_split_en                                       = (NUM_OF_EXT_UNITS == NUM_OF_ACT_FIELDS) ? 1'b0 : ( (NUM_OF_EXT_UNITS <= NUM_OF_ACT_FIELDS)? 1'b1 : 1'b0);

assign ext_core_pipe_split_threshold                                = NUM_OF_ACT_FIELDS / NUM_OF_EXT_UNITS;
                 

always@ (posedge clk)begin
    if(!resetn)begin
        //RESET
        action_ram_rd_data_addr_o   <= 0;
        pkt_buf_rd_addr_o           <= 0;
        cam_lookup_data_o           <= 0;     

        state_prs_ext_core          <= STATE_EXT_IDLE;
        pkt_started                 <= 0;
        pkt_rd_base_ptr             <= 0;
        ext_core_en                 <= 0;
        pkt_data_count              <= 0;  
        ext_core_data_count         <= 0;

        ext_core_start_addr         <= 0;

        ext_core_dylen_value        <= 0;
        ext_core_dylen_valid        <= 0;
        ext_core_lookup_value       <= 0;
        ext_core_lookup_valid       <= 0;

        //FIELD BUFFER
        parser_field_buff_data_o    <= 0;
        parser_field_buff_len_o     <= 0;
        parser_field_buff_valid_o   <= 0;

        parser_ext_buff_data_o      <= 0;
        parser_ext_buff_len_o       <= 0;
        parser_ext_buff_valid_o     <= 0;

        parser_offset_buff_data_o   <= 0;
        parser_offset_buff_len_o    <= 0;
        parser_offset_buff_valid_o  <= 0;

        pkt_rd_ptr_buf              <= 0;
        pkt_rd_ptr_buf_o            <= 0;

        parser_pkt_id_o             <= 0;

    end
    else begin
        case(state_prs_ext_core)

            STATE_EXT_IDLE: begin
                
                if(( (pkt_rd_ptr_buf) != pkt_wr_ptr_buf_i)  && (!(programming || prog_en || cam_prog_en)) ) begin   

                        state_prs_ext_core          <= STATE_EXT_INIT;
                        pkt_started                 <= 1'b1;
                        pkt_rd_base_ptr             <= pkt_buf_rd_addr_o;
                        pkt_length                  <= pkt_buf_rd_data_i;//ext_core_data_word; //Word Length
                        pkt_buf_rd_addr_o           <= pkt_buf_rd_addr_o + 1; //Absolute Word Count;

                        action_ram_rd_data_addr_o   <= 0;  // Header ID
                        ext_core_data_word          <= 0;
                        ext_core_data_valid         <= 1'b0;
                        //pkt_head_count              <= 0;
                        //pkt_head_started            <= 1'b1;

                        ext_core_en                 <= 0;
                        pkt_data_count              <= 0;  
                        ext_core_data_count         <= 0;

                        //Extraction Core Pipeline
                        ext_core_start_addr         <= 0;

                        ext_core_dylen_value        <= 0;
                        ext_core_dylen_valid        <= 0;

                        ext_core_lookup_value       <= 0;
                        ext_core_lookup_valid       <= 0;

                        //Pipe Split
                        ext_core_pipe_split_count   <= 0;

                        parser_pkt_id_o             <= parser_pkt_id_o + 1;

                        //Buffers to be filled
                        parser_field_buff_data_in   <= 0;
                        parser_field_buff_len_in    <= 0;

                        parser_ext_buff_data_in     <= 0;
                        parser_ext_buff_len_in      <= 0;

                        parser_offset_buff_data_in   <= 0;
                        parser_offset_buff_len_in    <= 0;

                        //Check whether it is necessary
                        //parser_ext_buff_valid_o     <= 0;
                        //parser_field_buff_valid_o   <= 0;
                end

                        parser_field_buff_data_o    <= 0;
                        parser_field_buff_len_o     <= 0;
                        parser_field_buff_valid_o   <= 0;
                        ext_core_exception_o        <= 1'b0;            
            end

            STATE_EXT_INIT: begin
                ext_core_en                 <= 1;
                pkt_data_count              <= 1;  
                ext_core_data_count         <= 1;

                pkt_data_count              <= pkt_data_count + 1;  
                ext_core_data_count         <= ext_core_data_count + 1;
                ext_core_data_word          <= pkt_buf_rd_data_i;
                ext_core_data_valid         <= 1'b1;                
                state_prs_ext_core          <= STATE_EXT_PKT;
            end

            STATE_EXT_PKT: begin                                                       

                    if(ext_core_hold_en_out)begin //Checking Pipeline Hold Enable

                        if(pkt_data_count < pkt_length)begin

                            pkt_buf_rd_addr_o           <= pkt_buf_rd_addr_o + 1;
                            state_prs_ext_core          <= STATE_EXT_READ;

                            //Stack into Field buffer                             
                            parser_field_buff_data [pkt_data_count*PRS_DATA_W +: PRS_DATA_W] <= pkt_buf_rd_data_i;
                            //Buffer Prvious One into Fielfd Buffer
                            //Push to Field Buffer                           
                     
                            ext_core_data_valid         <= 1'b0;
                            
                        end
                        else begin
                            //This should be a program error compilation error
                            state_prs_ext_core      <= STATE_EXT_FINISH;
                            ext_core_exception_o    <= 1'b1;
                        end

                        //pkt_data_count              <= pkt_data_count + 1;  
                        //ext_core_data_count         <= ext_core_data_count + 1;
                    end
                    else begin

                        //Pipeline Split
                            if(ext_core_head_finished_out)begin //Finishsed one Head , Not real, virtual

                                if(ext_core_pipe_split_count < ext_core_pipe_split_threshold)  begin //Check for Actual Header 
                                                  
                                    ext_core_pipe_split_count   <= ext_core_pipe_split_count + 1;

                                    ext_core_lookup_value       <= ext_core_lookup_value_out;
                                    ext_core_lookup_valid       <= ext_core_lookup_valid_out;

                                    ext_core_dylen_value        <= ext_core_dylen_value_out;
                                    ext_core_dylen_valid        <= ext_core_dylen_valid_out;

                                    ext_core_start_addr         <= ext_core_finish_addr_out;

                                    //Extracted Data
                                    parser_field_buff_data_in   <= parser_field_buff_data_out;
                                    parser_field_buff_len_in    <= parser_field_buff_len_out;

                                    parser_ext_buff_data_in     <= parser_ext_buff_data_out;
                                    parser_ext_buff_len_in      <= parser_ext_buff_len_out;

                                    parser_offset_buff_data_in  <= parser_offset_buff_data_out;
                                    parser_offset_buff_len_in   <= parser_offset_buff_len_out;

                                    /*
                                    head_lookup_buf         <= ext_core_lookup_value_out;
                                    head_lookup_valid_buf   <= ext_core_lookup_valid_out;
                        
                                    head_lookup_buf         <= ext_core_dylen_value_out;
                                    head_lookup_valid_buf   <= ext_core_dylen_valid_out;

                                    head_addr_buf           <= ext_core_finish_addr_out;
                                    */
                                        //Edit to add pipeline stages
                                        //ext_core_head_finished_out 
                                end
                                else begin
                                        //+ if(ext_core_)   
                                        //Then lookUp and transition                  
                    
                                            if(ext_core_lookup_valid_out)begin
                                                //cam_lookup_en_o         <= 1'b1;
                                                cam_lookup_data_o       <= {action_ram_rd_data_addr_o,{(CAM_DATA_W - ACTION_RAM_ADDR_W - ACTION_RAM_ADDR_W- PRS_LOOKUP_W){1'b0}},ext_core_lookup_value_out};
                                                state_prs_ext_core      <= STATE_EXT_PARS; //For CAM LookUp 
                                            end
                                            else begin
                                                //cam_lookup_data_o       <= ext_core_lookup_value_out;
                                                //Should Pass Errors: Without no lookup Value
                                                state_prs_ext_core      <= STATE_EXT_FINISH;
            
                                            end
                
                                            if(ext_core_dylen_valid_out)begin
                                                head_lookup_buf                 <= ext_core_dylen_value_out;
                                            end
                                            else begin
                                                head_lookup_buf                 <= ext_core_dylen_value_out;
                                            end  
                                            
                                                head_addr_buf                   <= ext_core_finish_addr_out;
                        
                                                head_lookup_buf                 <= ext_core_lookup_value_out;
                                                head_lookup_valid_buf           <= ext_core_lookup_valid_out;
                        
                                                head_lookup_buf                 <= ext_core_dylen_value_out;
                                                head_lookup_valid_buf           <= ext_core_dylen_valid_out;

                                                parser_field_buff_data_in       <= parser_field_buff_data_out;
                                                parser_field_buff_len_in        <= parser_field_buff_len_out; 

                                                parser_ext_buff_data_in         <= parser_ext_buff_data_out;
                                                parser_ext_buff_len_in          <= parser_ext_buff_len_out;

                                                parser_offset_buff_data_in      <= parser_offset_buff_data_out;
                                                parser_offset_buff_len_in       <= parser_offset_buff_len_out;
                                end // Check
                                        //+
                                    //No need of above
                            end // RAM HEADER LOOKUP
                        //Pipeline Split
                    end
            end

            STATE_EXT_PARS: begin // Looking Up and Parser Generation
                //Check whether tha Prsed or not
                if(cam_lookup_value_i == {ACTION_RAM_ADDR_W{1'b1}})begin 
                        state_prs_ext_core       <= STATE_EXT_FINISH;
                       // ext_core_start_addr         <= ext_core_finish_addr_out;      
                       ext_core_start_addr       <= 0;                
                end
                else begin
                    //Lookup - shuffle Acion ram
                    state_prs_ext_core          <= STATE_EXT_PKT;                    
                    //action_ram_rd_data_en_o     <= 1'b1; //No need here
                    action_ram_rd_data_addr_o   <= cam_lookup_value_i;
                    ext_core_start_addr         <= ext_core_finish_addr_out;

                end
                //Note
                /* Some cornor cases must be handled 

                1. Words eneded before p4 program
                2. Check the hold on sequence then
                
                */
            end

            STATE_EXT_READ: begin

                    pkt_data_count              <= pkt_data_count + 1;  
                    ext_core_data_count         <= ext_core_data_count + 1;
                    ext_core_data_word          <= pkt_buf_rd_data_i;

                    //Organize into Field Buffer
                    ext_core_data_valid         <= 1'b1;
                    state_prs_ext_core          <= STATE_EXT_PKT;
            end

            STATE_EXT_FINISH: begin
                
                pkt_data_count              <= 0;  
                ext_core_data_count         <= 0;
                pkt_buf_rd_addr_o           <= pkt_rd_base_ptr + pkt_length +1;
                pkt_rd_ptr_buf_o            <= pkt_rd_base_ptr + pkt_length +1; //Update Global Rd Pointer
                pkt_rd_ptr_buf              <= pkt_rd_base_ptr + pkt_length +1;
                state_prs_ext_core          <= STATE_EXT_IDLE;
                ext_core_en                 <= 1'b0;
                ext_core_flush              <= 1'b0;

                parser_ext_buff_data_o      <= parser_ext_buff_data_out;
                parser_ext_buff_len_o       <= parser_ext_buff_len_out;

                parser_field_buff_data_o    <= parser_field_buff_data_out;
                parser_field_buff_len_o     <= parser_field_buff_len_out;

                parser_offset_buff_data_o   <= parser_offset_buff_data_out;
                parser_offset_buff_len_o    <= parser_offset_buff_len_out;


                parser_ext_buff_valid_o     <= 1'b1;
                parser_field_buff_valid_o   <= 1'b1;

                //FILED BUFFER
               /* parser_field_buff_data_o    <= 1;
                parser_field_buff_len_o     <= 1;
                parser_field_buff_valid_o   <= 1;
                */

                parser_ext_buff_valid_o     <= 0;
                parser_field_buff_valid_o   <= 0;

            end

            default: begin

                        action_ram_rd_data_addr_o   <= 0;
                        pkt_buf_rd_addr_o           <= 0;
                        cam_lookup_data_o           <= 0;     
                
                        state_prs_ext_core          <= STATE_EXT_IDLE;
                        pkt_started                 <= 0;
                        pkt_rd_base_ptr             <= 0;
                        ext_core_en                 <= 0;
                        pkt_data_count              <= 0;  
                        ext_core_data_count         <= 0;
                
                        ext_core_start_addr         <= 0;
                
                        ext_core_dylen_value        <= 0;
                        ext_core_dylen_valid        <= 0;
                        ext_core_lookup_value       <= 0;
                        ext_core_lookup_valid       <= 0;
                
                        //FIELD BUFFER
                        parser_field_buff_data_o    <= 0;
                        parser_field_buff_len_o     <= 0;
                        parser_field_buff_valid_o   <= 0;

                        parser_ext_buff_data_o      <= 0;
                        parser_ext_buff_len_o       <= 0;
                        parser_ext_buff_valid_o     <= 0;

                        parser_offset_buff_data_o   <= 0;
                        parser_offset_buff_len_o    <= 0;
                        parser_offset_buff_valid_o  <= 0;
                
                        pkt_rd_ptr_buf              <= 0;
                        pkt_rd_ptr_buf_o            <= 0;

                        parser_pkt_id_o             <= 0;
            end
        endcase
    end
end

sdn_parser_extraction_core 
#(

    .PRS_DATA_W                 (PRS_DATA_W             ),
    .PRS_OFFSET_W               (PRS_OFFSET_W           ),
    .PRS_LENGTH_W               (PRS_LENGTH_W           ),
    .PRS_LOOKUP_W               (PRS_LOOKUP_W           ),
    .ACTION_RAM_DATA_W          (ACTION_RAM_DATA_W      ),
    .ACTION_RAM_ADDR_W          (ACTION_RAM_ADDR_W      ),

    .PRS_EXT_BUFF_DATA_W        (PRS_EXT_BUFF_DATA_W     ),
    .PRS_EXT_BUFF_ADDR_W        (PRS_EXT_BUFF_ADDR_W     ),

    .PRS_FIELD_BUFF_DATA_W      (PRS_FIELD_BUFF_DATA_W  ),
    .PRS_FIELD_BUFF_ADDR_W      (PRS_FIELD_BUFF_ADDR_W  ),
    .PRS_HEAD_ADDR_W            (PRS_HEAD_ADDR_W        ),
    .PRS_HEAD_FIELD_ADDR_W      (PRS_HEAD_FIELD_ADDR_W  ),
    .PRS_OFFSET_BUFF_DATA_W     (PRS_OFFSET_BUFF_DATA_W ),

    .HEAD_FIELD_FLAG_W          (HEAD_FIELD_FLAG_W      ),
    .HEAD_LEN_W                 (HEAD_LEN_W             ),
    .HEAD_FIELD_LEN_W           (HEAD_FIELD_LEN_W       ),
    .HEAD_FIELD_W               (HEAD_FIELD_W           ),
    .NUM_OF_EXT_UNITS           (NUM_OF_EXT_UNITS       ),
    .HEAD_LOOKUP_DATA_W         (HEAD_LOOKUP_DATA_W     )

)
ext_core_block
(

    .clk                     (clk),
    .resetn                  (resetn),

    .ext_core_flush_i        (ext_core_flush),
    .ext_core_head_valid_i   (1'b1),

    .ext_core_data_word_i    (ext_core_data_word),
    .ext_core_data_enable_i  (ext_core_data_valid),
    .ext_core_data_count_i   (ext_core_data_count),

    .ext_core_start_addr_i   (ext_core_start_addr),
    .ext_core_finish_addr_o  (ext_core_finish_addr_out),

    .ext_core_action_field_i (ext_core_action_field),
    .ext_core_action_length_i(ext_core_action_length),
    .ext_core_action_valid_i (ext_core_action_valid),

    //Newly Added
    .parser_field_buff_data_i(parser_field_buff_data_in),
    .parser_field_buff_len_i (parser_field_buff_len_in),
    .parser_field_buff_data_o(parser_field_buff_data_out),
    .parser_field_buff_len_o (parser_field_buff_len_out),

    .parser_ext_buff_data_i  (parser_ext_buff_data_in),
    .parser_ext_buff_len_i   (parser_ext_buff_len_in),
    .parser_ext_buff_data_o  (parser_ext_buff_data_out),
    .parser_ext_buff_len_o   (parser_ext_buff_len_out),

    .parser_offset_buff_data_i  (parser_offset_buff_data_in),
    .parser_offset_buff_len_i   (parser_offset_buff_len_in),
    .parser_offset_buff_data_o  (parser_offset_buff_data_out),
    .parser_offset_buff_len_o   (parser_offset_buff_len_out),

    .ext_core_lookup_value_i (ext_core_lookup_value),
    .ext_core_lookup_valid_i (ext_core_lookup_valid),

    .ext_core_lookup_value_o (ext_core_lookup_value_out),
    .ext_core_lookup_valid_o (ext_core_lookup_valid_out), 

    .ext_core_dylen_value_i  (ext_core_dylen_value),
    .ext_core_dylen_valid_i  (ext_core_dylen_valid),

    .ext_core_dylen_value_o  (ext_core_dylen_value_out),
    .ext_core_dylen_valid_o  (ext_core_dylen_valid_out),

    .ext_core_hold_en_o      (ext_core_hold_en_out),
    .ext_core_head_finished_o(ext_core_head_finished_out)
);


endmodule
