`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/20 14:16:20
// Design Name: 
// Module Name: Lock
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


module Lock(EN, CLK, RST, CONT, pauseIn, En, Pause);
	input EN, CLK, RST, CONT, pauseIn;
	output En, Pause;
	wire en, pause;
	assign En = ~en;
	assign Pause = ~pause;
	Register halt_reg(EN, ~en, CLK, RST, en);
	Register pause_reg(pauseIn, ~pause, CLK, RST | CONT, pause);
endmodule
