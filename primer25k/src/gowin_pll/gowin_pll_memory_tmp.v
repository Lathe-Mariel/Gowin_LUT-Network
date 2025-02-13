//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9.01 (64-bit)
//Part Number: GW5A-LV25MG121NES
//Device: GW5A-25
//Device Version: A
//Created Time: Thu Feb 13 01:23:16 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_PLL_memory your_instance_name(
        .lock(lock_o), //output lock
        .clkout0(clkout0_o), //output clkout0
        .clkout1(clkout1_o), //output clkout1
        .clkout2(clkout2_o), //output clkout2
        .clkin(clkin_i) //input clkin
    );

//--------Copy end-------------------
