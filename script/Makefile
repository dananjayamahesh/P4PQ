# Makefile for compile the Testbench
# Indunil Wanigasooriya
# 19-01-2016

#terminal should be in the work folder

PWD = $(shell pwd)     

## Compiler Options
VLOG = vlog
DPIC_OP = -dpiheader 
VLIB = work

# Test-bench sources
SRC_SV += ../sim/tb_defs.sv ../sim/axis_convertor.v ../sim/ram_r1w1.v 
 
# DPI-C SystemVerilog source
SRC_DPI_SV_0 = ../sim/dpic_if.sv

# Testbench Source
SRC_TB = ../sim/sdn_parser_tb.sv

## Source Header Files
SRC_HDR_0 = $(SRC_DPI_SV_0:.sv=.h)

## Make Rules

all: setup comp

clean:
	rm -rf $(VLIB)

setup: lib glbl

lib:
	vlib $(VLIB)

glbl:
	@echo "TODO : put glbl"     #xilinx file

comp: rtl sv dpihdr cc tb_top

rtl:
	make -f ../script/RTL_Makefile   #have to edit this file

cc: 
	#make -f $(PWD)/../script/CC_Makefile

sv:
	$(VLOG) $(SRC_SV) 

dpihdr:
	$(VLOG) $(DPIC_OP) $(SRC_HDR_0) $(SRC_DPI_SV_0)

tb_top:
	$(VLOG) $(SRC_TB)
