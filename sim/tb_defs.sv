//Indunil Wanigasooriya
//2016/01/19

`timescale 1ns / 1ps

package tb_defs;
    
    localparam      CLK                 = 4;
    localparam      HALF_CLK            = CLK/2;
    
    localparam      ADDR_W    			= 10;
    localparam      DATA_W    			= 512;
    localparam      KEEP_W    			= DATA_W / 8;
    localparam      EN_W                = DATA_W / 8;
    
    localparam      MAX_PKT_HOLD        = 1;
    localparam      NUM_OF_ITR          = 5;   //50402 = GTPC;   	//= no of pasckets

    
    parameter           PRS_RX_DATA_W           = 512;
    parameter           PRS_RX_KEEP_W           = PRS_RX_DATA_W / 8;

    parameter           PRS_TX_DATA_W           = 512;
    parameter           PRS_TX_KEEP_W           = PRS_TX_DATA_W / 8;

    parameter           PRS_PROG_DATA_W         = 512;
    parameter           PRS_PROG_KEEP_W         = PRS_PROG_DATA_W / 8;


    parameter           ACT_CONF_DATA_W         = 32;
    parameter           ACT_CONF_ADDR_W         = 10;
    parameter           ACT_CONF_KEEP_W         = ACT_CONF_DATA_W / 8;

    parameter           CAM_CONF_DATA_W         = 64;
    parameter           CAM_CONF_ADDR_W         = 10;
    parameter           CAM_CONF_KEEP_W         = CAM_CONF_DATA_W / 8;

    //Field Buffer Paraeters
    parameter           PRS_FIELD_BUFF_DATA_W   = 4096;
    parameter           PRS_FIELD_BUFF_ADDR_W   = 12;

    parameter           PRS_EXT_BUFF_DATA_W     = 4096;
    parameter           PRS_EXT_BUFF_ADDR_W     = 12;

    
    parameter           PRS_HEAD_ADDR_W         = 5; // Should be <= ACT_CONF_ADDR_W;
    parameter           PRS_HEAD_FIELD_ADDR_W   = 5;  //These two felds are depending on othe rparameters, Therefore please check parameter before generate

    parameter           PRS_OFFSET_BUFF_DATA_W  = (1<<(PRS_HEAD_ADDR_W+PRS_HEAD_FIELD_ADDR_W)) * PRS_FIELD_BUFF_ADDR_W;
    parameter           PRS_OFFSET_BUFF_ADDR_W  = 32;

    //Tuple Parameter;
    parameter           PRS_TPL_DATA_W          = 512;
    parameter           PRS_TPL_KEEP_W          = PRS_TPL_DATA_W / 8;
    //parameter           PRS_FIELD_BUFF_DATA_W   = 4096; //already there
    //parameter           PRS_FIELD_BUFF_ADDR_W   = 12;   //already there

    parameter           PRS_DATA_W              = 512;
    parameter           PRS_OFFSET_W            = 32;
    parameter           PRS_LENGTH_W            = 32;
    parameter           PRS_LOOKUP_W            = 32;

    parameter           ACTION_RAM_DATA_W       = 512;
    parameter           ACTION_RAM_ADDR_W       = 9; // Ahould Be equal to 
    parameter           ACTION_RAM_LEN_W        = 32;

    //Theoritically ACTION_RAM_ADDR_W < CAM_ADDR_W;

    parameter           CAM_DATA_W              = 64;
    parameter           CAM_ADDR_W              = 6;
   
    parameter           PRS_ACTION_DATA_W       = 512;
    parameter           PRS_EXT_UNIT_N          = 32;
    parameter           PRS_ACTION_HEAD_W       = 0;
    parameter           PRS_ACTION_FIELD_W      = 16;
    parameter           PRS_EXT_SEG_EN          = 1;
    parameter           PRS_OPTION              = 1;

    parameter           HEAD_FIELD_FLAG_W       = 6;
    parameter           HEAD_LEN_W              = 0;
    parameter           HEAD_FIELD_LEN_W        = 10; // previous
    parameter           HEAD_FIELD_W            = 16; // should be equal to HEAD_FIELD_FLAG_W + HEAD_FIELD_LEN_W = HEAD_FIELD_W;
    parameter           NUM_OF_EXT_UNITS        = 32;
    parameter           HEAD_LOOKUP_DATA_W      = 64;
    parameter           NUM_OF_PIPELINE_STAGES  = 1;
    parameter           MAX_NUM_HEAD_FIELDS     = 32;
    parameter           PKT_ADDR_W              = 10;
    parameter           PKT_DATA_W              = 512;
    parameter           PKT_KEEP_W              = PKT_DATA_W / 8;  //do not modif;

    parameter           ACT_LEN_W               = 32;
    parameter           ACT_WORD_W              = 512;   // 
    parameter           ACT_DATA_W              = ACT_WORD_W + ACT_LEN_W;
    parameter           ACT_ADDR_W              = 8;
    parameter           ACT_KEEP_W              = ACT_DATA_W / 8;

    parameter           PKT_NUM_W               = 64;


    /*localparam      CHNL_L34_BUFID          = 4'h0;
	localparam      CHNL_HTTP_PREP_BUFID    = 4'h1;
	localparam      CHNL_HTTPS_PREP_BUFID   = 4'h2;
	localparam      CHNL_DNS_PREP_BUFID     = 4'h3;
	localparam      CHNL_LAPP_BUFID         = 4'h4;
	localparam      CHNL_DNS_DEC_BUFID      = 4'h5;
	localparam      CHNL_DISCADER_BUFID     = 4'hf;*/
    
endpackage
