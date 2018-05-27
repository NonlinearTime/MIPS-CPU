`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/20 17:00:56
// Design Name: 
// Module Name: Address
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


module Address(AddrIn, AddrBranch, AddrSel, BHT_Pre,AddrOut, PcOut);
input [9:0] AddrIn;
input [31:0] AddrBranch;
input AddrSel, BHT_Pre;
output [31:0] AddrOut, PcOut;

assign AddrOut = {{22{1'b0}},AddrIn} + 32'b1;
assign PcOut = AddrSel ^ BHT_Pre ? AddrBranch : AddrOut;

endmodule
