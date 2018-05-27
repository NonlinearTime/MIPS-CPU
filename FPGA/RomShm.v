`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/20 09:39:24
// Design Name: 
// Module Name: RomShm
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


module RomShm(DataIn, SelIn, DataOut);
	input[31:0] DataIn;
	input[3:0] SelIn;
	output [31:0] DataOut;

	wire [31:0] Byte, Half;
	wire [1:0] sel;

	assign sel = {(SelIn == 4'h1) || (SelIn == 4'h2) || (SelIn == 4'h4) || (SelIn == 4'h8) || (SelIn == 4'hf), (SelIn == 4'hf) || (SelIn == 4'h3) || (SelIn == 4'hc)};	

	assign Byte = {4{DataIn[7:0]}};
	assign Half = {2{DataIn[15:0]}};

	assign DataOut = sel == 2'b00 ? DataIn : 
					 sel == 2'b01 ? Half :
					 sel == 2'b10 ? Byte : DataIn;
endmodule
