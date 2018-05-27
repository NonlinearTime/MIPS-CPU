`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:Haines 
// 
// Create Date: 2018/03/20 08:29:10
// Design Name: 
// Module Name: pipelineInterface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: a common pipeline interface 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pipelineInterface(CLK, SynClr, AsynClr, 
	statIn, IstrIn, R1In, R2In, b32In1, b32In2, b32In3, b32In4, b5In1, b5In2, b5In3, b5In4, PauseIn,
	HaltIn, AluIn, DmSelIn, shaIn, DmLdIn, DmStrIn, RegWriteIn, M4In, M3In, M2In, M1In, DispIn,
	statOut, IstrOut, R1Out, R2Out, b32Out1, b32Out2, b32Out3, b32Out4, b5Out1, b5Out2, b5Out3, b5Out4, PauseOut,
	HaltOut, AluOut, DmSelOut, shaOut, DmLdOut, DmStrOut, RegWriteOut, M4Out, M3Out, M2Out, M1Out, DispOut);
	
	input CLK, SynClr, AsynClr;
	input statIn, HaltIn, shaIn, DmLdIn, DmStrIn, RegWriteIn, DispIn, PauseIn;
	input[1:0] M4In, M3In, M2In, M1In;
	input[3:0] AluIn, DmSelIn;
	input[4:0] b5In1, b5In2, b5In3, b5In4;
	input[31:0] R1In, R2In, b32In4, b32In3, b32In2, b32In1;
	input[29:0] IstrIn;

	output reg statOut, HaltOut, shaOut, DmLdOut, DmStrOut, RegWriteOut, DispOut, PauseOut;
	output reg[1:0] M4Out,M3Out,M2Out,M1Out;
	output reg[3:0] AluOut, DmSelOut;
	output reg[4:0] b5Out1,b5Out2,b5Out3,b5Out4; 
	output reg[31:0] R1Out, R2Out, b32Out1, b32Out2, b32Out3, b32Out4;
	output reg[29:0] IstrOut;
	initial begin
		statOut <= 0; 
		HaltOut <= 0;
		shaOut <= 0; 
		DmLdOut <= 0;
		DmStrOut <= 0;
		RegWriteOut <= 0;
		DispOut <= 0;
		PauseOut <= 0;
		M4Out <= 2'b0; 
		M3Out <= 2'b0;
		M2Out <= 2'b0; 
		M1Out <= 2'b0;
		AluOut <= 4'b0; 
		DmSelOut <= 4'b0;
		b5Out1 <= 5'b0; 
		b5Out2 <= 5'b0;
		b5Out3 <= 5'b0;
		b5Out4 <= 5'b0; 
		IstrOut <= 32'b0; 
		R1Out <= 32'b0;
		R2Out <= 32'b0;
		b32Out1 <= 32'b0;
		b32Out2 <= 32'b0;
		b32Out3 <= 32'b0;
		b32Out4 <= 32'b0;
	end

	always @(posedge CLK or posedge AsynClr) begin
		if (AsynClr) begin
			// reset
			statOut <= 0; 
			HaltOut <= 0;
			shaOut <= 0; 
			DmLdOut <= 0;
			DmStrOut <= 0;
			RegWriteOut <= 0;
			DispOut <= 0;
			PauseOut <= 0;
			M4Out <= 2'b0; 
			M3Out <= 2'b0;
			M2Out <= 2'b0; 
			M1Out <= 2'b0;
			AluOut <= 4'b0; 
			DmSelOut <= 4'b0;
			b5Out1 <= 5'b0; 
			b5Out2 <= 5'b0;
			b5Out3 <= 5'b0;
			b5Out4 <= 5'b0; 
			IstrOut <= 32'b0; 
			R1Out <= 32'b0;
			R2Out <= 32'b0;
			b32Out1 <= 32'b0;
			b32Out2 <= 32'b0;
			b32Out3 <= 32'b0;
			b32Out4 <= 32'b0;
		end
		else if (CLK) begin
			if (statIn) begin
				if (SynClr) begin
					statOut <= 0; 
					HaltOut <= 0;
					shaOut <= 0; 
					DmLdOut <= 0;
					DmStrOut <= 0;
					RegWriteOut <= 0;
					DispOut <= 0;
					PauseOut <= 0;
					M4Out <= 2'b0; 
					M3Out <= 2'b0;
					M2Out <= 2'b0; 
					M1Out <= 2'b0;
					AluOut <= 4'b0; 
					DmSelOut <= 4'b0;
					b5Out1 <= 5'b0; 
					b5Out2 <= 5'b0;
					b5Out3 <= 5'b0;
					b5Out4 <= 5'b0; 
					IstrOut <= 32'b0; 
					R1Out <= 32'b0;
					R2Out <= 32'b0;
					b32Out1 <= 32'b0;
					b32Out2 <= 32'b0;
					b32Out3 <= 32'b0;
					b32Out4 <= 32'b0;
				end else begin
					statOut <= statIn; 
					HaltOut <= HaltIn;
					shaOut <= shaIn; 
					DmLdOut <= DmLdIn;
					DmStrOut <= DmStrIn;
					RegWriteOut <= RegWriteIn;
					DispOut <= DispIn;
					PauseOut <= PauseIn;
					M4Out <= M4In; 
					M3Out <= M3In;
					M2Out <= M2In; 
					M1Out <= M1In;
					AluOut <= AluIn; 
					DmSelOut <= DmSelIn;
					b5Out1 <= b5In1; 
					b5Out2 <= b5In2;
					b5Out3 <= b5In3;
					b5Out4 <= b5In4;  
					IstrOut <= IstrIn; 
					R1Out <= R1In;
					R2Out <= R2In;
					b32Out1 <= b32In1;
					b32Out2 <= b32In2;
					b32Out3 <= b32In3;
					b32Out4 <= b32In4;
				end
			end else ;
		end
	end

endmodule
