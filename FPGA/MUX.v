module Four_path_selector(data_in_0, data_in_1, data_in_2, data_in_3, select, data_out);
	input[31:0] data_in_0, data_in_1, data_in_2, data_in_3;
	input[1:0] select;
	output[31:0] data_out;
	assign data_out = select[1] ? (select[0]?data_in_3:data_in_2) : (select[0]?data_in_1:data_in_0);
endmodule 

module Two_path_selector(data_in_0, data_in_1, select, data_out);
	input[31:0] data_in_0, data_in_1;
	input select;
	output[31:0] data_out;
	assign data_out = select ? data_in_1: data_in_0;
endmodule 

module MUX_test;
	reg[31:0] data_in_0 = 0, data_in_1 = 1, data_in_2 = 2, data_in_3 = 3;
	reg[1:0] select_4_path = 0;
	reg select_2_path = 0;
	wire[31:0] data_out_4_path, data_out_2_path;
	Four_path_selector MUX1(data_in_0, data_in_1, data_in_2, data_in_3, select_4_path, data_out_4_path);
	Two_path_selector MUX2(data_in_0, data_in_1, select_2_path, data_out_2_path);
	initial
	 forever {select_4_path, select_2_path}
	 	 = #5 {select_4_path + 2'b1, select_2_path + 1'b1};
endmodule