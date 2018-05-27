`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/20 11:11:10
// Design Name: 
// Module Name: Ctrl
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


module Ctrl(En, Pause, power, Ctrl, PcCtrl);
	input En, Pause, power;
	output Ctrl, PcCtrl;

	assign Ctrl = Pause && En;
	assign PcCtrl = Pause && power && En;
endmodule
