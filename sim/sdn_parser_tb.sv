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

    wire                                        s_actconf_axis_rx_tvalid_i;
    wire            [ACT_CONF_DATA_W-1:0]       s_actconf_axis_rx_tdata_i;
    wire            [ACT_CONF_KEEP_W-1:0]       s_actconf_axis_rx_tkeep_i;
    wire                                        s_actconf_axis_rx_tlast_i;
    wire                                        s_actconf_axis_rx_tready_o;
//CAM
    wire                                        s_camconf_axis_rx_tvalid_i;
    wire            [CAM_CONF_DATA_W-1:0]       s_camconf_axis_rx_tdata_i;
    wire            [CAM_CONF_KEEP_W-1:0]       s_camconf_axis_rx_tkeep_i;
    wire                                        s_camconf_axis_rx_tlast_i;
    wire                                        s_camconf_axis_rx_tready_o;
    //axis tx interface
    wire                                        m_axis_tx_tvalid_o;
    wire            [DATA_W-1:0]                m_axis_tx_tdata_o;
    wire            [KEEP_W-1:0]                m_axis_tx_tkeep_o;
    wire                                        m_axis_tx_tlast_o;
    reg                                         m_axis_tx_tready_i;
    
    wire        [PKT_NUM_W-1:0]                 parser_pkt_id_o;
    wire                                        parser_pkt_valid_o;
    wire                                        parser_pkt_err_o;                                 
    wire        [PRS_FIELD_BUFF_DATA_W-1:0]     parser_field_buff_data_o;
    wire        [PRS_FIELD_BUFF_ADDR_W-1:0]     parser_field_buff_len_o;
    wire                                        parser_field_b;
    wire        [PRS_EXT_BUFF_DATA_W-1:0]       parser_ext_buff_data_o;
    wire        [PRS_EXT_BUFF_ADDR_W-1:0]       parser_ext_buff_len_o;
    wire                                        parser_ext_b;
    wire        [PRS_OFFSET_BUFF_DATA_W-1:0]    parser_offset_buff_data_o;
    wire      [PRS_OFFSET_BUFF_ADDR_W-1:0]      parser_offset_buff_len_o;
    wire                                        parser_offset_buff_valid_o;
    //packetizer interface
    wire                                        parser_axis_tx_tvalid_o;
    wire          [PRS_TX_DATA_W-1:0]           parser_axis_tx_tdata_o;
    wire          [PRS_TX_KEEP_W-1:0]           parser_axis_tx_tkeep_o;
    wire                                        parser_axis_tx_tlast_o;
    reg                                         parser_axis_tx_tready_i;

//---------------------------------------------------------------------------------------------------------------------  
// internal registers and wires
//---------------------------------------------------------------------------------------------------------------------
    
    reg                                      ram_en;
    reg             [KEEP_W-1:0]             ram_wren;
    reg             [ADDR_W-1:0]             ram_wraddr;
    reg             [DATA_W-1:0]             ram_wrdata;
    reg             [ADDR_W-1:0]             ram_wrptr;
    reg             [ADDR_W-1:0]             ram_rdptr;
    reg             [ADDR_W-1:0]             buf_wr_ptr;  //local to the verilog module to convert to axis
    wire            [ADDR_W-1:0]             rd_wr_diff;

    ///ACTION CONF MEM
    reg                                      actconf_ram_en;
    reg             [ACT_CONF_KEEP_W-1:0]    actconf_ram_wren;
    reg             [ACT_CONF_ADDR_W-1:0]    actconf_ram_wraddr;
    reg             [ACT_CONF_DATA_W-1:0]    actconf_ram_wrdata;
    reg             [ACT_CONF_ADDR_W-1:0]    actconf_ram_wrptr;
    reg             [ACT_CONF_ADDR_W-1:0]    actconf_ram_rdptr;
    reg             [ACT_CONF_ADDR_W-1:0]    actconf_buf_wr_ptr;  //local to the verilog module to convert to axis
    wire            [ACT_CONF_ADDR_W-1:0]    actconf_rd_wr_diff;

//CAM 
    reg                                      camconf_ram_en;
    reg             [CAM_CONF_KEEP_W-1:0]    camconf_ram_wren;
    reg             [CAM_CONF_ADDR_W-1:0]    camconf_ram_wraddr;
    reg             [CAM_CONF_DATA_W-1:0]    camconf_ram_wrdata;
    reg             [CAM_CONF_ADDR_W-1:0]    camconf_ram_wrptr;
    reg             [CAM_CONF_ADDR_W-1:0]    camconf_ram_rdptr;
    reg             [CAM_CONF_ADDR_W-1:0]    camconf_buf_wr_ptr;  //local to the verilog module to convert to axis
    wire            [CAM_CONF_ADDR_W-1:0]    camconf_rd_wr_diff;




    reg             [DATA_W-1 : 0]          tmp_data_512;
    reg             [63:0]                  frame_origin;
    reg             [63:0]                  frame_edited;

    reg                                     programming;

    wire                                    ext_core_exception;

//---------------------------------------------------------------------------------------------------------------------
// Instantiate the Design Under Test (DUT)
//---------------------------------------------------------------------------------------------------------------------
    /*always@(frame_origin)begin

        for(int i=0;i<8;i++)begin
            frame_edited[(8-i-1)*8 +: 8] = frame_origin [i*8 +: 8];
        end
    end
    */


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

        ram_en              = 0;
        ram_wren            = 0;
        ram_wraddr          = 0;
        ram_wrdata          = 0;
        ram_wrptr           = 0;
        ram_rdptr           = 0;

        actconf_ram_en     = 0;
        actconf_ram_wren   = 0;
        actconf_ram_wraddr = 0;
        actconf_ram_wrdata = 0;
        actconf_ram_wrptr  = 0;
        actconf_ram_rdptr  = 0;

        camconf_ram_en     = 0;
        camconf_ram_wren   = 0;
        camconf_ram_wraddr = 0;
        camconf_ram_wrdata = 0;
        camconf_ram_wrptr  = 0;
        camconf_ram_rdptr  = 0;


        programming       = 1'b1;

        // Wait 100 ns for global reset to finish
        #100;
        
        @(negedge clk);
        resetn  = 1'b1;
        
        #(CLK*2);

        //fork
            program_cam();
        //join

        //fork
            program_core();
        //join                
            #1000;
             programming       = 1'b0;
        //fork
            load_packets();
        //join

        #15000;
        $finish;
    end


    task program_cam();

        automatic int unsigned cam_len;
        automatic int unsigned cam_count;
        automatic longint unsigned cam_data;
        automatic int unsigned error;
        automatic int unsigned num_cam_entries;

        svCamConf(MAX_PKT_HOLD, error);                                  //1.read packet
        svGetNumCamEntries(num_cam_entries);
        $display("Number of CAM entries : %2d", num_cam_entries);
            //svGetPktHead (0,head_data,head_len,error);
        $display("Program Core : %2d", error);

                @(posedge clk) begin            //load packet into ram, try to change into negedge clk
                        camconf_ram_en = 1;
                        camconf_ram_wren = {CAM_CONF_KEEP_W{1'b1}};
                        camconf_ram_wraddr = (camconf_ram_wrptr + 0);
                        camconf_ram_wrdata = num_cam_entries;
                        $display("WORD : %x  %x",camconf_ram_wrptr, num_cam_entries);
                end

        for (int i = 1; i < num_cam_entries+1; i++) begin 
            automatic longint unsigned word;
            svGetCamEntry(word);
            $display("CAM Entry: : %x", word);

                @(posedge clk) begin            //load packet into ram, try to change into negedge clk
                        camconf_ram_en = 1;
                        camconf_ram_wren = {CAM_CONF_KEEP_W{1'b1}};
                        camconf_ram_wraddr = (camconf_ram_wrptr + i);
                        camconf_ram_wrdata = word;
                        $display("WORD : %x %x %x",camconf_ram_wrptr, i, word);
                end
        end

            @(posedge clk) begin
                    camconf_ram_wrptr += num_cam_entries +1;           
                    camconf_buf_wr_ptr = camconf_ram_wrptr;      //update the wr_ptr to buf reader
                    camconf_ram_en = 0;
                    camconf_ram_wren = 0;
            end 


    endtask : program_cam



    
    task program_core();

        //Program the Action Configuration Core
        automatic int unsigned head_len;
        automatic int unsigned head_count;
        automatic longint unsigned head_data;
        automatic int unsigned error;

         automatic int unsigned num;

            svActConf(MAX_PKT_HOLD, error);                                  //1.read packet
            svGetNumHeads(num);
            $display("Number of Headers : %2d", num);
            //svGetPktHead (0,head_data,head_len,error);
            $display("Program Core : %2d", error);

        for (int i = 0; i < num; i++) begin   

                automatic int unsigned len;
                svGetHeadWord(len);
                $display("HEADLEN : %x", len);

                @(posedge clk) begin            //load packet into ram, try to change into negedge clk
                        actconf_ram_en = 1;
                        actconf_ram_wren = {KEEP_W{1'b1}};
                        actconf_ram_wraddr = (actconf_ram_wrptr + 0);
                        actconf_ram_wrdata = len-1;
                        $display("WORD : %x  %x",actconf_ram_wrptr, len-1);
                end

            for (int j = 1; j < len; j++) begin
                automatic int unsigned word;
                svGetHeadWord(word);


                @(posedge clk) begin            //load packet into ram, try to change into negedge clk
                        actconf_ram_en = 1;
                        actconf_ram_wren = {KEEP_W{1'b1}};
                        actconf_ram_wraddr = (actconf_ram_wrptr + j);
                        actconf_ram_wrdata = word;
                        $display("WORD : %x %x %x",actconf_ram_wrptr, j, word);
                end

            end
            @(posedge clk) begin
                    actconf_ram_wrptr += len;           
                    actconf_buf_wr_ptr = actconf_ram_wrptr;      //update the wr_ptr to buf reader
                    actconf_ram_en = 0;
                    actconf_ram_wren = 0;
            end            
        end  
               /* @(posedge clk) begin
                programming = 1'b0; 
                end
                */ 


    endtask : program_core    
    

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
                $display("Info");

                svGetPktFrame(0, frame, pkt_len, error);                    //3.get a frame from a packet to write to the ram, here used to get the number of frames(64bits) with length+header
                $display("FRAME : %x", frame);
                $display("LEN   : %x", pkt_len);

                if (error != 0) begin
                    $display("Error at svGetPktFrame : %2d", error);
                    $finish;
                end

               //int  num_of_512;
               //int num_of_frames;
              
                    @(posedge clk) begin            //load packet into ram, try to change into negedge clk
                        ram_en = 1;
                        ram_wren = {KEEP_W{1'b1}};
                        ram_wraddr = ram_wrptr;
                        ram_wrdata = {448'b0,((pkt_len-2)/8)+1};   

                        $display("pkt_len : %x %x %x",  pkt_len, pkt_len-1, (pkt_len-1)/8 );
                         $display("Length Write : %x",  ((pkt_len-1)/8) );  
                           
                    end
               //automatic int unsigned num_of_frames = 0;
               //automatic int unsigned  num_of_512 = pkt_len / 8;

                //for (int unsigned addr = 0; addr < pkt_len; addr++) begin
                for (int unsigned addr = 0; addr < (((pkt_len-2) / 8)+1); addr++) begin                    
                    
                    for(int unsigned j=0; j< 8 ; j++)begin                
                                        
                                if(((addr*8)+j) < (pkt_len-1))begin                            
        
                                        svGetPktFrame( (((addr*8)+j)+1), frame, pkt_len, error);             //same as 3.
                                        if (error != 0) begin
                                            $display("Error at svGetPktFrame : %2d", error);
                                            $finish;
                                        end 

                                       //frame_origin = frame; 
        
                                       tmp_data_512 [ ((8-j-1)*64) +: 64] =   frame;
                                        $display("FRAME : %x", frame);
                                end // if(num_of_frames < pkt_len)
                                else begin
        
                                    tmp_data_512 [ ((8-j-1)*64) +: 64] =   64'h0000000000000000;
        
                                end
        
                        // J for Loop    //num_of_frames = num_of_frames + 1;                       
                    end

                            @(posedge clk) begin            //load packet into ram, try to change into negedge clk
                                ram_en = 1;
                                ram_wren = {KEEP_W{1'b1}};
                                ram_wraddr = (ram_wrptr + addr + 1);
                                ram_wrdata =  tmp_data_512; 
                                //ram_wrdata = {448'b0,frame};                                               
                                $display("WORD_512 : %x", tmp_data_512);
                                /*if (addr == 1) begin
                                    rd_hdr = frame;
                                end*/
                            end                       

                    
                end
                @(posedge clk) begin
                    ram_wrptr += (( (pkt_len-2)/8) + 1 + 1);           
                    buf_wr_ptr = ram_wrptr;      //update the wr_ptr to buf reader
                    ram_en = 0;
                    ram_wren = 0;
                end
            end
            else begin
                i = i - 1;
                $display(" err");
            end          
            
            @ (negedge clk)
            m_axis_tx_tready_i = 1'b0;
            ram_rdptr += (((pkt_len-2)/8) + 1 + 1); //pkt_len

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
        .m_axis_tx_tready_i     (s_axis_rx_ready_o),    // earlier  1'b1
        .m_axis_tx_tdata_o      (s_axis_rx_tdata_i),
        .m_axis_tx_tkeep_o      (s_axis_rx_tkeep_i),
        .m_axis_tx_tlast_o      (s_axis_rx_tlast_i)
);


    axis_convertor
    #(
        .DATA_W                 (ACT_CONF_DATA_W),
        .ADDR_W                 (ACT_CONF_ADDR_W)
    )
    actconf_axis_convertor_i
    (
        .clk                    (clk),
        .resetn                 (resetn),

        .wr_ptr_i               (actconf_buf_wr_ptr),
                    
        .en_a_i                 (actconf_ram_en),
        .wren_a_i               (actconf_ram_wren),
        .wraddr_a_i             (actconf_ram_wraddr),
        .wrdata_a_i             (actconf_ram_wrdata),
        
        .m_axis_tx_tvalid_o     (s_actconf_axis_rx_tvalid_i),    
        .m_axis_tx_tready_i     (s_actconf_axis_rx_tready_o),      // earlier  1'b1
        .m_axis_tx_tdata_o      (s_actconf_axis_rx_tdata_i),
        .m_axis_tx_tkeep_o      (s_actconf_axis_rx_tkeep_i),
        .m_axis_tx_tlast_o      (s_actconf_axis_rx_tlast_i)
    );


    axis_convertor
    #(
        .DATA_W                 (CAM_CONF_DATA_W),
        .ADDR_W                 (CAM_CONF_ADDR_W)
    )
    camconf_axis_convertor_i
    (
        .clk                    (clk),
        .resetn                 (resetn),

        .wr_ptr_i               (camconf_buf_wr_ptr),                    
        .en_a_i                 (camconf_ram_en),
        .wren_a_i               (camconf_ram_wren),
        .wraddr_a_i             (camconf_ram_wraddr),
        .wrdata_a_i             (camconf_ram_wrdata),
        
        .m_axis_tx_tvalid_o     (s_camconf_axis_rx_tvalid_i),    
        .m_axis_tx_tready_i     (s_camconf_axis_rx_tready_o),      // earlier  1'b1
        .m_axis_tx_tdata_o      (s_camconf_axis_rx_tdata_i),
        .m_axis_tx_tkeep_o      (s_camconf_axis_rx_tkeep_i),
        .m_axis_tx_tlast_o      (s_camconf_axis_rx_tlast_i)
    );


sdn_parser_top
#(

    .PRS_RX_DATA_W           (PRS_RX_DATA_W           ),
    .PRS_RX_KEEP_W           (PRS_RX_KEEP_W           ),

    .PRS_TX_DATA_W           (PRS_TX_DATA_W           ),
    .PRS_TX_KEEP_W           (PRS_TX_KEEP_W           ),

    .ACT_CONF_DATA_W         (ACT_CONF_DATA_W         ),
    .ACT_CONF_KEEP_W         (ACT_CONF_KEEP_W         ),
    .ACT_CONF_ADDR_W         (ACT_CONF_ADDR_W         ),

    .CAM_CONF_DATA_W         (CAM_CONF_DATA_W         ),
    .CAM_CONF_KEEP_W         (CAM_CONF_KEEP_W         ),

    .PRS_TPL_DATA_W          (PRS_TPL_DATA_W          ),
    .PRS_TPL_KEEP_W          (PRS_TPL_KEEP_W          ),

    //.PRS_FIELD_BUFF_DATA_W   (PRS_FIELD_BUFF_DATA_W   ),
    //.PRS_FIELD_BUFF_ADDR_W   (PRS_FIELD_BUFF_ADDR_W   ),
    .PRS_EXT_BUFF_DATA_W    (PRS_EXT_BUFF_DATA_W      ),
    .PRS_EXT_BUFF_ADDR_W    (PRS_EXT_BUFF_ADDR_W      ),

    .PRS_FIELD_BUFF_DATA_W   (PRS_FIELD_BUFF_DATA_W   ),
    .PRS_FIELD_BUFF_ADDR_W   (PRS_FIELD_BUFF_ADDR_W   ),
    .PRS_HEAD_ADDR_W         (PRS_HEAD_ADDR_W         ),
    .PRS_HEAD_FIELD_ADDR_W   (PRS_HEAD_FIELD_ADDR_W   ),
    .PRS_OFFSET_BUFF_DATA_W  (PRS_OFFSET_BUFF_DATA_W  ),

    .PRS_DATA_W              (PRS_DATA_W              ),
    .PRS_OFFSET_W            (PRS_OFFSET_W            ),
    .PRS_LENGTH_W            (PRS_LENGTH_W            ),
    .PRS_LOOKUP_W            (PRS_LOOKUP_W            ),

    .ACTION_RAM_DATA_W       (ACTION_RAM_DATA_W       ),
    .ACTION_RAM_ADDR_W       (ACTION_RAM_ADDR_W       ),

    .CAM_DATA_W              (CAM_DATA_W              ),
    .CAM_ADDR_W              (CAM_ADDR_W              ),

    .PRS_ACTION_DATA_W       (PRS_ACTION_DATA_W       ),
    .PRS_EXT_UNIT_N          (PRS_EXT_UNIT_N          ),
    .PRS_ACTION_HEAD_W       (PRS_ACTION_HEAD_W       ),
    .PRS_ACTION_FIELD_W      (PRS_ACTION_FIELD_W      ),
    .PRS_EXT_SEG_EN          (PRS_EXT_SEG_EN          ),

    .PRS_OPTION              (PRS_OPTION              ),

    .HEAD_FIELD_FLAG_W       (HEAD_FIELD_FLAG_W        ),
    .HEAD_LEN_W              (HEAD_LEN_W               ),
    .HEAD_FIELD_LEN_W        (HEAD_FIELD_LEN_W         ),
    .HEAD_FIELD_W            (HEAD_FIELD_W             ),
    .NUM_OF_EXT_UNITS        (NUM_OF_EXT_UNITS         ),

    .HEAD_LOOKUP_DATA_W      (HEAD_LOOKUP_DATA_W      ),
    .NUM_OF_PIPELINE_STAGES  (NUM_OF_PIPELINE_STAGES  ),
    .MAX_NUM_HEAD_FIELDS     (MAX_NUM_HEAD_FIELDS     ),


    .ACT_LEN_W              (ACT_LEN_W ),
    .ACT_WORD_W             (ACT_WORD_W),
    .ACT_DATA_W             (ACT_DATA_W),
    .ACT_ADDR_W             (ACT_ADDR_W),
    .ACT_KEEP_W             (ACT_KEEP_W),

    .PKT_NUM_W              (PKT_NUM_W)

)

parser_top_block

(
    .clk                        (clk),
    .resetn                     (resetn),

    .parser_axis_rx_tvalid_i    (s_axis_rx_tvalid_i),
    .parser_axis_rx_tdata_i     (s_axis_rx_tdata_i),
    .parser_axis_rx_tkeep_i     (s_axis_rx_tkeep_i),
    .parser_axis_rx_tlast_i     (s_axis_rx_tlast_i),
    .parser_axis_rx_tready_o    (s_axis_rx_ready_o),    

    //.parser_axis_rx_tdrop_o     (parser_axis_rx_tdrop_o),
    .parser_pkt_id_o    (parser_pkt_id_o),
    .parser_pkt_valid_o (parser_pkt_valid_o),
    .parser_pkt_err_o   (parser_pkt_err_o),

    .parser_field_buff_data_o   (parser_field_buff_data_o),
    .parser_field_buff_len_o    (parser_field_buff_len_o),
    .parser_field_buff_valid_o  (parser_field_buff_valid_o),

    .parser_ext_buff_data_o (parser_ext_buff_data_o),
    .parser_ext_buff_len_o  (parser_ext_buff_len_o),
    .parser_ext_buff_valid_o    (parser_ext_buff_valid_o),
    
    .parser_offset_buff_data_o  (parser_offset_buff_data_o),
    .parser_offset_buff_len_o   (parser_offset_buff_len_o),
    .parser_offset_buff_valid_o (parser_offset_buff_valid_o),

    .parser_axis_tx_tvalid_o    (m_axis_tx_tvalid_o),
    .parser_axis_tx_tdata_o     (m_axis_tx_tdata_o),
    .parser_axis_tx_tkeep_o     (m_axis_tx_tkeep_o),
    .parser_axis_tx_tlast_o     (m_axis_tx_tlast_o),
    .parser_axis_tx_tready_i    (m_axis_tx_ready_i),

    .parser_axis_tuple_tvalid_o (parser_axis_tuple_tvalid_o),
    .parser_axis_tuple_tdata_o  (parser_axis_tuple_tdata_o),
    .parser_axis_tuple_tkeep_o  (parser_axis_tuple_tkeep_o),
    .parser_axis_tuple_tlast_o  (parser_axis_tuple_tlast_o),
    .parser_axis_tuple_tready_i (parser_axis_tuple_tready_i),

    .programming                (programming),
    .actconf_axis_rx_tvalid_i   (s_actconf_axis_rx_tvalid_i),
    .actconf_axis_rx_tdata_i    (s_actconf_axis_rx_tdata_i),
    .actconf_axis_rx_tkeep_i    (s_actconf_axis_rx_tkeep_i),
    .actconf_axis_rx_tlast_i    (s_actconf_axis_rx_tlast_i),
    .actconf_axis_rx_tready_o   (s_actconf_axis_rx_tready_o),

    .camconf_axis_rx_tvalid_i   (s_camconf_axis_rx_tvalid_i),
    .camconf_axis_rx_tdata_i    (s_camconf_axis_rx_tdata_i),
    .camconf_axis_rx_tkeep_i    (s_camconf_axis_rx_tkeep_i),
    .camconf_axis_rx_tlast_i    (s_camconf_axis_rx_tlast_i),
    .camconf_axis_rx_tready_o   (s_camconf_axis_rx_tready_o),

    .ext_core_exception_o       (ext_core_exception)

);



endmodule
