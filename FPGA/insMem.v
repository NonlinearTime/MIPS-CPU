`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/13 16:25:55
// Design Name: 
// Module Name: insMem
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


module insMem(
input [9:0] addr,
output [31:0] data
);
 reg[31:0] memory[0:511];   
 
 initial
 begin 
 $readmemh("F:/class/CPU/multi_circle_cpu/cpu_redirect/benchmark_ccmb.hex",memory);
 end 

 assign   data =  memory[addr];

endmodule
