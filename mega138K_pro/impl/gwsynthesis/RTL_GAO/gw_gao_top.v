module gw_gao(
    cmos_vsync,
    cmos_16bit_wr,
    cmos_href,
    cmd_ready,
    wr_data_en,
    wr_data_rdy,
    rd_data_valid,
    camera_de,
    cmd_en,
    rst_n,
    \tp[15] ,
    \tp[14] ,
    \tp[13] ,
    \tp[12] ,
    \tp[11] ,
    \tp[10] ,
    \tp[9] ,
    \tp[8] ,
    \tp[7] ,
    \tp[6] ,
    \tp[5] ,
    \tp[4] ,
    \tp[3] ,
    \tp[2] ,
    \tp[1] ,
    \tp[0] ,
    \tp_counter[9] ,
    \tp_counter[8] ,
    \tp_counter[7] ,
    \tp_counter[6] ,
    \tp_counter[5] ,
    \tp_counter[4] ,
    \tp_counter[3] ,
    \tp_counter[2] ,
    \tp_counter[1] ,
    \tp_counter[0] ,
    cmos_pclk,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input cmos_vsync;
input cmos_16bit_wr;
input cmos_href;
input cmd_ready;
input wr_data_en;
input wr_data_rdy;
input rd_data_valid;
input camera_de;
input cmd_en;
input rst_n;
input \tp[15] ;
input \tp[14] ;
input \tp[13] ;
input \tp[12] ;
input \tp[11] ;
input \tp[10] ;
input \tp[9] ;
input \tp[8] ;
input \tp[7] ;
input \tp[6] ;
input \tp[5] ;
input \tp[4] ;
input \tp[3] ;
input \tp[2] ;
input \tp[1] ;
input \tp[0] ;
input \tp_counter[9] ;
input \tp_counter[8] ;
input \tp_counter[7] ;
input \tp_counter[6] ;
input \tp_counter[5] ;
input \tp_counter[4] ;
input \tp_counter[3] ;
input \tp_counter[2] ;
input \tp_counter[1] ;
input \tp_counter[0] ;
input cmos_pclk;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire cmos_vsync;
wire cmos_16bit_wr;
wire cmos_href;
wire cmd_ready;
wire wr_data_en;
wire wr_data_rdy;
wire rd_data_valid;
wire camera_de;
wire cmd_en;
wire rst_n;
wire \tp[15] ;
wire \tp[14] ;
wire \tp[13] ;
wire \tp[12] ;
wire \tp[11] ;
wire \tp[10] ;
wire \tp[9] ;
wire \tp[8] ;
wire \tp[7] ;
wire \tp[6] ;
wire \tp[5] ;
wire \tp[4] ;
wire \tp[3] ;
wire \tp[2] ;
wire \tp[1] ;
wire \tp[0] ;
wire \tp_counter[9] ;
wire \tp_counter[8] ;
wire \tp_counter[7] ;
wire \tp_counter[6] ;
wire \tp_counter[5] ;
wire \tp_counter[4] ;
wire \tp_counter[3] ;
wire \tp_counter[2] ;
wire \tp_counter[1] ;
wire \tp_counter[0] ;
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
    .trig0_i(cmos_vsync),
    .data_i({cmos_vsync,cmos_16bit_wr,cmos_href,cmd_ready,wr_data_en,wr_data_rdy,rd_data_valid,camera_de,cmd_en,rst_n,\tp[15] ,\tp[14] ,\tp[13] ,\tp[12] ,\tp[11] ,\tp[10] ,\tp[9] ,\tp[8] ,\tp[7] ,\tp[6] ,\tp[5] ,\tp[4] ,\tp[3] ,\tp[2] ,\tp[1] ,\tp[0] ,\tp_counter[9] ,\tp_counter[8] ,\tp_counter[7] ,\tp_counter[6] ,\tp_counter[5] ,\tp_counter[4] ,\tp_counter[3] ,\tp_counter[2] ,\tp_counter[1] ,\tp_counter[0] }),
    .clk_i(cmos_pclk)
);

endmodule
