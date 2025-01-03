//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.9.01 (64-bit)
//Part Number: GW5A-LV25MG121NES
//Device: GW5A-25
//Device Version: A
//Created Time: Fri Jan  3 22:42:13 2025

module Gowin_CLKDIV (clkout, hclkin, resetn, calib);

output clkout;
input hclkin;
input resetn;
input calib;

CLKDIV clkdiv_inst (
    .CLKOUT(clkout),
    .HCLKIN(hclkin),
    .RESETN(resetn),
    .CALIB(calib)
);

defparam clkdiv_inst.DIV_MODE = "5";

endmodule //Gowin_CLKDIV
