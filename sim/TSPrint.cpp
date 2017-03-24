/*
 * TSPrint.cpp
 *
 *  Created on: May 29, 2015
 *      Author: aditha
 */

#include "header/TSPrint.h"

pthread_mutex_t mutex_print = PTHREAD_MUTEX_INITIALIZER;

void PrintLog(const char *str) {
	pthread_mutex_lock(&mutex_print);
	// Print
	FILE *log_file = NULL;
	log_file = fopen("reptool.log", "a");
	time_t t = time(NULL);
	struct tm tm = *localtime(&t);
	fprintf(log_file, "[%d-%d-%d %d:%d:%d] : %s\n", tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, tm.tm_hour, tm.tm_min, tm.tm_sec, str);
	fclose(log_file);
	pthread_mutex_unlock(&mutex_print);
}
