`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/12 21:11:04
// Design Name: 
// Module Name: InstCounter
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


module InstCounter(clk,rst,halt,EQUAL,LESS,Istr,J,B,Br,All);
	input clk,rst,halt,EQUAL,LESS;
	input [29:0] Istr;
	output reg[15:0] J,B,Br,All;

	wire Bcount,Jcount,Brcount;

	assign Jcount = Istr[26] || Istr[10] || Istr[9];
	assign Bcount = Istr[6] || Istr[7] || Istr[12];
	assign Brcount = (EQUAL && Istr[6]) || (~EQUAL && Istr[7]) || (LESS && Istr[12]);

	initial begin
		J=0;
		B=0;
		Br=0;
		All=0;
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin //如果清零
				// reset
				J=0;
				B=0;
				Br=0;
				All=0;
		end
		else if (halt) begin //如果没有停机
				if(Jcount) //对应信号计数加一
					J=J+1;
				if(Bcount)
					B=B+1;
				if(Brcount)
					Br=Br+1;				
				All=All+1;
		   end
	end
endmodule
