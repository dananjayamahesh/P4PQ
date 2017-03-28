/* MTI_DPI */

/*
 * Copyright 2002-2013 Mentor Graphics Corporation.
 *
 * Note:
 *   This file is automatically generated.
 *   Please do not edit this file - you will lose your edits.
 *
 * Settings when this file was generated:
 *   PLATFORM = 'linux_x86_64'
 */
#ifndef INCLUDED_DPIC_IF
#define INCLUDED_DPIC_IF

#ifdef __cplusplus
#define DPI_LINK_DECL  extern "C" 
#else
#define DPI_LINK_DECL 
#endif

#include "svdpi.h"



DPI_LINK_DECL DPI_DLLESPEC
void
svActConf(
    unsigned int svActCount,
    unsigned int* svActError);

DPI_LINK_DECL DPI_DLLESPEC
void
svCamConf(
    unsigned int svCamCount,
    unsigned int* svCamError);

DPI_LINK_DECL DPI_DLLESPEC
void
svGetCamEntry(
    uint64_t* svCamEntry);

DPI_LINK_DECL DPI_DLLESPEC
void
svGetHeadWord(
    unsigned int* svHeadWord);

DPI_LINK_DECL DPI_DLLESPEC
void
svGetNumCamEntries(
    unsigned int* svNum);

DPI_LINK_DECL DPI_DLLESPEC
void
svGetNumHeads(
    unsigned int* svNum);

DPI_LINK_DECL DPI_DLLESPEC
void
svGetPktCount(
    unsigned int* svPktCount,
    unsigned int* svError);

DPI_LINK_DECL DPI_DLLESPEC
void
svGetPktFrame(
    unsigned int svFrameAddr,
    uint64_t* svFrame,
    unsigned int* svPktLen,
    unsigned int* svError);

DPI_LINK_DECL DPI_DLLESPEC
void
svGetPktHead(
    unsigned int svHeadAddr,
    uint64_t* svHead,
    unsigned int* svHeadLen,
    unsigned int* svHeadError);

DPI_LINK_DECL DPI_DLLESPEC
void
svGet_ext_queue_word(
    uint64_t* ext_queue_word);

DPI_LINK_DECL DPI_DLLESPEC
void
svGet_field_buffer_word(
    uint64_t* field_buffer_word);

DPI_LINK_DECL DPI_DLLESPEC
void
svGet_hdr_Seq_queue_word(
    uint64_t* hdr_Seq_queue_word);

DPI_LINK_DECL DPI_DLLESPEC
void
svGet_offset_queue_word(
    uint64_t* offset_queue_word);

DPI_LINK_DECL DPI_DLLESPEC
void
svReadPkts(
    unsigned int svCount,
    unsigned int* svError);

DPI_LINK_DECL DPI_DLLESPEC
void
svRunParser();

#endif 