
`timescale 1ns / 1ps

package dpic_if;  ////////////////update the en of inforamtion element
    
    import tb_defs::*;
    
    import "DPI-C" function void svReadPkts(
        input int unsigned svCount,
        output int unsigned svError
    );

    import "DPI-C" function void svGetPktCount(
        output int unsigned svPktCount,
        output int unsigned svError
    );

    import "DPI-C" function void svGetPktFrame(
        input int unsigned svFrameAddr,
        output longint unsigned svFrame,
        output int unsigned svPktLen,
        output int unsigned svError
    ); 


    import "DPI-C" function void svGetPktHead(
        input int unsigned svHeadAddr,
        output longint unsigned svHead,
        output int unsigned svHeadLen,
        output int unsigned svHeadError
    ); 
    
    import "DPI-C" function void svActConf(
        input int unsigned svActCount,
        output int unsigned svActError
    );
    import "DPI-C" function void svGetNumHeads(        
        output int unsigned svNum
    );

    import "DPI-C" function void svGetHeadWord(        
        output int unsigned svHeadWord
    );

    import "DPI-C" function void svCamConf(
        input int unsigned svCamCount,
        output int unsigned svCamError
    );
    import "DPI-C" function void svGetNumCamEntries(        
        output int unsigned svNum
    );

    import "DPI-C" function void svGetCamEntry(        
        output longint unsigned svCamEntry
    );

//-----------------------------------------------------------------

    import "DPI-C" function void svRunParser();

    import "DPI-C" function void svGet_field_buffer_word(
        output longint unsigned field_buffer_word
    );

    import "DPI-C" function void svGet_offset_queue_word(
        output longint unsigned offset_queue_word
    );

    import "DPI-C" function void svGet_ext_queue_word(
        output longint unsigned ext_queue_word
    );

    import "DPI-C" function void svGet_hdr_Seq_queue_word(
        output longint unsigned hdr_Seq_queue_word
    );
//-----------------------------------------------------------------

endpackage : dpic_if
