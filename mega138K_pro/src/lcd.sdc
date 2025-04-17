//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11.01 (64-bit) 
//Created Time: 2025-04-18 01:55:32
create_clock -name cmos_vsync -period 1000 -waveform {0 500} [get_ports {cmos_vsync}] -add
create_clock -name clk -period 20 -waveform {0 18.518} [get_ports {clk}] -add
create_clock -name cmos_16bit_clk -period 83.333 -waveform {0 41.666} [get_nets {cmos_16bit_clk}] -add
create_clock -name cmos_pclk -period 41.667 -waveform {0 5} [get_ports {cmos_pclk}] -add
create_generated_clock -name serial_clk -source [get_ports {clk}] -master_clock clk -divide_by 4 -multiply_by 26 -add [get_nets {serial_clk}]
create_generated_clock -name video_clk -source [get_nets {serial_clk}] -master_clock serial_clk -divide_by 5 -add [get_nets {video_clk}]
create_generated_clock -name mem_clk -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 8 -add [get_nets {memory_clk}]
set_clock_groups -asynchronous -group [get_clocks {cmos_pclk}] -group [get_clocks {clk}] -group [get_clocks {serial_clk}] -group [get_clocks {mem_clk}]
report_timing -hold -from_clock [get_clocks {clk*}] -to_clock [get_clocks {clk*}] -max_paths 25 -max_common_paths 1
report_timing -setup -from_clock [get_clocks {clk*}] -to_clock [get_clocks {clk*}] -max_paths 25 -max_common_paths 1
