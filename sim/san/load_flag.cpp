#include "headers/load_flag.h"

#define FLAG_WIDTH					1
#define FIELD_LENGTH_ENTRY_WIDTH	9

int load_flag(std::string ram_entry, int index){
	char * 	ptr;
	char 	temp_flag[FLAG_WIDTH];
	strcpy(temp_flag, ram_entry.substr(index, FLAG_WIDTH).c_str());
	int		flag 	=	strtol(temp_flag, & ptr, 2);
	return flag;
}

std::bitset<FIELD_LENGTH_ENTRY_WIDTH> load_length(std::string ram_entry, int index){
	char * 	ptr;
	char 	temp_flag[FIELD_LENGTH_ENTRY_WIDTH];
	strcpy(temp_flag, ram_entry.substr(index, FIELD_LENGTH_ENTRY_WIDTH).c_str());
	std::bitset<FIELD_LENGTH_ENTRY_WIDTH> flag 	=	strtol(temp_flag, & ptr, 2);
	return flag;
}