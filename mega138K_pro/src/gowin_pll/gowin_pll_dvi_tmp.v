//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.11 (64-bit)
//Part Number: GW5AST-LV138FPG676AES
//Device: GW5AST-138
//Device Version: B
//Created Time: Fri Jun  6 13:09:39 2025

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
