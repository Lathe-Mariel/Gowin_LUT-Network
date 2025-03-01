//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.10.03 (64-bit)
//Part Number: GW5AST-LV138PG484AES
//Device: GW5AST-138
//Device Version: B
//Created Time: Sat Mar  1 15:47:22 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_PLL_dvi your_instance_name(
        .lock(lock), //output lock
        .clkout0(clkout0), //output clkout0
        .clkout1(clkout1), //output clkout1
        .clkin(clkin), //input clkin
        .reset(reset) //input reset
    );

//--------Copy end-------------------
