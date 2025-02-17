module gw_gao(
    cmos_16bit_wr,
    camera_de,
    sdrc_wr_n,
    sdrc_rd_n,
    \sdram_controller0/O_sdrc_busy_n ,
    \sdram_controller0/O_sdrc_rd_valid ,
    \frameBuffer_SDRAM/O_vout0_fifo_empty ,
    \frameBuffer_SDRAM/O_vin0_fifo_full ,
    cmos_vsync,
    memory_clk45,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input cmos_16bit_wr;
input camera_de;
input sdrc_wr_n;
input sdrc_rd_n;
input \sdram_controller0/O_sdrc_busy_n ;
input \sdram_controller0/O_sdrc_rd_valid ;
input \frameBuffer_SDRAM/O_vout0_fifo_empty ;
input \frameBuffer_SDRAM/O_vin0_fifo_full ;
input cmos_vsync;
input memory_clk45;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire cmos_16bit_wr;
wire camera_de;
wire sdrc_wr_n;
wire sdrc_rd_n;
wire \sdram_controller0/O_sdrc_busy_n ;
wire \sdram_controller0/O_sdrc_rd_valid ;
wire \frameBuffer_SDRAM/O_vout0_fifo_empty ;
wire \frameBuffer_SDRAM/O_vin0_fifo_full ;
wire cmos_vsync;
wire memory_clk45;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(cmos_vsync),
    .data_i({cmos_16bit_wr,camera_de,sdrc_wr_n,sdrc_rd_n,\sdram_controller0/O_sdrc_busy_n ,\sdram_controller0/O_sdrc_rd_valid ,\frameBuffer_SDRAM/O_vout0_fifo_empty ,\frameBuffer_SDRAM/O_vin0_fifo_full }),
    .clk_i(memory_clk45)
);

endmodule
