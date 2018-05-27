`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/04/23 22:06:47
// Design Name: 
// Module Name: dataMemory
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


module dataMemory(
    input [11:0] showin, 
    input [11:0] addr,
    input [31:0] datain,
    input str,
    input ld,
    input [3:0] sel,
    input clk,
    input clr,
    output reg [31:0] dataout = 0,
    output [31:0] showout
    );
    
     reg[31:0] memory[0:511];   
     
     assign showout = memory[showin];
     
     //д
  always @(posedge clk) 
  begin 
       if(str==1) begin 
           case(sel)
               4'b0001: memory[addr][7:0] <= datain[7:0];
               4'b0010: memory[addr][15:8] <= datain[15:8];
               4'b0011: memory[addr][15:0] <= datain[15:0];
               
               4'b0100: memory[addr][23:16] <= datain[23:16];
               4'b0101: begin 
                        memory[addr][23:16] <= datain[23:16]; 
                        memory[addr][7:0] <= datain[7:0];
                        end
               4'b0110: memory[addr][23:8] <= datain[23:8];
               4'b0111: memory[addr][23:0] <=datain[23:0];
               
               4'b1000: memory[addr][31:24] <= datain[31:24];
               4'b1001:begin
                       memory[addr][31:24] <= datain[31:24];
                       memory[addr][7:0] <= datain[7:0];
                       end 
               4'b1010:begin 
                       memory[addr][31:24] <=datain[31:24];
                       memory[addr][15:8] <= datain[15:8];
                       end 
               4'b1011:begin 
                       memory[addr][31:24] <= datain[31:24];
                       memory[addr][15:0] <= datain[15:0];
                       end
               
               4'b1100: memory[addr][31:16] <= datain[31:16];
               4'b1101: begin 
                        memory[addr][31:16] <= datain[31:16];
                        memory[addr][7:0] <=datain[7:0];
                        end 
               4'b1110:memory[addr][31:8] <= datain[31:8];
               4'b1111:memory[addr][31:0] <= datain[31:0];
           endcase
           end
      else if (ld) begin
        dataout <= 0;
        case (sel)
          4'b0001: dataout[7:0] <= memory[addr][7:0];
          4'b0010: dataout[15:8] <= memory[addr][15:8];
          4'b0011: dataout[15:0] <= memory[addr][15:0];
          4'b0100: dataout[23:16] <= memory[addr][23:16];
          4'b0101: begin 
                  dataout[23:16] <=memory[addr][23:16]; 
                  dataout[7:0] <= memory[addr][7:0];
                  end
          4'b0110: dataout[23:8] <= memory[addr][23:8];
          4'b0111: dataout[23:0] <= memory[addr][23:0];
               
          4'b1000: dataout[31:24] <= memory[addr][31:24];
          4'b1001:begin
                  dataout[31:24] <= memory[addr][31:24];
                  dataout[7:0] <= memory[addr][7:0];
                  end 
          4'b1010:begin 
                  dataout[31:24] <=memory[addr][31:24];
                  dataout[15:8] <= memory[addr][15:8];
                  end 
          4'b1011:begin 
                  dataout[31:24] <= memory[addr][31:24];
                  dataout[15:0] <= memory[addr][15:0];
                  end
               
          4'b1100: dataout[31:16] <= memory[addr][31:16];
          4'b1101: begin 
                  dataout[31:16] <= memory[addr][31:16];
                  dataout[7:0] <= memory[addr][7:0];
                  end 
          4'b1110: dataout[31:8] <= memory[addr][31:8];
          4'b1111: dataout[31:0] <= memory[addr][31:0];
          endcase
          end
      else;
  end
endmodule
