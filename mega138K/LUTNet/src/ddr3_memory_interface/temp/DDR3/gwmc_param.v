parameter DRAM_TYPE = "DDR3";
parameter nCK_PER_CLK = 4;
parameter tCK = 2500;
parameter REG_CTRL = "OFF";
parameter DQ_WIDTH = 32;
parameter DRAM_WIDTH = 16;
parameter ECC = "OFF";
parameter RANK_WIDTH = 1;
parameter BANK_WIDTH = 3;
parameter ROW_WIDTH = 15;
parameter COL_WIDTH = 10;
parameter tRP = 15000;
parameter tRRD = 10000;
parameter tRTP = 7500;
parameter tRCD = 15000;
parameter tRC = 55000;
parameter tRAS = 37500;
parameter tFAW = 40000;
parameter tWTR = 7500;
parameter tCKE = 10000;
parameter tREFI = 7800000;
parameter tRFC = 260000;
parameter tDLLK = 512;
parameter BURST_MODE = "8";
parameter BURST_TYPE = "SEQ";
parameter CL = 6;
parameter CWL = 5;
parameter AL = "0";
parameter SLOT_0_CONFIG = 8'b00000001;
parameter SLOT_1_CONFIG = 8'b00000000;
parameter RTT_NOM = "60";
parameter RTT_WR = "60";
parameter USER_REFRESH = "OFF";
parameter ADDR_CMD_MODE = "1T";
parameter OUTPUT_DRV = "LOW";
