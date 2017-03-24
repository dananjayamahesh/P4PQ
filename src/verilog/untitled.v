sdn_parser_core
#(
.PRS_RX_DATA_W           (PRS_RX_DATA_W           ),
.PRS_RX_KEEP_W           (PRS_RX_KEEP_W           ),
.PRS_TX_DATA_W           (PRS_TX_DATA_W           ),
.PRS_TX_KEEP_W           (PRS_TX_KEEP_W           ),
.PRS_TPL_DATA_W          (PRS_TPL_DATA_W          ),
.PRS_TPL_KEEP_W          (PRS_TPL_KEEP_W          ),
.PRS_FIELD_BUFFF_DATA_W  (PRS_FIELD_BUFFF_DATA_W  ),
.PRS_FIELD_BUFFF_ADDR_W  (PRS_FIELD_BUFFF_ADDR_W  ),
.PRS_DATA_W              (PRS_DATA_W              ),
.PRS_OFFSET_W 			 (PRS_OFFSET_W 			  ),
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
.PRS_OPTION              (PRS_OPTION              )

)
block
(
.clk	(clk),
.resetn	(resetn),
.parser_axis_rx_tvalid_i	(parser_axis_rx_tvalid_i),
.parser_axis_rx_tdata_i	(parser_axis_rx_tdata_i),
.parser_axis_rx_tkeep_i	(parser_axis_rx_tkeep_i),
.parser_axis_rx_tlast_i	(parser_axis_rx_tlast_i),
.parser_axis_rx_tready_o	(parser_axis_rx_tready_o),
.parser_axis_rx_tdrop_o	(parser_axis_rx_tdrop_o),
.parser_field_buff_data_o	(parser_field_buff_data_o),
.parser_field_buff_len_o	(parser_field_buff_len_o),
.parser_field_buff_valid_o	(parser_field_buff_valid_o),
.parser_axis_tx_tvalid_o	(parser_axis_tx_tvalid_o),
.parser_axis_tx_tdata_o	(parser_axis_tx_tdata_o),
.parser_axis_tx_tkeep_o	(parser_axis_tx_tkeep_o),
.parser_axis_tx_tlast_o	(parser_axis_tx_tlast_o),
.parser_axis_tx_tready_i	(parser_axis_tx_tready_i),
.parser_axis_tuple_tvalid_o	(parser_axis_tuple_tvalid_o),
.parser_axis_tuple_tdata_o	(parser_axis_tuple_tdata_o),
.parser_axis_tuple_tkeep_o	(parser_axis_tuple_tkeep_o),
.parser_axis_tuple_tlast_o	(parser_axis_tuple_tlast_o),
.parser_axis_tuple_tready_i	(parser_axis_tuple_tready_i)

);



.PRS_RX_DATA_W            (PRS_RX_DATA_W          ),
.PRS_RX_KEEP_W            (PRS_RX_KEEP_W          ),
.PRS_PROG_DATA_W          (PRS_PROG_DATA_W        ),
.PRS_PROG_KEEP_W          (PRS_PROG_KEEP_W        ),
.PRS_FIELD_BUFF_DATA_W    (PRS_FIELD_BUFF_DATA_W  ),
.PRS_FIELD_BUFFF_ADDR_W   (PRS_FIELD_BUFFF_ADDR_W ),
.PRS_DATA_W               (PRS_DATA_W             ),
.PRS_OFFSET_W             (PRS_OFFSET_W           ),
.PRS_LENGTH_W             (PRS_LENGTH_W           ),
.PRS_LOOKUP_W             (PRS_LOOKUP_W           ),
.ACTION_RAM_DATA_W        (ACTION_RAM_DATA_W      ),
.ACTION_RAM_ADDR_W        (ACTION_RAM_ADDR_W      ),
.CAM_DATA_W               (CAM_DATA_W             ),
.CAM_ADDR_W               (CAM_ADDR_W             ),
.HEAD_LEN_W               (HEAD_LEN_W             ),
.HEAD_FIELD_LEN_W         (HEAD_FIELD_LEN_W       ),
.HEAD_FIELD_W             (HEAD_FIELD_W           ),
.NUM_OF_EXT_UNITS         (NUM_OF_EXT_UNITS       ),
.HEAR_LOOKUP_DATA_W       (HEAR_LOOKUP_DATA_W     )


.clk (clk),
.resetn (resetn),
.parser_axis_rx_tvalid_i (parser_axis_rx_tvalid_i),
.parser_axis_rx_tdata_i (parser_axis_rx_tdata_i),
.parser_axis_rx_tkeep_i (parser_axis_rx_tkeep_i),
.parser_axis_rx_tlast_i (parser_axis_rx_tlast_i),
.parser_axis_rx_tready_o (parser_axis_rx_tready_o),
.parser_axis_rx_tdrop_o (parser_axis_rx_tdrop_o),
.parser_field_buff_data_o (parser_field_buff_data_o),
.parser_field_buff_len_o (parser_field_buff_len_o),
.parser_field_buff_valid_o (parser_field_buff_valid_o),
.action_ram_rd_data_en_o (action_ram_rd_data_en_o),
.action_ram_rd_data_addr_o (action_ram_rd_data_addr_o),
.action_ram_rd_data_i (action_ram_rd_data_i),
.cam_lookup_en_o (cam_lookup_en_o),
.cam_lookup_data_o (cam_lookup_data_o),
.cam_lookup_addr_i   (cam_lookup_addr_i  )



.clk,
.resetn,
.ext_pkt_start_i,
.ext_pkt_finish_i,    
.ext_header_start_i,        
.ext_pkt_data_i,
.ext_action_data_i,
.ext_pkt_data_fetch_en_o,
.ext_action_data_fetch_o,
.ext_header_finished_o,
.ext_header_lookup_data_o



//////////////////


sdn_parser_extraction_unit
#(
.EXT_UNIT_ID             (EXT_UNIT_ID             ),
.PRS_DATA_W              (PRS_DATA_W              ),
.PRS_OFFSET_W            (PRS_OFFSET_W            ),
.PRS_LENGTH_W            (PRS_LENGTH_W            ),
.PRS_LOOKUP_W            (PRS_LOOKUP_W            ),
.PRS_COUNT_W             (PRS_COUNT_W             ),
.HEAD_LEN_W              (HEAD_LEN_W              ),
.HEAD_FIELD_LEN_W        (HEAD_FIELD_LEN_W        ),
.HEAD_FIELD_W            (HEAD_FIELD_W            ),
.NUM_OF_EXT_UNITS        (NUM_OF_EXT_UNITS        ),
.HEAR_LOOKUP_DATA_W      (HEAR_LOOKUP_DATA_W      )
)
block
(

.clk							(clk)
.resetn							(resetn)
.ext_unit_en_i					(ext_unit_en_i)
.ext_unit_header_start_i		(ext_unit_header_start_i)
.ext_unit_header_finish_i		(ext_unit_header_finish_i)
.ext_unit_flip_state_i			(ext_unit_flip_state_i)
.ext_unit_header_valid_i		(ext_unit_header_valid_i)
.ext_unit_header_id_i			(ext_unit_header_id_i)
.ext_unit_flip_i				(ext_unit_flip_i)
.ext_unit_hold_extdata_i		(ext_unit_hold_extdata_i)
.ext_unit_data_valid_i			(ext_unit_data_valid_i)
.ext_unit_data_i				(ext_unit_data_i)
.ext_unit_data_count_i			(ext_unit_data_count_i)
.ext_unit_word_addr_i 			(ext_unit_word_addr_i )
.ext_unit_addr_start_i			(ext_unit_addr_start_i)
.ext_unit_field_info_i			(ext_unit_field_info_i)
.ext_unit_addr_finish_o   		(ext_unit_addr_finish_o   )
.ext_unit_field_offset_o  		(ext_unit_field_offset_o  )
.ext_unit_hold_en_i				(ext_unit_hold_en_i)
.ext_unit_hold_en_o				(ext_unit_hold_en_o)
.ext_unit_hold_pipe_en_o		(ext_unit_hold_pipe_en_o)
.ext_unit_field_data_o			(ext_unit_field_data_o)
.ext_unit_field_len_o			(ext_unit_field_len_o)
.ext_unit_dylen_en_o			(ext_unit_dylen_en_o)
.ext_unit_dylen_o				(ext_unit_dylen_o)
.ext_unit_lookup_en_o			(ext_unit_lookup_en_o)
.ext_unit_lookup_o				(ext_unit_lookup_o)

);
            

sdn_parser_extraction_core 
#(

.PRS_DATA_W          		(PRS_DATA_W          ),
.PRS_OFFSET_W       		(PRS_OFFSET_W       ),
.PRS_LENGTH_W       		(PRS_LENGTH_W       ),
.PRS_LOOKUP_W       		(PRS_LOOKUP_W       ),
.ACTION_RAM_DATA_W   		(ACTION_RAM_DATA_W   ),
.ACTION_RAM_ADDR_W     		(ACTION_RAM_ADDR_W      ),
.HEAD_LEN_W        			(HEAD_LEN_W        ),
.HEAD_FIELD_LEN_W   		(HEAD_FIELD_LEN_W   ),
.HEAD_FIELD_W       		(HEAD_FIELD_W       ),
.NUM_OF_EXT_UNITS   		(NUM_OF_EXT_UNITS   ),
.HEAR_LOOKUP_DATA_W			(HEAR_LOOKUP_DATA_W)
)

ext_core_blobk
(

.clk 						(clk),
.resetn 					(resetn),
.ext_pkt_start_i 			(ext_pkt_start_i),
.ext_pkt_finish_i   		(ext_pkt_finish_i   ),
.ext_header_start_i      	(ext_header_start_i      ),
.ext_pkt_data_i 			(ext_pkt_data_i),
.ext_action_data_i 			(ext_action_data_i),
.ext_pkt_data_fetch_en_o	(ext_pkt_data_fetch_en_o),
.ext_action_data_fetch_o	(ext_action_data_fetch_o),
.ext_header_finished_o  	(ext_header_finished_o),
.ext_header_lookup_data_o   (ext_header_lookup_data_o  )

);

.clk 					(clk,),
.resetn 				(resetn,),
.ext_core_data_word_i 	(ext_core_data_word_i,),
.ext_core_data_enable_i (ext_core_data_enable_i,),
.ext_core_start_addr_i 	(ext_core_start_addr_i,),
.ext_core_finish_addr_o (ext_core_finish_addr_o,),
.ext_core_action_field_i (ext_core_action_field_i,),
.ext_core_lookup_value_i (ext_core_lookup_value_i,),
.ext_core_lookup_valid_i (ext_core_lookup_valid_i,),
.ext_core_lookup_value_o (ext_core_lookup_value_o,),
.ext_core_lookup_valid_o (ext_core_lookup_valid_o, ) 
.ext_core_dylen_value_i (ext_core_dylen_value_i,),
.ext_core_dylen_valid_i (ext_core_dylen_valid_i,),
.ext_core_dylen_value_o (ext_core_dylen_value_o,),
.ext_core_dylen_valid_o (ext_core_dylen_valid_o,),
.ext_core_hold_en_o 	(ext_core_hold_en_o,),
.ext_core_head_finished_o (ext_core_head_finished_o)



   // wire                                       clk,
   // wire                                       resetn,
   //Extraction Word
   /* wire                                       ext_pkt_start_i;
    wire                                       ext_pkt_finish_i;   
    wire                                       ext_header_start_i;        
    wire     [PRS_DATA_W-1:0]                  ext_pkt_data_i;
    wire     [ACTION_RAM_DATA_W-1:0]           ext_action_data_i;

    wire                                      ext_pkt_data_fetch_en_o;
    wire                                      ext_action_data_fetch_o;

    wire                                      ext_header_finished_o;
    wire    [HEAD_LOOKUP_DATA_W-1:0]          ext_header_lookup_data_o;
*/






    always@(*)begin
        if(!resetn)begin
          //RESET          
        end
        else begin
            if(ext_unit_en_i)begin
                if(!ext_unit_hold_extdata_i)begin
                    if(flag_enable)begin
                        if(!ext_unit_hold_en_i)begin
                            if( data_underflow) begin
    
                                    ext_unit_field_offset_o         <=  ext_unit_addr_start_i;
                                    ext_unit_addr_finish_o          <=  ext_unit_addr_start_i + field_length;
                                    ext_unit_field_data_shifted     <=  ext_unit_data_i >> (PRS_DATA_W - (ext_unit_addr_finish_o % PRS_DATA_W)-1 ) ;
                                    ext_unit_field_data_o           <=  ext_unit_field_data_shifted & ((1 << field_length)-1); //[0 +: field_length ]


                                //LookUp Value
                                if(flag_lookup)begin
                                    ext_unit_lookup_o           <= ext_unit_field_data_o;
                                    ext_unit_lookup_en_o        <= 1'b1;
                                end
                                else begin
                                    if(ext_unit_lookup_en_i)begin
                                        ext_unit_lookup_o       <= ext_unit_lookup_i;
                                        ext_unit_lookup_en_o    <= 1'b1;
                                    end
                                    else begin
                                        ext_unit_lookup_o       <= 0;
                                        ext_unit_lookup_en_o    <= 0;
                                    end
                                end

                                //dynamic length
                                if(flag_dyn_fld_len)begin
                                    ext_unit_dylen_o           <= ext_unit_field_data_o;
                                    ext_unit_dylen_en_o        <= 1'b1;
                                end
                                else begin
                                    if(ext_unit_dylen_en_i)begin
                                        if(flag_dynamic)begin                                        
                                            ext_unit_dylen_o        <= 0;
                                            ext_unit_dylen_en_o     <= 1'b0;
                                        end
                                        else begin
                                            ext_unit_dylen_o       <= ext_unit_dylen_i;
                                            ext_unit_dylen_en_o    <= 1'b1;
                                        end                                        
                                    end
                                    else begin
                                        ext_unit_dylen_o       <= 0;
                                        ext_unit_dylen_en_o    <= 0;
                                    end
                                end

                            end
                            else begin
                                //Check for Buffering                            
                                v_ext_length                    <=  (ext_unit_data_count_i * PRS_DATA_W) - ext_unit_addr_start_i ;
                                v_field_length                  <=  field_length - v_ext_length ; 
                                v_ext_unit_addr_start           <=  ext_unit_data_count_i * PRS_DATA_W ;
                                v_hold_on                       <=  1'b1; 
                                //v_data [0 +: v_ext_length]      <=  ext_unit_field_data_shifted & ((1 << v_ext_length)-1);  
                                v_data                          <=  ext_unit_field_data_shifted & ((1 << v_ext_length)-1);
                                ext_unit_addr_finish_o          <=  ext_unit_addr_start_i + field_length ;                                 
                                ext_unit_hold_pipe_en_o         <=  1'b1;  
                                ext_unit_hold_en_o              <=  1'b1;  //Special for others           
                                                          
                                //Hold Condition
                            end ////Condition for Within Extraction
                        end // Check for Previous Exctractions
                        else begin
                            ext_unit_hold_en_o          <= ext_unit_hold_en_i;
                            ext_unit_field_offset_o     <= ext_unit_addr_start_i;
                            ext_unit_addr_finish_o      <= ext_unit_addr_start_i;
                        end
                        //
                    end
                    else begin
                        ext_unit_field_offset_o     <= ext_unit_addr_start_i;
                        ext_unit_addr_finish_o      <= ext_unit_addr_start_i;
                    end // flag_enable
                end
                else begin
                    //Resolve Native Hold On
                    if(v_hold_on)begin
                        if( (v_ext_unit_addr_start + v_field_length -1)     <= (ext_unit_data_count_i * PRS_DATA_W -1)) begin

                            ext_unit_hold_pipe_en_o                         <= 1'b0;
                            ext_unit_hold_en_o                              <= 1'b0;
                            ext_unit_field_data_shifted                     <= ext_unit_data_i >> (PRS_DATA_W - (ext_unit_addr_finish_o % PRS_DATA_W)-1 ) ;
                            //Check dont comment
                            //v_data [v_ext_length +: v_field_length]         <=  ext_unit_field_data_shifted & ((1 << v_field_length)-1); 


                            if(flag_lookup)begin
                                    ext_unit_lookup_o           <= ext_unit_field_data_o;
                                    ext_unit_lookup_en_o        <= 1'b1;
                            end
                            else begin
                                if(ext_unit_lookup_en_i)begin
                                    ext_unit_lookup_o       <= ext_unit_lookup_i;
                                    ext_unit_lookup_en_o    <= 1'b1;
                                end
                                else begin
                                    ext_unit_lookup_o       <= 0;
                                    ext_unit_lookup_en_o    <= 0;
                                end
                            end

                            if(flag_dyn_fld_len)begin
                                    ext_unit_dylen_o           <= ext_unit_field_data_o;
                                    ext_unit_dylen_en_o        <= 1'b1;
                            end
                            else begin
                                if(ext_unit_dylen_en_i)begin
                                    if(flag_dynamic)begin                                        
                                        ext_unit_dylen_o        <= 0;
                                        ext_unit_dylen_en_o     <= 1'b0;
                                    end
                                    else begin
                                        ext_unit_dylen_o       <= ext_unit_dylen_i;
                                        ext_unit_dylen_en_o    <= 1'b1;
                                    end                                        
                                end
                                else begin
                                    ext_unit_dylen_o       <= 0;
                                    ext_unit_dylen_en_o    <= 0;
                                end
                            end


                        end
                        else begin

                            //This can be avoided by the Micro-instruction architecture <= 128
                        end

                    end
                    else begin

                    end //If this is the unit of Hold On

                end //Hold Extracted Data
            end
            else begin

            end // enable the unit
        end
    end


/*
//test logic
    always@(posedge clk)begin
        if(!resetn)begin

        end
        else begin
            if(count < 1000)begin
                count = count + 1;
                if(ext_unit_data_valid_i)begin
                     ext_unit_lookup_o <= count;
                     ext_unit_dylen_o <=  count;

                end
                else begin
                     ext_unit_lookup_o <= 0;
                     ext_unit_dylen_o <=  0;
                end
            end
            else begin
                count = 0 ;
            end
        end
    end
*/
always@(posedge clk)begin
    if(!resetn)begin
            //RESET
    end
    else begin
       v_hold_on        <=          ext_unit_hold_en_o;
    end
end




//---------------------------------------------------------------------------------------------------------------------
    
    input                                               clk,
    input                                               resetn,

    input                                               ext_unit_en_i,

    //input                                       ext_unit_header_start_i,
    //input                                       ext_unit_header_finish_i,

    //State of Action and Word Transition
    input           [1:0]                               ext_unit_flip_state_i,

    input                                               ext_unit_header_valid_i,
    input           [PRS_COUNT_W-1:0]                   ext_unit_header_id_i,

    //Flip ?
    input                                               ext_unit_flip_i,
    input                                               ext_unit_hold_extdata_i,

    input                                               ext_unit_data_valid_i,
    input           [PRS_DATA_W-1:0]                    ext_unit_data_i,
    input           [PRS_COUNT_W-1:0]                   ext_unit_data_count_i,
    input           [PRS_OFFSET_W-1:0]                  ext_unit_word_addr_i,  //Can be derived from the counter

    input           [PRS_OFFSET_W-1:0]                  ext_unit_addr_start_i, //Absolute
    input           [HEAD_FIELD_W-1:0]                  ext_unit_field_info_i,
    output          [PRS_OFFSET_W-1:0]                  ext_unit_addr_finish_o,    

    //
    output          [PRS_OFFSET_W-1:0]                  ext_unit_field_offset_o, 
    output          [PRS_DATA_W-1:0]                    ext_unit_field_data_o,
    output          [PRS_LENGTH_W-1:0]                  ext_unit_field_len_o,  
    output                                              ext_unit_field_data_valid_o,

    input                                               ext_unit_hold_en_i,
    output                                              ext_unit_hold_en_o,
    output                                              ext_unit_hold_pipe_en_o,

   //Tuples Extracted for Field Buffer


   //Field For Dynamic Length
    output                                              ext_unit_dylen_en_o,
    output          [PRS_LENGTH_W-1:0]                  ext_unit_dylen_o,

    input                                               ext_unit_dylen_en_i,
    input           [PRS_LENGTH_W-1:0]                  ext_unit_dylen_i,

   //LookUp Value
    output                                              ext_unit_lookup_en_o,
    output          [PRS_LOOKUP_W-1:0]                  ext_unit_lookup_o,

    input                                               ext_unit_lookup_en_i,
    input           [PRS_LOOKUP_W-1:0]                  ext_unit_lookup_i

);




    /*
    .parser_axis_rx_tvalid_i    (parser_axis_rx_tvalid_i),
    .parser_axis_rx_tdata_i     (parser_axis_rx_tdata_i),
    .parser_axis_rx_tkeep_i     (parser_axis_rx_tkeep_i),
    .parser_axis_rx_tlast_i     (parser_axis_rx_tlast_i),
    .parser_axis_rx_tready_o    (parser_axis_rx_tready_o),
    .parser_axis_rx_tdrop_o     (parser_axis_rx_tdrop_o),
    */