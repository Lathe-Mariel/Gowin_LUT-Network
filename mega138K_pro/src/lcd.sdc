//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11.01 (64-bit) 
//Created Time: 2025-04-20 04:36:35
create_clock -name cmos_vsync -period 10000 -waveform {0 5000} [get_ports {cmos_vsync}] -add
create_clock -name clk -period 20 -waveform {0 18.518} [get_ports {clk}] -add
create_clock -name cmos_pclk -period 8.929 -waveform {0 4.465} [get_ports {cmos_pclk}] -add
create_generated_clock -name clk_x1 -source [get_nets {memory_clk}] -master_clock mem_clk -divide_by 4 -multiply_by 1 [get_pins {DDR3MI_inst/gw3_top/u_ddr_phy_top/fclkdiv/CLKOUT}]
create_generated_clock -name cmos_16bit_clk -source [get_ports {cmos_pclk}] -master_clock cmos_pclk -divide_by 2 [get_nets {cmos_16bit_clk}]
create_generated_clock -name serial_clk -source [get_ports {clk}] -master_clock clk -divide_by 4 -multiply_by 26 -add [get_nets {serial_clk}]
create_generated_clock -name video_clk -source [get_nets {serial_clk}] -master_clock serial_clk -divide_by 5 -add [get_nets {video_clk}]
create_generated_clock -name mem_clk -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 8 -add [get_nets {memory_clk}]
set_clock_groups -asynchronous -group [get_clocks {cmos_pclk}] -group [get_clocks {clk}] -group [get_clocks {serial_clk}] -group [get_clocks {mem_clk}]
report_timing -hold -from_clock [get_clocks {clk*}] -to_clock [get_clocks {clk*}] -max_paths 25 -max_common_paths 1
report_timing -setup -from_clock [get_clocks {clk*}] -to_clock [get_clocks {clk*}] -max_paths 25 -max_common_paths 1
