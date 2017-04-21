#include <string>
#include <fstream>

#include <stdlib.h> 
#include <stdio.h>
#include <iostream>
#include <vector>
#include <queue>

#define CURRENT_STATE_RAM_ENTRY_WIDTH	512
#define HEADER_ENTRY_WIDTH				8
#define NEXT_HEADERTYPE_ENTRY_WIDTH		24

#include "header/CamConfProg.h"

std::queue<uint64_t> camram;
int no_entries;
CamConfProg::CamConfProg() {
	//std::cout << "ActConfProg::ActConfProg" << std::endl;
	 std::cout << "CamConfProg" << std::endl;
     no_entries = 0;
	OpenFile();

}

CamConfProg::~CamConfProg() {
 // std::cout << "ActConfProg::_ActConfProg" << std::endl;
}

// Read the next packet of the pcap file

void CamConfProg::Prog() {
	//Prog
	std::cout << "Programming" << std::endl;
}

int CamConfProg::OpenFile() {

	std::cout << "OpenFile" << std::endl; 
	ReadFile();
	ExtractLength();
	Prog();
/*
std::string line;

  std::ifstream myfile ("/home/mahesh/paraqum/repos/sdn_parser_complete/actconf.txt");
  
  if (myfile.is_open())
  {
   
    while ( getline (myfile,line) )
    {
      std::cout << line << '\n';
    }

    
    myfile.close();
  }

  else 
  	std::cout << "Unable to open file"; 
 */

  return 0;

}

int CamConfProg::GetNextHead() {

 //std::cout << "ActConfProg::GetNextHead" << std::endl;

 return 0;
}

long CamConfProg::GetNextHeadWord(){

	long word = camram.front();
	camram.pop();
	long wi =  word;
	std::cout<<wi<< std::endl;
	return wi;
}

int CamConfProg::GetNumHeads() {

 //std::cout << "ActConfProg::GetNextHead" << std::endl;

 return no_entries;

}

int CamConfProg::ExtractLength() {

 //std::cout << "ActConfProg::GetNextHead" << std::endl;
	long length = camram.front();
	camram.pop();
	no_entries = (int)length;
	std::cout << "Number of Headers: " << length << std::endl;

 return length;

}

int CamConfProg::ReadFile() {

 	std::ifstream myReadFile;
 	myReadFile.open("/home/dhananjaya/san/repos/P4PQ/camconf.txt");
 	char output[256];
 	if (myReadFile.is_open()) {
 		while (!myReadFile.eof()) {
		
 		    myReadFile >> output;
 		    char * ptr;
 		    uint64_t word = strtol(output, &ptr, 2);

 		   //int word = stoi(output, nullptr, 2);
 		   camram.push(word); 

 		   std::cout <<"WORD_LONG: "<< word << std::endl;
 		   std::cout<<output<< std::endl;
		
 		}
	}
	myReadFile.close();
	return 0;
}

/*
int main(){
	ActConfProg *a = new ActConfProg();
	return 0;
}
*/
