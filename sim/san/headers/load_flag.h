/*
 *  load_flag.h
 *
 *  Created on: March 14, 2017
 *      Author: sandaruwan
 */

#include <iostream>
#include <string.h>
#include <bitset>
#include <stdio.h>
#include <stdlib.h> 

#define FLAG_WIDTH					1
#define FIELD_LENGTH_ENTRY_WIDTH	9

using namespace std;

int load_flag(string ram_entry, int index);

bitset<FIELD_LENGTH_ENTRY_WIDTH> load_length(string ram_entry, int index);