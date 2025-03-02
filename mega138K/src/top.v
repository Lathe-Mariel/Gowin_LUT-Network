//`default_nettype none

module top(
	input wire               clk,
	input wire               rst_n,
	inout wire               cmos_scl,          //cmos i2c clock
	inout wire               cmos_sda,          //cmos i2c data
	input wire               cmos_vsync,        //cmos vsync
	input wire               cmos_href,         //cmos hsync refrence,data valid
	input wire               cmos_pclk,         //cmos pxiel clock
    output wire              cmos_xclk,         //cmos externl clock 
	input wire[7:0]          cmos_db,           //cmos data
	output wire              cmos_rst_n,        //cmos reset 
	output wire              cmos_pwdn,         //cmos power down
	
//	output [4:0] 				state_led,

	output wire[15:0]        ddr_addr,         //ROW_WIDTH=16
	output wire[3-1:0]       ddr_bank,         //BANK_WIDTH=3
	output wire              ddr_cs,
	output wire              ddr_ras,
	output wire              ddr_cas,
	output wire              ddr_we,
	output wire              ddr_ck,
	output wire              ddr_ck_n,
	output wire              ddr_cke,
	output wire              ddr_odt,
	output wire              ddr_reset_n,
	output wire[3:0]         ddr_dm,         //DM_WIDTH=4
	inout wire[31:0]         ddr_dq,         //DQ_WIDTH=32
	inout wire[3:0]          ddr_dqs,        //DQS_WIDTH=4
	inout wire[3:0]          ddr_dqs_n,      //DQS_WIDTH=4

    output wire       O_tmds_clk_p    ,
    output wire       O_tmds_clk_n    ,
    output wire[2:0]  O_tmds_data_p   ,//{r,g,b}
    output wire[2:0]  O_tmds_data_n   
);

//memory interface
wire                   memory_clk         ;
wire                   DDR_pll_lock           ;

//According to IP parameters to choose
`define	    RD_VIDEO_WIDTH_16
`define	DEF_RD_VIDEO_WIDTH 16

`define	USE_THREE_FRAME_BUFFER

`define	DEF_ADDR_WIDTH 29 
`define	DEF_SRAM_DATA_WIDTH 256
//
//=========================================================
//SRAM parameters
parameter ADDR_WIDTH          = `DEF_ADDR_WIDTH;    //{rank[0],bank[2:0],row[13:0],cloumn[9:0]}
parameter DATA_WIDTH          = `DEF_SRAM_DATA_WIDTH;   //
  
parameter RD_VIDEO_WIDTH      = `DEF_RD_VIDEO_WIDTH;  

wire                      video_clk;         //video pixel clock
//-------------------
//syn_code
wire                      syn_off0_re;  // ofifo read enable signal
wire                      syn_off0_vs;
wire                      syn_off0_hs;
                          
wire                      off0_syn_de  ;
wire [RD_VIDEO_WIDTH-1:0] off0_syn_data;

wire[15:0]                cmos_16bit_data;
wire                      cmos_16bit_clk;
wire[15:0] 			      write_data;

wire[9:0]                 lut_index;
wire[31:0]                lut_data;

wire cmos_clk;
logic cmos_16bit_wr;
logic camera_de;

assign cmos_xclk  = cmos_clk;
assign cmos_pwdn  = 1'b0;
assign cmos_rst_n = 1'b1;
assign write_data = {cmos_16bit_data[4:0],cmos_16bit_data[10:5],cmos_16bit_data[15:11]};

//状态指示灯
//assign state_led[2] = lcd_vs_cnt[4];
//assign state_led[1] = rst_n; //复位指示灯
//assign state_led[0] = init_calib_complete; //DDR3初始化指示灯

reg [4:0] lcd_vs_cnt;
always@(posedge lcd_vs) lcd_vs_cnt <= lcd_vs_cnt + 1;

//generate the CMOS sensor clock and DDR3 controller clock
    Gowin_PLL Gowin_PLL_inst(
        .lock(DDR_pll_lock),  //output lock
        .clkout0(memory_clk), //output clkout0
        .clkout1(cmos_clk),   // for OV5640
        .clkin(clk),          //input clkin
        .reset(~rst_n)        //input reset
    );

//I2C master controller
i2c_config i2c_config_m0(
	.rst                        (~rst_n                   ),
	.clk                        (clk                      ),
	.clk_div_cnt                (16'd270                  ),
	.i2c_addr_2byte             (1'b1                     ),
	.lut_index                  (lut_index                ),
	.lut_dev_addr               (lut_data[31:24]          ),
	.lut_reg_addr               (lut_data[23:8]           ),
	.lut_reg_data               (lut_data[7:0]            ),
	.error                      (                         ),
	.done                       (                         ),
	.i2c_scl                    (cmos_scl                 ),
	.i2c_sda                    (cmos_sda                 )
);
//configure look-up table
lut_ov5640_rgb565_480_272 lut_ov5640_rgb565_480_272_m0(
	.lut_index                  (lut_index                ),
	.lut_data                   (lut_data                 )
);
//CMOS sensor 8bit data is converted to 16bit data

wire cmos_16bit_vsync;

cmos_8_16bit cmos_8_16bit_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (cmos_pclk                ),
	.pdata_i                    (cmos_db                  ),
	.de_i                       (cmos_href                ),
	.pdata_o                    (cmos_16bit_data          ),
	.hblank                     (cmos_16bit_wr            ),
	.de_o                       (cmos_16bit_clk           )
);

    // -----------------------------
    //  縮小＆二値化
    // -----------------------------

    logic           prev_href,prev2_href,prev3_href, prev_vsync,prev2_vsync;
    logic   [10:0]  cam_x;
    logic   [9:0]   cam_y;
    always @(posedge cmos_clk)begin
        prev_href   <= cmos_href;
        prev2_href  <= prev_href;
        prev3_href  <= prev2_href;
        prev_vsync  <= cmos_vsync;
        prev2_vsync <= prev_vsync;

        if(prev2_vsync)begin
            cam_y <= 0;
        // ブランキングでラッチ 
            bin_img <= bin_shr;
        end else begin
            if({prev3_href, prev2_href} == 2'b01) begin
                cam_y <= cam_y +1;
            end
        end
    end

    always_ff @(posedge cmos_16bit_clk ) begin

        if ( ~cmos_16bit_wr ) begin
            cam_x <= 0;
        end
        else begin
            cam_x <= cam_x + 1;
        end
    end

    logic   [27:0][27:0]    bin_shr;
    logic   [27:0][27:0]    bin_img;
    always_ff @(posedge cmos_16bit_clk) begin
        // 間引いてシフトレジスタにサンプリング
        if ( cmos_16bit_wr ) begin
            if ( cam_x[8:3] < 28 && cam_y[7:3] < 28 && cam_x[2:0] == 0 && cam_y[2:0] == 0 ) begin
                bin_shr <= (28*28)'({(write_data[15:11]+write_data[10:5]+write_data[4:0]) < 30, bin_shr} >> 1);  //2値化閾値
            end
        end
    end


    // -----------------------------
    //  LUT-Network 画像認識
    // -----------------------------

    logic   [9:0]       mnist_class;
    MnistLutSimple
            #(
                .USE_REG        (0      ),
                .USER_WIDTH     (0      ),
                .DEVICE         ("RTL"  )
            )
        u_MnistLutSimple
            (
                .reset          (~rst_n          ),
                .clk            (cmos_16bit_clk  ),
                .cke            (1'b1           ),
                
                .in_user        ('0             ),
                .in_data        (bin_img        ),
                .in_valid       (1'b1           ),

                .out_user       (               ),
                .out_data       (mnist_class    ),
                .out_valid      (               )
            );

logic cmos_16bit_clk_half;

//The video output timing generator and generate a frame read data request
//输出
wire out_de;
//wire [9:0] lcd_x,lcd_y;
vga_timing vga_timing_m0(
    .clk (video_clk),
    .rst (~rst_n),

    .hs(syn_off0_hs),
    .vs(syn_off0_vs),
    .de(out_de),
    .rd(camera_de)

    );

//输入测试图
/*//--------------------------
wire        tp0_vs_in  ;
wire        tp0_hs_in  ;
wire        tp0_de_in ;
wire [ 7:0] tp0_data_r;
wire [ 7:0] tp0_data_g;
wire [ 7:0] tp0_data_b;
testpattern testpattern_inst
(
    .I_pxl_clk   (video_clk              ),//pixel clock
    .I_rst_n     (rst_n             ),//low active 
    .I_mode      (3'b010 ),//data select
    .I_single_r  (8'd255               ),
    .I_single_g  (8'd255             ),
    .I_single_b  (8'd255               ),                  //800x600    //1024x768   //1280x720   //1920x1080 
    .I_h_total   (12'd1650     ),//hor total time  // 12'd1056  // 12'd1344  // 12'd1650  // 12'd2200
    .I_h_sync    (12'd40       ),//hor sync time   // 12'd128   // 12'd136   // 12'd40    // 12'd44  
    .I_h_bporch  (12'd220      ),//hor back porch  // 12'd88    // 12'd160   // 12'd220   // 12'd148 
    .I_h_res     (12'd1280     ),//hor resolution  // 12'd800   // 12'd1024  // 12'd1280  // 12'd1920
    .I_v_total   (12'd750      ),//ver total time  // 12'd628   // 12'd806   // 12'd750   // 12'd1125 
    .I_v_sync    (12'd5        ),//ver sync time   // 12'd4     // 12'd6     // 12'd5     // 12'd5   
    .I_v_bporch  (12'd20       ),//ver back porch  // 12'd23    // 12'd29    // 12'd20    // 12'd36  
    .I_v_res     (12'd720      ),//ver resolution  // 12'd600   // 12'd768   // 12'd720   // 12'd1080 
    .I_hs_pol    (1'b1               ),//0,负极性;1,正极性
    .I_vs_pol    (1'b1               ),//0,负极性;1,正极性
    .O_de        (tp0_de_in          ),   
    .O_hs        (tp0_hs_in          ),
    .O_vs        (tp0_vs_in          ),
    .O_data_r    (tp0_data_r         ),   
    .O_data_g    (tp0_data_g         ),
    .O_data_b    (tp0_data_b         )
);*/

wire dma_clk;
wire cmd_ready;
wire[2:0]cmd;
wire cmd_en;
wire[ADDR_WIDTH-1:0] addr;
wire wr_data_rdy;
wire wr_data_en;  //
wire wr_data_end; //
wire[DATA_WIDTH-1:0] wr_data;
wire[DATA_WIDTH/8-1:0] wr_data_mask;
wire rd_data_valid;
wire rd_data_end; //unused
wire[DATA_WIDTH-1:0] rd_data;
wire init_calib_complete;
wire[5:0] app_burst_number;

	Video_Frame_Buffer_Top Video_Frame_Buffer_inst(
		.I_rst_n(rst_n), //input I_rst_n
		.I_dma_clk(dma_clk), //clock for frame buffer and memory controller (generated by memory controller)
		.I_wr_halt(1'b0), //frame buffer interrupt(write) for debug
		.I_rd_halt(1'b0), //frame buffer interrupt(read) for debug
// video data input(camera)
		.I_vin0_clk(cmos_16bit_clk), //camera data input clock
		.I_vin0_vs_n(~cmos_vsync),   // camera data v sync
		.I_vin0_de(cmos_16bit_wr),   // camera data enable
		.I_vin0_data(write_data),    // camera data
		.O_vin0_fifo_full(),         //output O_vin0_fifo_full
// video data output(dvi or LCD)
		.I_vout0_clk(video_clk),     // pixel clock for DVI
		.I_vout0_vs_n(~syn_off0_vs), //input I_vout0_vs_n
		.I_vout0_de(camera_de),      // video output enbable(generated by vga_timing)
		.O_vout0_den(off0_syn_de),   //output O_vout0_den
		.O_vout0_data(off0_syn_data), //output data for DVI
		.O_vout0_fifo_empty(),       //output O_vout0_fifo_empty
// interface to DDR3 controller
		.I_cmd_ready(cmd_ready),     //input I_cmd_ready
		.O_cmd(cmd),                 //output [2:0] O_cmd
		.O_cmd_en(cmd_en),           //output O_cmd_en
//		.O_app_burst_number(app_burst_number), //output [5:0] O_app_burst_number
		.O_addr(addr),               //output [28:0] O_addr
		.I_wr_data_rdy(wr_data_rdy), //input I_wr_data_rdy
		.O_wr_data_en(wr_data_en),   //output O_wr_data_en
		.O_wr_data_end(wr_data_end), //output O_wr_data_end
		.O_wr_data(wr_data),         //output [255:0] O_wr_data
		.O_wr_data_mask(wr_data_mask), //output [31:0] O_wr_data_mask
		.I_rd_data_valid(rd_data_valid), //input I_rd_data_valid
		.I_rd_data_end(rd_data_end), //input I_rd_data_end
		.I_rd_data(rd_data),         //input [255:0] I_rd_data
		.I_init_calib_complete(init_calib_complete) // DDR3 controller calibration completed
	);

/*
Video_Frame_Buffer_Top Video_Frame_Buffer_Top_inst
( 
    .I_rst_n              (init_calib_complete ),//rst_n            ),
    .I_dma_clk            (dma_clk          ),   //sram_clk         ),
`ifdef USE_THREE_FRAME_BUFFER 
    .I_wr_halt            (1'd0             ), //1:halt,  0:no halt
    .I_rd_halt            (1'd0             ), //1:halt,  0:no halt
`endif
    // video data input             
//    .I_vin0_clk           (cmos_16bit_clk_half   ),
    .I_vin0_clk           (cmos_16bit_clk   ),
    .I_vin0_vs_n          (~cmos_vsync      ),//只接收负极性
    .I_vin0_de            (cmos_16bit_wr    ),
    .I_vin0_data          (write_data       ),
    .O_vin0_fifo_full     (                 ),

    // video data output            
    .I_vout0_clk          (video_clk        ),
    .I_vout0_vs_n         (~syn_off0_vs     ),//只接收负极性
    .I_vout0_de           (camera_de        ),
    .O_vout0_den          (off0_syn_de      ),
    .O_vout0_data         (off0_syn_data    ),
    .O_vout0_fifo_empty   (                 ),
    // ddr write request
    .I_cmd_ready          (cmd_ready          ),
    .O_cmd                (cmd                ),//0:write;  1:read
    .O_cmd_en             (cmd_en             ),
    .O_app_burst_number   (app_burst_number   ),
    .O_addr               (addr               ),//[ADDR_WIDTH-1:0]
    .I_wr_data_rdy        (wr_data_rdy        ),
    .O_wr_data_en         (wr_data_en         ),//
    .O_wr_data_end        (wr_data_end        ),//
    .O_wr_data            (wr_data            ),//[DATA_WIDTH-1:0]
    .O_wr_data_mask       (wr_data_mask       ),
    .I_rd_data_valid      (rd_data_valid      ),
    .I_rd_data_end        (rd_data_end        ),//unused 
    .I_rd_data            (rd_data            ),//[DATA_WIDTH-1:0]
    .I_init_calib_complete(init_calib_complete)
);*/ 


localparam N = 7; //delay N clocks
                          
reg  [N-1:0]  Pout_hs_dn   ;
reg  [N-1:0]  Pout_vs_dn   ;
reg  [N-1:0]  Pout_de_dn   ;

always@(posedge video_clk or negedge rst_n)
begin
    if(!rst_n)
        begin                          
            Pout_hs_dn  <= {N{1'b1}};
            Pout_vs_dn  <= {N{1'b1}}; 
            Pout_de_dn  <= {N{1'b0}}; 
        end
    else 
        begin                          
            Pout_hs_dn  <= {Pout_hs_dn[N-2:0],syn_off0_hs};
            Pout_vs_dn  <= {Pout_vs_dn[N-2:0],syn_off0_vs}; 
            Pout_de_dn  <= {Pout_de_dn[N-2:0],out_de}; 
        end
end

//---------------------------------------------
wire lcd_vs,lcd_de,lcd_hs,lcd_dclk;

assign lcd_vs      			  = Pout_vs_dn[4];//syn_off0_vs;
assign lcd_hs      			  = Pout_hs_dn[4];//syn_off0_hs;
assign lcd_de      			  = Pout_de_dn[4];//off0_syn_de;
assign lcd_dclk    			  = video_clk;//video_clk_phs;


	DDR3MI DDR3MI_inst(
		.clk(clk),           //input clk
		.pll_stop(), //output pll_stop
		.memory_clk(memory_clk), //input memory_clk
		.pll_lock(DDR_pll_lock), //input pll_lock
		.rst_n(rst_n),       //reset
		.clk_out(dma_clk)  , //output clk_out
		.ddr_rst(),   //output ddr_rst
		.init_calib_complete(init_calib_complete), //output init_calib_complete
		.cmd_ready(cmd_ready),     //output cmd_ready
		.cmd(cmd),                 //input [2:0] cmd
		.cmd_en(cmd_en),           //input cmd_en
		.addr(addr),               //input [28:0] addr
		.wr_data_rdy(wr_data_rdy), //output wr_data_rdy
		.wr_data(wr_data),         //input [255:0] wr_data
		.wr_data_en(wr_data_en),   //input wr_data_en
		.wr_data_end(wr_data_end), //input wr_data_end
		.wr_data_mask(wr_data_mask), //input [31:0] wr_data_mask
		.rd_data(rd_data),         //output [255:0] rd_data
		.rd_data_valid(rd_data_valid), //output rd_data_valid
		.rd_data_end(rd_data_end), //output rd_data_end
		.sr_req(1'b0),             //input sr_req
		.ref_req(1'b0),            //input ref_req
		.sr_ack(),                 //output sr_ack
		.ref_ack(),                //output ref_ack
		.burst(1'b1),              //input burst
// phisical memory interface
		.O_ddr_addr(ddr_addr),  //
		.O_ddr_ba(ddr_bank),    //output [2:0] O_ddr_ba
		.O_ddr_cs_n(ddr_cs),    //output O_ddr_cs_n
		.O_ddr_ras_n(ddr_ras),  //output O_ddr_ras_n
		.O_ddr_cas_n(ddr_cas),  //output O_ddr_cas_n
		.O_ddr_we_n(ddr_we), //output O_ddr_we_n
		.O_ddr_clk(ddr_ck),     //output O_ddr_clk
		.O_ddr_clk_n(ddr_ck_n), //output O_ddr_clk_n
		.O_ddr_cke(ddr_cke),    //output O_ddr_cke
		.O_ddr_odt(ddr_odt),    //output O_ddr_odt
		.O_ddr_reset_n(ddr_reset_n), //output O_ddr_reset_n
		.O_ddr_dqm(ddr_dm),     //output [3:0] O_ddr_dqm
		.IO_ddr_dq(ddr_dq),     //inout [31:0] IO_ddr_dq
		.IO_ddr_dqs(ddr_dqs),   //inout [3:0] IO_ddr_dqs
		.IO_ddr_dqs_n(ddr_dqs_n) //inout [3:0] IO_ddr_dqs_n
	);

/*
DDR3MI DDR3_Memory_Interface_Top_inst 
(
    .clk                (video_clk          ),
    .memory_clk         (memory_clk         ),
    .pll_lock           (DDR_pll_lock       ),
    .rst_n              (rst_n              ), //rst_n
    .app_burst_number   (app_burst_number   ),
    .cmd_ready          (cmd_ready          ),
    .cmd                (cmd                ),
    .cmd_en             (cmd_en             ),
    .addr               (addr               ),
    .wr_data_rdy        (wr_data_rdy        ),
    .wr_data            (wr_data            ),
    .wr_data_en         (wr_data_en         ),
    .wr_data_end        (wr_data_end        ),
    .wr_data_mask       (wr_data_mask       ),
    .rd_data            (rd_data            ),
    .rd_data_valid      (rd_data_valid      ),
    .rd_data_end        (rd_data_end        ),
    .sr_req             (1'b0               ),
    .ref_req            (1'b0               ),
    .sr_ack             (                   ),
    .ref_ack            (                   ),
    .init_calib_complete(init_calib_complete),
    .clk_out            (dma_clk            ),
    .burst              (1'b1               ),
    // mem interface
    .ddr_rst            (                 ),
    .O_ddr_addr         (ddr_addr         ),
    .O_ddr_ba           (ddr_bank         ),
    .O_ddr_cs_n         (ddr_cs         ),
    .O_ddr_ras_n        (ddr_ras        ),
    .O_ddr_cas_n        (ddr_cas        ),
    .O_ddr_we_n         (ddr_we         ),
    .O_ddr_clk          (ddr_ck          ),
    .O_ddr_clk_n        (ddr_ck_n        ),
    .O_ddr_cke          (ddr_cke          ),
    .O_ddr_odt          (ddr_odt          ),
    .O_ddr_reset_n      (ddr_reset_n      ),
    .O_ddr_dqm          (ddr_dm           ),
    .IO_ddr_dq          (ddr_dq           ),
    .IO_ddr_dqs         (ddr_dqs          ),
    .IO_ddr_dqs_n       (ddr_dqs_n        )
);*/

    // -----------------------------
    //  表示画像オーバーレイ
    // -----------------------------

    logic           prev_de;
    logic   [11:0]  dvi_x;
    logic   [10:0]  dvi_y;

    always_ff @(posedge video_clk ) begin
        prev_de <= lcd_de;

        if ( ~lcd_de ) begin
            dvi_x <= 0;
        end
        else begin
            dvi_x <= dvi_x + 1;
        end

        if ( lcd_vs ) begin
            dvi_y <= 0;
        end
        else begin
            if ( {prev_de, lcd_de} == 2'b10 ) begin
                dvi_y <= dvi_y + 1;
            end
        end
    end

    localparam int  BIN_X = 50;
    localparam int  BIN_Y = 1;
    logic  bin_en;
    logic  bin_view;
    always_ff @(posedge video_clk ) begin
        if ( dvi_x[10:4] >= BIN_X && dvi_x[10:4] < BIN_X+28 
                && dvi_y[9:4] >= BIN_Y && dvi_y[9:4]  < BIN_Y+28 ) begin
            bin_en   <= 1;
            bin_view <= bin_img[dvi_y[9:4]-BIN_Y][dvi_x[10:4]-BIN_X];
        end
        else begin
            bin_en   <= 0;
            bin_view <= 0;
        end
    end

    localparam int  MNIST_X = 1;
    localparam int  MNIST_Y = 18;
    logic  mnist_en;
    logic  mnist_view;
    always_ff @(posedge video_clk ) begin
        if ( dvi_x[10:5] >= MNIST_X && dvi_x[10:5] < MNIST_X+10 
                && dvi_y[9:5] >= MNIST_Y && dvi_y[9:5] < MNIST_Y+1 ) begin
            mnist_en   <= 1;
            mnist_view <= mnist_class[dvi_x[10:5]-MNIST_X];
        end
        else begin
            mnist_en   <= 0;
            mnist_view <= 0;
        end
    end



//==============================================================================
//TMDS TX(HDMI4)
wire serial_clk;
//wire hdmi4_rst_n;

    Gowin_PLL_dvi Gowin_PLL_dvi_inst(
        .lock(), //output lock
        .clkout0(serial_clk), //output clkout0
        .clkout1(video_clk), //output clkout1
        .clkin(clk), //input clkin
        .reset(~rst_n) //input reset
    );

	DVI_TX_Top DVI_TX_Top_inst(
		.I_rst_n(rst_n), //input I_rst_n
		.I_serial_clk(serial_clk), //input I_serial_clk
		.I_rgb_clk(lcd_dclk), //input I_rgb_clk
		.I_rgb_vs(lcd_vs), //input I_rgb_vs
		.I_rgb_hs(lcd_hs), //input I_rgb_hs
		.I_rgb_de(lcd_de), //input I_rgb_de
		.I_rgb_r(off0_syn_de? {off0_syn_data[4:0],3'b0}: bin_en?{8{bin_view}}: mnist_en? {8{mnist_view}}: dvi_x), //
		.I_rgb_g(off0_syn_de? {off0_syn_data[10:5],2'b0}: bin_en?{8{bin_view}}: mnist_en? {8{mnist_view}}: dvi_y), //
		.I_rgb_b(off0_syn_de? {off0_syn_data[15:11],3'b0}: bin_en?{8{bin_view}}: mnist_en? {8{mnist_view}}: 8'hff), //
		.O_tmds_clk_p(O_tmds_clk_p), //output O_tmds_clk_p
		.O_tmds_clk_n(O_tmds_clk_n), //output O_tmds_clk_n
		.O_tmds_data_p(O_tmds_data_p), //output [2:0] O_tmds_data_p
		.O_tmds_data_n(O_tmds_data_n) //output [2:0] O_tmds_data_n
	);

/*
DVI_TX_Top DVI_TX_Top_inst
(
    .I_rst_n       (hdmi4_rst_n   ),  //asynchronous reset, low active
    .I_serial_clk  (serial_clk    ),

    .I_rgb_clk     (lcd_dclk      ),  //pixel clock
    .I_rgb_vs      (lcd_vs        ), 
    .I_rgb_hs      (lcd_hs        ),    
    .I_rgb_de      (lcd_de        ), 
    .I_rgb_r       ( off0_syn_de? {off0_syn_data[4:0],3'b0}: bin_en?{8{bin_view}}: mnist_en? {8{mnist_view}}: dvi_x),  //tp0_data_r
    .I_rgb_g       ( off0_syn_de? {off0_syn_data[10:5],2'b0}: bin_en?{8{bin_view}}: mnist_en? {8{mnist_view}}: dvi_y),  //,  
    .I_rgb_b       ( off0_syn_de? {off0_syn_data[15:11],3'b0}: bin_en?{8{bin_view}}: mnist_en? {8{mnist_view}}: 8'hff),  //,

    .O_tmds_clk_p  (O_tmds_clk_p  ),
    .O_tmds_clk_n  (O_tmds_clk_n  ),
    .O_tmds_data_p (O_tmds_data_p ),  //{r,g,b}
    .O_tmds_data_n (O_tmds_data_n )
);*/

endmodule