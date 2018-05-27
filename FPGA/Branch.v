`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/20 09:19:43
// Design Name: 
// Module Name: Branch
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


module Branch(Istr, RS, RT, M4In, M4Out, Disp, Halt, Equal, Less, Pause, isBranch);
	input[31:0] RS, RT;
	input[1:0] M4In;
	input[29:0] Istr;

	output[1:0] M4Out;
	output Disp, Halt, Equal, Less, Pause, isBranch;

	wire beq, bne, bltz, syscall;

	assign beq = Istr[6];
	assign bne = Istr[7];
	assign bltz = Istr[12];
	assign syscall = Istr[27];

	assign Equal = (RS == RT);
	assign Less = $signed(RS) < $signed (32'b0);
	assign Disp = syscall && (RS == 32'h22);
	assign Halt = syscall && (RS == 32'ha);
	assign Pause = syscall && (RS == 32'h32);
	assign isBranch = beq || bne || bltz || Istr[9] || Istr[10] || Istr[26];
	assign M4Out = {(beq && Equal) || (~Equal && bne) || (bltz && Less) || M4In[1], M4In[0]};


endmodule
