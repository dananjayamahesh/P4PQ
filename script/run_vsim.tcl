#!/usr/bin/tclsh
# Do file for QuestaSim
# aditha@paraqum.com

#always should be in the work directory
set mypath [pwd]  

# Set-up
# if { [catch {file copy -force -- $mypath/../sim/lapp_rules.list $mypath} errmsg] } {	#no need
#     puts "Error : ${errmsg}"
#     quit -f
# }

# Compilation
make -f $mypath/../script/Makefile

## Simulation
puts "\n-- Start of Simulation --\n"
vsim -coverage -voptargs="+acc" -t 1ps -lib work work.sdn_parser_tb -sv_lib $mypath/../sim/libdpic

# Source waveform config file
do {wave.do}

# Save coverage report
coverage save -code bsf -onexit sdnpar_tb.ucdb

# Set VCD file
vcd file dump.vcd

# Set the window types		#uncomment this if u run in the QuestaSim GUI
#view wave
#view structure
#view signals
log -r /*
vcd add -r /*

# Run the simulation
run -all 

checkpoint

# End
puts "\n-- End of Simulation --\n"

quit -f

