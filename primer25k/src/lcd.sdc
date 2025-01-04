//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.9.01 (64-bit) 
//Created Time: 2025-01-05 01:08:59
create_clock -name mem_clk -period 10 -waveform {0 1.25} [get_nets {memory_clk}]
create_clock -name cmos_pclk -period 10 -waveform {0 5} [get_ports {cmos_pclk}] -add
create_clock -name cmos_vsync -period 1000 -waveform {0 500} [get_ports {cmos_vsync}] -add
create_clock -name clk -period 20 -waveform {0 18.518} [get_ports {clk}] -add
report_timing -hold -from_clock [get_clocks {clk*}] -to_clock [get_clocks {clk*}] -max_paths 25 -max_common_paths 1
report_timing -setup -from_clock [get_clocks {clk*}] -to_clock [get_clocks {clk*}] -max_paths 25 -max_common_paths 1
