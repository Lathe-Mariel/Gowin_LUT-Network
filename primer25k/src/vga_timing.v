module vga_timing(
	input                 clk,           //pixel clock
	input                 rst,           //reset signal high active
	output                hs,            //horizontal synchronization
	output                vs,            //vertical synchronization
	output                de,            //video valid
    output reg            monitor_en,    // monitor enable

	output reg [9:0] active_x,              //video x position 
	output reg [9:0] active_y,             //video y position 
	output reg rd //real resolution
	);


//VIDEO_1024 768
parameter H_ACTIVE = 16'd1280;  //1280 1920 1280@24
parameter H_FP = 16'd110;       //110  88 1760
parameter H_SYNC = 16'd40;      //40   44 40
parameter H_BP = 16'd220;       //220  148 220
parameter V_ACTIVE = 16'd720;   //720  1080
parameter V_FP  = 16'd5;        //5    4
parameter V_SYNC  = 16'd5;      //5    5
parameter V_BP  = 16'd20;       //20   36
parameter HS_POL = 1'b1;
parameter VS_POL = 1'b1;
parameter RD_H = 16'd480;
parameter RD_V = 16'd272;


parameter H_TOTAL = H_ACTIVE + H_BP + H_SYNC + H_FP;//horizontal total time (pixels)
parameter V_TOTAL = V_ACTIVE + V_BP + V_SYNC + V_FP;//vertical total time (lines)


reg hs_reg;                      //horizontal sync register
reg vs_reg;                      //vertical sync register
reg[11:0] h_cnt;                 //horizontal counter
reg[10:0] v_cnt;                 //vertical counter

reg h_active;                    //horizontal video active
reg v_active;                    //vertical video active
assign hs = hs_reg;
assign vs = vs_reg;
assign de = h_active & v_active;


/*有効領域 de信号生成*/
always@ (posedge clk)begin
    if(rst == 1'b1)
        rd <= 0;
    else begin
        rd <= (h_cnt > (H_FP + H_SYNC -2)) & (h_cnt < (H_FP + H_SYNC + RD_H -1)) & 
              (v_cnt > (V_FP + V_SYNC -2)) & (v_cnt < (V_FP + V_SYNC + RD_V -1));
    end
end

always@ (posedge clk)begin
    if(v_cnt > RD_V && v_cnt < (V_TOTAL - RD_V))begin
        monitor_en <= 1;
    end else begin
        monitor_en <= 0;
    end
end

//Horizontalカウンタ
always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		h_cnt <= 12'd0;
	else if(h_cnt == H_TOTAL - 1)//horizontal counter maximum value
		h_cnt <= 12'd0;
	else
		h_cnt <= h_cnt + 12'd1;
end
//显示计数
always@(posedge clk)
begin
//	if(h_cnt >= H_BP + H_SYNC + H_FP)//horizontal video active
	if(h_cnt >= H_FP + H_SYNC )//horizontal video active
		active_x <= h_cnt - (H_FP[11:0] + H_SYNC[11:0] );
	else
		active_x <= active_x;
end
always@(posedge clk)
begin	
//	if(v_cnt >= V_BP + V_SYNC + V_FP)//horizontal video active
	if(v_cnt >= V_FP + V_SYNC )//horizontal video active
		active_y <= v_cnt - (V_FP[11:0] + V_SYNC[11:0] );
	else
		active_y <= active_y;
end
//Vertical　カウンタ
always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		v_cnt <= 12'd0;
	else if(h_cnt == H_FP  - 1)//horizontal sync time
		if(v_cnt == V_TOTAL - 1)//vertical counter maximum value
			v_cnt <= 12'd0;
		else
			v_cnt <= v_cnt + 12'd1;
	else
		v_cnt <= v_cnt;
end
//Horizonal Sync生成
always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		hs_reg <= 1'b0;
	else if(h_cnt == (H_FP - 1))//horizontal sync begin
		hs_reg <= HS_POL;
	else if(h_cnt == (H_FP + H_SYNC - 1))//horizontal sync end
		hs_reg <= ~hs_reg;
	else
		hs_reg <= hs_reg;
end
//H_ACTIVE生成
always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		h_active <= 1'b0;
	else if(h_cnt == (H_FP - 1))//horizontal active begin
		h_active <= 1'b1;
	else if(h_cnt == (H_FP + H_SYNC + H_ACTIVE - 1))//horizontal active end
		h_active <= 1'b0;
	else
		h_active <= h_active;
end
//Vertical Sync 生成
always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		vs_reg <= 1'd0;
	else if((v_cnt == V_FP - 1) && (h_cnt == H_FP - 1))//vertical sync begin
		vs_reg <= VS_POL;
	else if((v_cnt == V_FP + V_SYNC - 1) && (h_cnt == H_FP - 1))//vertical sync end
		vs_reg <= ~vs_reg;
	else
		vs_reg <= vs_reg;
end
//V_ACTIVE生成
always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		v_active <= 1'd0;
	else if((v_cnt == (V_FP + V_SYNC - 1)) && (h_cnt == (H_FP - 1)))//vertical active begin
		v_active <= 1'b1;
	else if((v_cnt == (V_FP + V_SYNC + V_ACTIVE - 1)) && (h_cnt == (H_FP - 1))) //vertical active end
		v_active <= 1'b0;   
	else
		v_active <= v_active;
end


endmodule 