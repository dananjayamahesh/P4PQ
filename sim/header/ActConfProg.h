/*
 * PacketReader.h
 *
 *  Created on: May 26, 2015
 *      Author: mahesh
 */

#ifndef HEADERS_ACTCONFPROG_H_
#define HEADERS_ACTCONFPROG_H_

#include <vector>
#include <fstream>
#include <stdint.h>

#include "CommonDefs.h"
#include "TSPrint.h"


class ActConfProg {
private:
	int a;

public:
    ActConfProg();
    ~ActConfProg();
    //int open_file(const char* filename);
    int GetNextHead();
    void Prog();
    int OpenFile();
    int ReadFile();
    int ExtractLength();
    int GetNumHeads();
    int GetNextHeadWord();
};


#endif /* HEADERS_ACTCONFPROG_H_ */