module top(
	input                       clk,
	input                       rst,
    input                       sw1,
	inout                       cmos_scl,          //cmos i2c clock
	inout                       cmos_sda,          //cmos i2c data
	input                       cmos_vsync,        //cmos vsync
	input                       cmos_href,         //cmos hsync refrence,data valid
	input                       cmos_pclk,         //cmos pxiel clock
    output                      cmos_xclk,         //cmos externl clock 
	input   [7:0]               cmos_db,           //cmos data
	output                      cmos_rst_n,        //cmos reset 
	output                      cmos_pwdn,         //cmos power down
	
	output  				    led,
/*
	output [14-1:0]             ddr_addr,       //ROW_WIDTH=14
	output [3-1:0]              ddr_bank,       //BANK_WIDTH=3
	output                      ddr_cs,
	output                      ddr_ras,
	output                      ddr_cas,
	output                      ddr_we,
	output                      ddr_ck,
	output                      ddr_ck_n,
	output                      ddr_cke,
	output                      ddr_odt,
	output                      ddr_reset_n,
	output [2-1:0]              ddr_dm,         //DM_WIDTH=2
	inout [16-1:0]              ddr_dq,         //DQ_WIDTH=16
	inout [2-1:0]               ddr_dqs,        //DQS_WIDTH=2
	inout [2-1:0]               ddr_dqs_n,      //DQS_WIDTH=2
*/
    // SDRAM
    output O_sdram_clk,
    output O_sdram_cke,
    output O_sdram_cs_n,            // chip select
    output O_sdram_cas_n,           // columns address select
    output O_sdram_ras_n,           // row address select
    output O_sdram_wen_n,           // write enable
    inout [15:0] IO_sdram_dq,       // 16 bit bidirectional data bus
    output [12:0] O_sdram_addr,     // 13 bit multiplexed address bus
    output [1:0] O_sdram_ba,        // two banks
    output [1:0] O_sdram_dqm,       // 32/4

    output            O_tmds_clk_p    ,
    output            O_tmds_clk_n    ,
    output     [2:0]  O_tmds_data_p   ,//{r,g,b}
    output     [2:0]  O_tmds_data_n   
);

//memory interface
wire                   memory_clk         ;
wire                   memory_clk45;
wire                   fb_clk;
wire                   clk32_5;
//wire                   dma_clk       	  ;
wire                   DDR_pll_lock       ;
wire                   sdrc_busy_n        ;
wire[2:0]              cmd                ;
wire                   cmd_en             ;
wire[7:0]              sdrc_data_len      ;
wire[20:0]             sdrc_addr          ;
wire                   wr_data_rdy        ;
wire                   sdrc_wr_n         ;//
wire                   wr_data_end        ;//
//wire[DATA_WIDTH-1:0]   wr_data            ;   
wire[15:0]   wr_data;  
wire                   sdrc_rd_valid;
wire                   rd_data_end        ;//unused 
//wire[DATA_WIDTH-1:0]   rd_data            ;   
wire [15:0] sdrc_data;
wire                   sdrc_init_done;

logic rst_n;
assign rst_n = ~rst;

//According to IP parameters to choose
`define	    WR_VIDEO_WIDTH_16
`define	DEF_WR_VIDEO_WIDTH 16

`define	    RD_VIDEO_WIDTH_16
`define	DEF_RD_VIDEO_WIDTH 16

`define	USE_THREE_FRAME_BUFFER

`define	DEF_ADDR_WIDTH 28 
`define	DEF_SRAM_DATA_WIDTH 128
//
//=========================================================
//SRAM parameters
parameter WR_VIDEO_WIDTH      = `DEF_WR_VIDEO_WIDTH;  
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

assign cmos_xclk  = cmos_clk;
assign cmos_pwdn  = 1'b0;
assign cmos_rst_n = 1'b1;
assign write_data = {cmos_16bit_data[4:0],cmos_16bit_data[10:5],cmos_16bit_data[15:11]};
assign hdmi_hpd   = 1;

//状态指示灯
assign led = lcd_vs_cnt[4];

reg [4:0] lcd_vs_cnt;
always@(posedge lcd_vs) lcd_vs_cnt <= lcd_vs_cnt + 1;

Gowin_PLL_memory pll_memory(
    .lock(DDR_pll_lock),  //output lock
    .clkout0(memory_clk), //output clkout0 100MHz
    .clkout1(cmos_clk),   //output clkout1  24MHz
    .clkin(clk),          //input clkin
    .clkout2(memory_clk45)   //output clkout2
);


//I2C master controller
i2c_config i2c_config_m0(
	.rst                        (~rst_n                   ),
	.clk                        (clk                      ),
	.clk_div_cnt                (16'd270                  ), //
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
wire camera_de;
wire out_de;
wire monitor_en;
//wire [9:0] lcd_x,lcd_y;
vga_timing vga_timing_m0(
    .clk (video_clk),
    .rst (~rst_n),

    .hs(syn_off0_hs),
    .vs(syn_off0_vs),
    .de(out_de),
    .rd(camera_de)
//    .monitor_en(monitor_en)
);

logic input_camera;
    always_ff @(negedge cmos_vsync)begin
        if(monitor_en)begin
            input_camera <= 1'b1;
        end else begin
            input_camera <= 1'b0;
        end
    end

//输入测试图
/*//--------------------------

    .I_single_b  (8'd255               ),                  //800x600    //1024x768   //1280x720   //1920x1080 
    .I_h_total   (12'd1650     ),//hor total time  // 12'd1056  // 12'd1344  // 12'd1650  // 12'd2200
    .I_h_sync    (12'd40       ),//hor sync time   // 12'd128   // 12'd136   // 12'd40    // 12'd44  
    .I_h_bporch  (12'd220      ),//hor back porch  // 12'd88    // 12'd160   // 12'd220   // 12'd148 
    .I_h_res     (12'd1280     ),//hor resolution  // 12'd800   // 12'd1024  // 12'd1280  // 12'd1920
    .I_v_total   (12'd750      ),//ver total time  // 12'd628   // 12'd806   // 12'd750   // 12'd1125 
    .I_v_sync    (12'd5        ),//ver sync time   // 12'd4     // 12'd6     // 12'd5     // 12'd5   
    .I_v_bporch  (12'd20       ),//ver back porch  // 12'd23    // 12'd29    // 12'd20    // 12'd36  
    .I_v_res     (12'd720      ),//ver resolution  // 12'd600   // 12'd768   // 12'd720   // 12'd1080 
720x480(PixelClock 27MHz)    H_Active 720    H_Blank 138    H_FrontPorch 16    H_Sync 62    H_BackPorch 60
           V_Active    V_Blank 45    V_Front_Porch 9    V_Sync 6    V_BackPorch 30
);*/

logic[1:0] sdrc_dqm;
logic sdrc_rd_n;

	Video_Frame_Buffer_SDRAM frameBuffer_SDRAM(
		.I_rst_n(rst_n), //input I_rst_n
		.I_dma_clk(memory_clk45   ), //input I_dma_clk

		.I_wr_halt(sw1         ), //input [0:0] I_wr_halt
		.I_rd_halt(sw1           ), //input [0:0] I_rd_halt

		.I_vin0_clk(cmos_16bit_clk), //input I_vin0_clk
		.I_vin0_vs_n(~cmos_vsync  ), //input I_vin0_vs_n
		.I_vin0_de(cmos_16bit_wr), //input I_vin0_de
		.I_vin0_data(write_data   ), //input [15:0] I_vin0_data
		.O_vin0_fifo_full(        ), //output O_vin0_fifo_full

		.I_vout0_clk(video_clk    ), //input I_vout0_clk
		.I_vout0_vs_n(~syn_off0_vs), //input I_vout0_vs_n
		.I_vout0_de(camera_de     ), //input I_vout0_de
		.O_vout0_den(off0_syn_de  ), //output O_vout0_den
		.O_vout0_data(off0_syn_data), //output [15:0] O_vout0_data
		.O_vout0_fifo_empty(       ), //output O_vout0_fifo_empty

		.I_sdrc_busy_n(sdrc_busy_n   ), //input I_sdrc_busy_n
		.O_sdrc_wr_n(sdrc_wr_n    ), //output O_sdrc_wr_n
		.O_sdrc_rd_n(sdrc_rd_n     ), //output O_sdrc_rd_n
		.O_sdrc_addr(sdrc_addr          ), //output [20:0] O_sdrc_addr
		.O_sdrc_data_len(sdrc_data_len), //output [7:0] O_sdrc_data_len
		.O_sdrc_data(wr_data       ), //output [15:0] O_sdrc_data
		.O_sdrc_dqm(sdrc_dqm       ), //output [1:0] O_sdrc_dqm
		.I_sdrc_rd_valid(sdrc_rd_valid), //input I_sdrc_rd_valid
		.I_sdrc_data_out(sdrc_data ), //input [15:0] I_sdrc_data_out
		.I_sdrc_init_done(sdrc_init_done) //input I_sdrc_init_done
	);


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

assign lcd_vs      			  = Pout_vs_dn[2]; //syn_off0_vs;
assign lcd_hs      			  = Pout_hs_dn[2]; //syn_off0_hs;
assign lcd_de      			  = Pout_de_dn[2]; //off0_syn_de;
assign lcd_dclk    			  = video_clk;     //video_clk_phs;

SDRAM_controller_top_SIP sdram_controller0( // IPUG279-1.3J  P.7
		.O_sdram_clk(O_sdram_clk    ),      //output O_sdram_clk
		.O_sdram_cke(O_sdram_cke    ),      //output O_sdram_cke
		.O_sdram_cs_n(O_sdram_cs_n  ),      //output O_sdram_cs_n
		.O_sdram_cas_n(O_sdram_cas_n),      //output O_sdram_cas_n
		.O_sdram_ras_n(O_sdram_ras_n),      //output O_sdram_ras_n
		.O_sdram_wen_n(O_sdram_wen_n),      //output O_sdram_wen_n
		.O_sdram_dqm(O_sdram_dqm    ),      //output [1:0] O_sdram_dqm
		.O_sdram_addr(O_sdram_addr  ),      //output [12:0] O_sdram_addr
		.O_sdram_ba(O_sdram_ba      ),      //output [1:0] O_sdram_ba
		.IO_sdram_dq(IO_sdram_dq    ),              // [15:0] IO_sdram_dq
		.I_sdrc_rst_n(rst_n         ),              // I_sdrc_rst_n リセット
		.I_sdrc_clk(memory_clk45    ),              // I_sdrc_clk コントローラ動作クロック
        .I_sdram_clk(memory_clk     ),              // I_sdram_clk SDRAM動作クロック
		.I_sdrc_selfrefresh(1'b0 ),                 // I_sdrc_selfrefresh セルフリフレッシュ制御(1:有効, 0:無効)
		.I_sdrc_power_down(1'b0  ),                 // I_sdrc_power_down 低消費電力制御(1:有効, 0:無効)
		.I_sdrc_wr_n(sdrc_wr_n  ),                 // I_sdrc_wr_n 書込イネーブル
		.I_sdrc_rd_n(sdrc_rd_n   ),                 // I_sdrc_rd_n 読取イネーブル
		.I_sdrc_addr({2'b00,sdrc_addr}  ),                 // [22:0] I_sdrc_addr アドレス
		.I_sdrc_data_len(sdrc_data_len),         // [7:0] I_sdrc_data_len 読み書きデータ長
		.I_sdrc_dqm(sdrc_dqm     ),                 // [1:0] I_sdrc_dqm データマスク制御
		.I_sdrc_data(wr_data     ),                 // [15:0] I_sdrc_data 書込データ
		.O_sdrc_data(sdrc_data     ),                 // [15:0] O_sdrc_data 読取データ
		.O_sdrc_init_done(sdrc_init_done),     // O_sdrc_init_done パワーアップ初期化完了(1:完了, 0:未完)
		.O_sdrc_busy_n(sdrc_busy_n ),                 // O_sdrc_busy_n コントローラアイドル表示．アイドル時に読み書きトリガ可能(1:アイドル, 0:ビジー)
		.O_sdrc_rd_valid(sdrc_rd_valid),            // O_sdrc_rd_valid 読み取りデータ有効．(1:有効)
		.O_sdrc_wrd_ack(         )                // O_sdrc_wrd_ack 読み書きリクエスト応答
);



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

    localparam int  BIN_X = 61;
    localparam int  BIN_Y = 2;
    logic  bin_en;
    logic  bin_view;
    always_ff @(posedge video_clk ) begin
        if ( dvi_x[9:3] >= BIN_X && dvi_x[9:3] < BIN_X+28 
                && dvi_y[8:3] >= BIN_Y && dvi_y[8:3]  < BIN_Y+28 ) begin
            bin_en   <= 1;
            bin_view <= bin_img[dvi_y[8:3]-BIN_Y][dvi_x[9:3]-BIN_X];
        end
        else begin
            bin_en   <= 0;
            bin_view <= 0;
        end
    end

    localparam int  MNIST_X = 1;
    localparam int  MNIST_Y = 25;
    logic  mnist_en;
    logic  mnist_view;
    always_ff @(posedge video_clk ) begin
        if ( dvi_x[10:5] >= MNIST_X && dvi_x[10:5] < MNIST_X+10 
                && dvi_y[8:4] >= MNIST_Y && dvi_y[8:4] < MNIST_Y+1 ) begin
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
wire TMDS_DDR_pll_lock;
wire hdmi4_rst_n;
/*
TMDS_rPLL u_tmds_rpll
(.clkin     (clk       )     //input clk 
,.clkout    (serial_clk     )     //output clk 325MHz
,.lock      (TMDS_DDR_pll_lock       )     //output lock
);
*/
Gowin_PLL_tmds pll_tmds(
    .lock(TMDS_DDR_pll_lock), //output lock
    .clkout0(serial_clk), //output clkout0
    .clkin(clk) //input clkin
);

assign hdmi4_rst_n = rst_n & TMDS_DDR_pll_lock;

Gowin_CLKDIV video_clk_gen(
        .clkout(video_clk), //output clkout
        .hclkin(serial_clk), //input hclkin
        .resetn(hdmi_hpd), //input resetn
        .calib(1'b1) //input calib
);


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

    //测试图
    // .I_rgb_clk     (video_clk       ),  //pixel clock
    // .I_rgb_vs      (tp0_vs_in  ), 
    // .I_rgb_hs      (tp0_hs_in  ),   
    // .I_rgb_de      (tp0_de_in  ), 
    // .I_rgb_r       (tp0_data_r  ), 
    // .I_rgb_g       (tp0_data_g  ), 
    // .I_rgb_b       (tp0_data_b  ), 

    .O_tmds_clk_p  (O_tmds_clk_p  ),
    .O_tmds_clk_n  (O_tmds_clk_n  ),
    .O_tmds_data_p (O_tmds_data_p ),  //{r,g,b}
    .O_tmds_data_n (O_tmds_data_n )
);

endmodule