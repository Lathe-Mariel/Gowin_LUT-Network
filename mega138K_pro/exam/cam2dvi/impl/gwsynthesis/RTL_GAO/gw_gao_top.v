module gw_gao(
    \HActive[15] ,
    \HActive[14] ,
    \HActive[13] ,
    \HActive[12] ,
    \HActive[11] ,
    \HActive[10] ,
    \HActive[9] ,
    \HActive[8] ,
    \HActive[7] ,
    \HActive[6] ,
    \HActive[5] ,
    \HActive[4] ,
    \HActive[3] ,
    \HActive[2] ,
    \HActive[1] ,
    \HActive[0] ,
    HA_valid,
    \VActive[15] ,
    \VActive[14] ,
    \VActive[13] ,
    \VActive[12] ,
    \VActive[11] ,
    \VActive[10] ,
    \VActive[9] ,
    \VActive[8] ,
    \VActive[7] ,
    \VActive[6] ,
    \VActive[5] ,
    \VActive[4] ,
    \VActive[3] ,
    \VActive[2] ,
    \VActive[1] ,
    \VActive[0] ,
    VA_valid,
    \fps[7] ,
    \fps[6] ,
    \fps[5] ,
    \fps[4] ,
    \fps[3] ,
    \fps[2] ,
    \fps[1] ,
    \fps[0] ,
    fps_valid,
    \cmos_db[7] ,
    \cmos_db[6] ,
    \cmos_db[5] ,
    \cmos_db[4] ,
    \cmos_db[3] ,
    \cmos_db[2] ,
    \cmos_db[1] ,
    \cmos_db[0] ,
    \cmos_16bit_data[15] ,
    \cmos_16bit_data[14] ,
    \cmos_16bit_data[13] ,
    \cmos_16bit_data[12] ,
    \cmos_16bit_data[11] ,
    \cmos_16bit_data[10] ,
    \cmos_16bit_data[9] ,
    \cmos_16bit_data[8] ,
    \cmos_16bit_data[7] ,
    \cmos_16bit_data[6] ,
    \cmos_16bit_data[5] ,
    \cmos_16bit_data[4] ,
    \cmos_16bit_data[3] ,
    \cmos_16bit_data[2] ,
    \cmos_16bit_data[1] ,
    \cmos_16bit_data[0] ,
    cmos_vsync,
    cmos_href,
    cmos_16bit_clk,
    cmos_16bit_wr,
    init_calib_complete,
    cmos_pclk,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \HActive[15] ;
input \HActive[14] ;
input \HActive[13] ;
input \HActive[12] ;
input \HActive[11] ;
input \HActive[10] ;
input \HActive[9] ;
input \HActive[8] ;
input \HActive[7] ;
input \HActive[6] ;
input \HActive[5] ;
input \HActive[4] ;
input \HActive[3] ;
input \HActive[2] ;
input \HActive[1] ;
input \HActive[0] ;
input HA_valid;
input \VActive[15] ;
input \VActive[14] ;
input \VActive[13] ;
input \VActive[12] ;
input \VActive[11] ;
input \VActive[10] ;
input \VActive[9] ;
input \VActive[8] ;
input \VActive[7] ;
input \VActive[6] ;
input \VActive[5] ;
input \VActive[4] ;
input \VActive[3] ;
input \VActive[2] ;
input \VActive[1] ;
input \VActive[0] ;
input VA_valid;
input \fps[7] ;
input \fps[6] ;
input \fps[5] ;
input \fps[4] ;
input \fps[3] ;
input \fps[2] ;
input \fps[1] ;
input \fps[0] ;
input fps_valid;
input \cmos_db[7] ;
input \cmos_db[6] ;
input \cmos_db[5] ;
input \cmos_db[4] ;
input \cmos_db[3] ;
input \cmos_db[2] ;
input \cmos_db[1] ;
input \cmos_db[0] ;
input \cmos_16bit_data[15] ;
input \cmos_16bit_data[14] ;
input \cmos_16bit_data[13] ;
input \cmos_16bit_data[12] ;
input \cmos_16bit_data[11] ;
input \cmos_16bit_data[10] ;
input \cmos_16bit_data[9] ;
input \cmos_16bit_data[8] ;
input \cmos_16bit_data[7] ;
input \cmos_16bit_data[6] ;
input \cmos_16bit_data[5] ;
input \cmos_16bit_data[4] ;
input \cmos_16bit_data[3] ;
input \cmos_16bit_data[2] ;
input \cmos_16bit_data[1] ;
input \cmos_16bit_data[0] ;
input cmos_vsync;
input cmos_href;
input cmos_16bit_clk;
input cmos_16bit_wr;
input init_calib_complete;
input cmos_pclk;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \HActive[15] ;
wire \HActive[14] ;
wire \HActive[13] ;
wire \HActive[12] ;
wire \HActive[11] ;
wire \HActive[10] ;
wire \HActive[9] ;
wire \HActive[8] ;
wire \HActive[7] ;
wire \HActive[6] ;
wire \HActive[5] ;
wire \HActive[4] ;
wire \HActive[3] ;
wire \HActive[2] ;
wire \HActive[1] ;
wire \HActive[0] ;
wire HA_valid;
wire \VActive[15] ;
wire \VActive[14] ;
wire \VActive[13] ;
wire \VActive[12] ;
wire \VActive[11] ;
wire \VActive[10] ;
wire \VActive[9] ;
wire \VActive[8] ;
wire \VActive[7] ;
wire \VActive[6] ;
wire \VActive[5] ;
wire \VActive[4] ;
wire \VActive[3] ;
wire \VActive[2] ;
wire \VActive[1] ;
wire \VActive[0] ;
wire VA_valid;
wire \fps[7] ;
wire \fps[6] ;
wire \fps[5] ;
wire \fps[4] ;
wire \fps[3] ;
wire \fps[2] ;
wire \fps[1] ;
wire \fps[0] ;
wire fps_valid;
wire \cmos_db[7] ;
wire \cmos_db[6] ;
wire \cmos_db[5] ;
wire \cmos_db[4] ;
wire \cmos_db[3] ;
wire \cmos_db[2] ;
wire \cmos_db[1] ;
wire \cmos_db[0] ;
wire \cmos_16bit_data[15] ;
wire \cmos_16bit_data[14] ;
wire \cmos_16bit_data[13] ;
wire \cmos_16bit_data[12] ;
wire \cmos_16bit_data[11] ;
wire \cmos_16bit_data[10] ;
wire \cmos_16bit_data[9] ;
wire \cmos_16bit_data[8] ;
wire \cmos_16bit_data[7] ;
wire \cmos_16bit_data[6] ;
wire \cmos_16bit_data[5] ;
wire \cmos_16bit_data[4] ;
wire \cmos_16bit_data[3] ;
wire \cmos_16bit_data[2] ;
wire \cmos_16bit_data[1] ;
wire \cmos_16bit_data[0] ;
wire cmos_vsync;
wire cmos_href;
wire cmos_16bit_clk;
wire cmos_16bit_wr;
wire init_calib_complete;
wire cmos_pclk;
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
    .trig0_i(HA_valid),
    .trig1_i(VA_valid),
    .trig2_i(fps_valid),
    .data_i({\HActive[15] ,\HActive[14] ,\HActive[13] ,\HActive[12] ,\HActive[11] ,\HActive[10] ,\HActive[9] ,\HActive[8] ,\HActive[7] ,\HActive[6] ,\HActive[5] ,\HActive[4] ,\HActive[3] ,\HActive[2] ,\HActive[1] ,\HActive[0] ,HA_valid,\VActive[15] ,\VActive[14] ,\VActive[13] ,\VActive[12] ,\VActive[11] ,\VActive[10] ,\VActive[9] ,\VActive[8] ,\VActive[7] ,\VActive[6] ,\VActive[5] ,\VActive[4] ,\VActive[3] ,\VActive[2] ,\VActive[1] ,\VActive[0] ,VA_valid,\fps[7] ,\fps[6] ,\fps[5] ,\fps[4] ,\fps[3] ,\fps[2] ,\fps[1] ,\fps[0] ,fps_valid,\cmos_db[7] ,\cmos_db[6] ,\cmos_db[5] ,\cmos_db[4] ,\cmos_db[3] ,\cmos_db[2] ,\cmos_db[1] ,\cmos_db[0] ,\cmos_16bit_data[15] ,\cmos_16bit_data[14] ,\cmos_16bit_data[13] ,\cmos_16bit_data[12] ,\cmos_16bit_data[11] ,\cmos_16bit_data[10] ,\cmos_16bit_data[9] ,\cmos_16bit_data[8] ,\cmos_16bit_data[7] ,\cmos_16bit_data[6] ,\cmos_16bit_data[5] ,\cmos_16bit_data[4] ,\cmos_16bit_data[3] ,\cmos_16bit_data[2] ,\cmos_16bit_data[1] ,\cmos_16bit_data[0] ,cmos_vsync,cmos_href,cmos_16bit_clk,cmos_16bit_wr,init_calib_complete}),
    .clk_i(cmos_pclk)
);

endmodule
