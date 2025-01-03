//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9.01 (64-bit)
//Part Number: GW5A-LV25MG121NES
//Device: GW5A-25
//Device Version: A
//Created Time: Fri Jan  3 22:42:13 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_CLKDIV your_instance_name(
        .clkout(clkout_o), //output clkout
        .hclkin(hclkin_i), //input hclkin
        .resetn(resetn_i), //input resetn
        .calib(calib_i) //input calib
    );

//--------Copy end-------------------
