`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/12 16:30:57
// Design Name: 
// Module Name: register_file
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


module register_file(rA,rB,rW,W,WE,clk,A,B);
input [4:0]rA; //寄存器A的地址
input [4:0]rB; //寄存器B的地址
input [4:0]rW; //写寄存器的地址
input [31:0]W; //写入的数据
input WE,clk;  //写使能信号、时钟
output [31:0]A; //寄存器A的数据
output [31:0]B; //寄存器B的数据
reg [31:0]data[31:0]; //32个32位寄存器
integer i; //用于初始化寄存器的循环

initial
	begin
		for(i=0;i<32;i=i+1)
			data[i]=32'b0; //将32个寄存器初始化为0
	end
	
assign A = data[rA]; //读寄存器A的数据
assign B = data[rB]; //读寄存器B的数据

always @(negedge clk) begin
	if(WE==1)
		data[rW]=W; //时钟上升沿到来时，检查写使能，若为1，则写入数据
	data[0]=32'b0; //保持0号寄存器值不变
end
endmodule
