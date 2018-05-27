`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: RuLaiFo Group	
// Engineer: Haines
// 
// Create Date: 2018/03/12 15:35:11
// Design Name: 
// Module Name: IstrSplit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IstrSplit(Istr, RS, RT, RD, IMM16, IMM26, SHAMT, OP, FUNC);
input [31:0] Istr;
output reg [4:0] RS = 0, RT = 0, RD = 0;
output reg [15:0] IMM16 = 0;
output reg [25:0] IMM26 = 0;
output reg [4:0] SHAMT = 0;
reg SYSCALL;
output reg [5:0] OP = 0, FUNC = 0;

reg [4:0] local_rs, local_rt;

always @(*) begin
	FUNC = Istr[5:0];
	OP = Istr[31:26];
	RD = Istr[15:11];
	local_rt = Istr[20:16];
	local_rs = Istr[25:21];
	IMM16 = Istr[15:0];
	IMM26 = Istr[25:0];
	SHAMT = Istr[10:6];
end

always @(*) begin
	if (OP == 6'b000000 && FUNC == 6'b001100) begin
		SYSCALL = 1;
	end else begin
		SYSCALL = 0;
	end
end

always @(*) begin
	if (SYSCALL == 1) begin
		RT = 6'b000100;
		RS = 6'b000010;
	end
	else begin
		RT = local_rt;
		RS = local_rs;
	end
end

endmodule
