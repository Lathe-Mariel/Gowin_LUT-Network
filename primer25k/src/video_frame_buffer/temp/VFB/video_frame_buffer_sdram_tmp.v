//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9.01 (64-bit)
//Part Number: GW5A-LV25MG121NES
//Device: GW5A-25
//Device Version: A
//Created Time: Sat Jan  4 23:16:51 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	Video_Frame_Buffer_SDRAM your_instance_name(
		.I_rst_n(I_rst_n_i), //input I_rst_n
		.I_dma_clk(I_dma_clk_i), //input I_dma_clk
		.I_wr_halt(I_wr_halt_i), //input [0:0] I_wr_halt
		.I_rd_halt(I_rd_halt_i), //input [0:0] I_rd_halt
		.I_vin0_clk(I_vin0_clk_i), //input I_vin0_clk
		.I_vin0_vs_n(I_vin0_vs_n_i), //input I_vin0_vs_n
		.I_vin0_de(I_vin0_de_i), //input I_vin0_de
		.I_vin0_data(I_vin0_data_i), //input [15:0] I_vin0_data
		.O_vin0_fifo_full(O_vin0_fifo_full_o), //output O_vin0_fifo_full
		.I_vout0_clk(I_vout0_clk_i), //input I_vout0_clk
		.I_vout0_vs_n(I_vout0_vs_n_i), //input I_vout0_vs_n
		.I_vout0_de(I_vout0_de_i), //input I_vout0_de
		.O_vout0_den(O_vout0_den_o), //output O_vout0_den
		.O_vout0_data(O_vout0_data_o), //output [15:0] O_vout0_data
		.O_vout0_fifo_empty(O_vout0_fifo_empty_o), //output O_vout0_fifo_empty
		.I_sdrc_busy_n(I_sdrc_busy_n_i), //input I_sdrc_busy_n
		.O_sdrc_wr_n(O_sdrc_wr_n_o), //output O_sdrc_wr_n
		.O_sdrc_rd_n(O_sdrc_rd_n_o), //output O_sdrc_rd_n
		.O_sdrc_addr(O_sdrc_addr_o), //output [20:0] O_sdrc_addr
		.O_sdrc_data_len(O_sdrc_data_len_o), //output [7:0] O_sdrc_data_len
		.O_sdrc_data(O_sdrc_data_o), //output [15:0] O_sdrc_data
		.O_sdrc_dqm(O_sdrc_dqm_o), //output [1:0] O_sdrc_dqm
		.I_sdrc_rd_valid(I_sdrc_rd_valid_i), //input I_sdrc_rd_valid
		.I_sdrc_data_out(I_sdrc_data_out_i), //input [15:0] I_sdrc_data_out
		.I_sdrc_init_done(I_sdrc_init_done_i) //input I_sdrc_init_done
	);

//--------Copy end-------------------
