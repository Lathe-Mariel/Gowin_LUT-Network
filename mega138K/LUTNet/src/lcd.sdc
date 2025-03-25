//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.9.01 (64-bit) 
//Created Time: 2025-03-26 00:37:05
create_clock -name cmos_pclk -period 41.667 -waveform {0 5} [get_ports {cmos_pclk}] -add
create_clock -name cmos_16bit_clk -period 83.333 -waveform {0 41.666} [get_nets {cmos_16bit_clk}] -add
create_clock -name cmos_vsync -period 1000 -waveform {0 500} [get_ports {cmos_vsync}] -add
create_clock -name mem_clk -period 2.5 -waveform {0 1.25} [get_nets {memory_clk}] -add
create_clock -name clk -period 20 -waveform {0 18.518} [get_ports {clk}] -add
report_timing -hold -from_clock [get_clocks {clk*}] -to_clock [get_clocks {clk*}] -max_paths 25 -max_common_paths 1
report_timing -setup -from_clock [get_clocks {clk*}] -to_clock [get_clocks {clk*}] -max_paths 25 -max_common_paths 1
