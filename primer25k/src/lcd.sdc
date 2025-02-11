//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.9.01 (64-bit) 
//Created Time: 2025-02-11 21:32:34
create_clock -name cmos_16bit_clk -period 80 -waveform {0 40} [get_nets {cmos_16bit_clk}]
create_clock -name mem_clk -period 10 -waveform {0 1.25} [get_nets {memory_clk}]
create_clock -name cmos_pclk -period 40 -waveform {0 5} [get_ports {cmos_pclk}] -add
create_clock -name clk -period 20 -waveform {0 18.518} [get_ports {clk}] -add
report_timing -hold -from_clock [get_clocks {clk*}] -to_clock [get_clocks {clk*}] -max_paths 25 -max_common_paths 1
report_timing -setup -from_clock [get_clocks {clk*}] -to_clock [get_clocks {clk*}] -max_paths 25 -max_common_paths 1
