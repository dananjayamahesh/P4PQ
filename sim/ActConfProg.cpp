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

#include "header/ActConfProg.h"

std::queue<long> actram;
int no_heads;
ActConfProg::ActConfProg() {
	//std::cout << "ActConfProg::ActConfProg" << std::endl;
	 std::cout << "ActConfProg" << std::endl;
     no_heads = 0;
	OpenFile();

}

ActConfProg::~ActConfProg() {
 // std::cout << "ActConfProg::_ActConfProg" << std::endl;
}

// Read the next packet of the pcap file

void ActConfProg::Prog() {
	//Prog
	std::cout << "Programming" << std::endl;
}

int ActConfProg::OpenFile() {

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

int ActConfProg::GetNextHead() {

 //std::cout << "ActConfProg::GetNextHead" << std::endl;

 return 0;
}

int ActConfProg::GetNextHeadWord(){

	long word = actram.front();
	actram.pop();
	int wi = (int) word;
	return wi;
}

int ActConfProg::GetNumHeads() {

 //std::cout << "ActConfProg::GetNextHead" << std::endl;

 return no_heads;

}

int ActConfProg::ExtractLength() {

 //std::cout << "ActConfProg::GetNextHead" << std::endl;
	long length = actram.front();
	actram.pop();
	no_heads = (int)length;
	std::cout << "Number of Headers: " << length << std::endl;

 return length;

}

int ActConfProg::ReadFile() {

 	std::ifstream myReadFile;
 	myReadFile.open("/home/dhananjaya/san/repos/P4PQ/actconf.txt");
 	char output[256];
 	if (myReadFile.is_open()) {
 		while (!myReadFile.eof()) {
		
 		   myReadFile >> output;
 		    char * ptr;
 		    long word = strtol(output, &ptr, 2);

 		   //int word = stoi(output, nullptr, 2);
 		   actram.push(word); 

 		   std::cout <<"Integer: "<< word << std::endl;
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
