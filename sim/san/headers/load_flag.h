/*
 *  load_flag.h
 *
 *  Created on: March 14, 2017
 *      Author: sandaruwan
 */

#include <iostream>
#include <string>
#include <string.h>
#include <bitset>
#include <stdio.h>
#include <stdlib.h> 

#define FLAG_WIDTH					1
#define FIELD_LENGTH_ENTRY_WIDTH	9

int load_flag(std::string ram_entry, int index);

std::bitset<FIELD_LENGTH_ENTRY_WIDTH> load_length(std::string ram_entry, int index);