//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11.02 (64-bit) 
//Created Time: 2025-06-17 21:45:11
create_clock -name cmos_vsync -period 1000 -waveform {0 500} [get_ports {cmos_vsync}]
create_clock -name cmos_pclk -period 10 -waveform {0 5} [get_ports {cmos_pclk}]
create_clock -name clk -period 20 -waveform {0 10} [get_ports {clk}]
create_generated_clock -name cmos_in -source [get_ports {clk}] -master_clock clk -divide_by 50 -multiply_by 24 [get_pins {Gowin_PLL_inst/u_pll/PLL_inst/CLKOUT1}]
create_generated_clock -name cmos_16bit -source [get_ports {cmos_pclk}] -master_clock cmos_pclk -divide_by 2 -multiply_by 1 [get_nets {cmos_16bit_clk}]
create_generated_clock -name memory_clk -source [get_ports {clk}] -master_clock clk -multiply_by 6 [get_pins {Gowin_PLL_inst/u_pll/PLL_inst/CLKOUT0}]
create_generated_clock -name serial_clk -source [get_ports {clk}] -master_clock clk -divide_by 4 -multiply_by 26 [get_pins {Gowin_PLL_dvi_inst/u_pll/PLL_inst/CLKOUT0}]
create_generated_clock -name video_clk -source [get_ports {clk}] -master_clock clk -divide_by 20 -multiply_by 26 [get_pins {Gowin_PLL_dvi_inst/u_pll/PLL_inst/CLKOUT1}]
create_generated_clock -name clk_x1 -source [get_nets {memory_clk}] -master_clock memory_clk -divide_by 3 [get_pins {DDR3MI_inst/gw3_top/u_ddr_phy_top/fclkdiv/CLKOUT}]
set_clock_groups -asynchronous -group [get_clocks {clk}] -group [get_clocks {clk_x1}] -group [get_clocks {video_clk}] -group [get_clocks {memory_clk}] -group [get_clocks {cmos_in}] -group [get_clocks {cmos_16bit}] -group [get_clocks {cmos_vsync}] -group [get_clocks {cmos_pclk}]
report_timing -hold -from_clock [get_clocks {clk*}] -to_clock [get_clocks {clk*}] -max_paths 25 -max_common_paths 1
report_timing -setup -from_clock [get_clocks {clk*}] -to_clock [get_clocks {clk*}] -max_paths 25 -max_common_paths 1
