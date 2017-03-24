/*
 * PacketReader.h
 *
 *  Created on: May 26, 2015
 *      Author: mahesh
 */

#ifndef HEADERS_CAMCONFPROG_H_
#define HEADERS_CAMCONFPROG_H_

#include <vector>
#include <fstream>
#include <stdint.h>

#include "CommonDefs.h"
#include "TSPrint.h"


class CamConfProg {
private:
	int a;

public:
    CamConfProg();
    ~CamConfProg();
    //int open_file(const char* filename);
    int GetNextHead();
    void Prog();
    int OpenFile();
    int ReadFile();
    int ExtractLength();
    int GetNumHeads();
    long GetNextHeadWord();
};


#endif /* HEADERS_ACTCONFPROG_H_ */