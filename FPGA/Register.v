`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////

module Register(data_in, enable, clk, rst, data_out);
	input[31:0] data_in;
	input enable, clk, rst;
	output reg[31:0] data_out = 0;
	always @(posedge clk or posedge rst)
	begin
		if(rst) data_out = 0;
		else if(enable) data_out = data_in; 
		else data_out = data_out;
	end
endmodule

module Register_test;
	reg[31:0] data_in = 1;
	reg enable = 0, clk = 0 , rst = 0;
	wire[31:0] data_out;
	Register pc(data_in, enable, clk, rst, data_out);
	initial
	begin
		enable <= #100 1;
		rst <= #500 1;
		data_in <= #3 data_in + 1;
		forever {data_in, clk} = #5 {data_in+'b1, ~clk};
	end
endmodule