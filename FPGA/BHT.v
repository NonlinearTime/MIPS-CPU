`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/22 09:17:30
// Design Name: 
// Module Name: BHT
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


module Pri(bits, code, sel);
	input [7:0] bits;
	output [2:0] code;
	output sel;

	assign code = bits[0] ? 3'h0 :
				  bits[1] ? 3'h1 :
				  bits[2] ? 3'h2 :
				  bits[3] ? 3'h3 :
				  bits[4] ? 3'h4 :
				  bits[5] ? 3'h5 :
				  bits[6] ? 3'h6 :
				  			3'h7 ; 
	assign sel = bits != 0;
endmodule

module BHT(clk, rst, if_pc_addr, pc_addr, dest_addr, is_success, op, if_pre_pc_addr, if_pre_dest_addr, pre_result, pre_pc_addr, pre_dest_addr, entry_hit);
	input [31:0] pc_addr, dest_addr, if_pc_addr;
	input is_success, clk, rst;
	input op;

	output [31:0] pre_pc_addr, pre_dest_addr, if_pre_pc_addr, if_pre_dest_addr;
	output pre_result, entry_hit;

	reg Valid[7:0];
	reg [31:0] branch_pc_addr [7:0];
	reg [31:0] branh_dest_addr [7:0];
	reg [1:0] pre_hist [7:0]; 
	reg [7:0] replace_bit [7:0];
	reg [7:0] max_use_times = 0;

	wire [2:0] pos, free_pos, replace_pos, pc_addr_pos, if_pc_addr_pos;
	wire [7:0] free_cmp, replace_cmp, pc_addr_cmp, if_pc_addr_cmp;
	wire free_sel, replace_sel, if_entry_hit;

	//find free entry
	assign free_cmp = {Valid[7] == 0, Valid[6] == 0, Valid[5] == 0, Valid[4] == 0, Valid[3] == 0, Valid[2] == 0, Valid[1] == 0, Valid[0] == 0};
	Pri free_pri (free_cmp, free_pos, free_sel);

	//find entry to replace
	assign replace_cmp = {replace_bit[7] == max_use_times && Valid[7] != 0, replace_bit[6] == max_use_times && Valid[7] != 0, 
						  replace_bit[5] == max_use_times && Valid[7] != 0, replace_bit[4] == max_use_times && Valid[7] != 0, 
						  replace_bit[3] == max_use_times && Valid[7] != 0, replace_bit[2] == max_use_times && Valid[7] != 0,
						  replace_bit[1] == max_use_times && Valid[7] != 0, replace_bit[0] == max_use_times && Valid[7] != 0};
	Pri replace_pri (replace_cmp, replace_pos, replace_sel);

	//decide which position to write
	assign pos = free_cmp == 0 ? replace_pos : free_pos;

	//find right entry during exe state
	assign pc_addr_cmp = {pc_addr == branch_pc_addr[7] && Valid[7] != 0, pc_addr == branch_pc_addr[6] && Valid[6] != 0, 
						  pc_addr == branch_pc_addr[5] && Valid[5] != 0, pc_addr == branch_pc_addr[4] && Valid[4] != 0,
					  	  pc_addr == branch_pc_addr[3] && Valid[3] != 0, pc_addr == branch_pc_addr[2] && Valid[2] != 0, 
					  	  pc_addr == branch_pc_addr[1] && Valid[1] != 0, pc_addr == branch_pc_addr[0] && Valid[0] != 0}; 

	Pri pc_pri (pc_addr_cmp, pc_addr_pos, entry_hit);

	//output entry found
	assign pre_pc_addr = branch_pc_addr[pc_addr_pos];
	assign pre_dest_addr = branh_dest_addr[pc_addr_pos];

	//find right entry during if
	assign if_pc_addr_cmp = {if_pc_addr == branch_pc_addr[7] && Valid[7] != 0, if_pc_addr == branch_pc_addr[6] && Valid[6] != 0, 
						  if_pc_addr == branch_pc_addr[5] && Valid[5] != 0, if_pc_addr == branch_pc_addr[4] && Valid[4] != 0,
					  	  if_pc_addr == branch_pc_addr[3] && Valid[3] != 0, if_pc_addr == branch_pc_addr[2] && Valid[2] != 0, 
					  	  if_pc_addr == branch_pc_addr[1] && Valid[1] != 0, if_pc_addr == branch_pc_addr[0] && Valid[0] != 0}; 

	Pri if_pc_pri (if_pc_addr_cmp, if_pc_addr_pos, if_entry_hit);

	//output entry found
	assign if_pre_pc_addr = branch_pc_addr[if_pc_addr_pos];
	assign if_pre_dest_addr = branh_dest_addr[if_pc_addr_pos];
	assign pre_result = if_entry_hit ? pre_hist[if_pc_addr_pos] == 2'b10 || pre_hist[if_pc_addr_pos] == 2'b11 : 0;				  	  
	

	//initial
	integer i = 0;

	initial begin
		for (i = 0 ; i < 8 ; i = i + 1) begin
			Valid[i] = 0;
			replace_bit[i] = 0;
			branch_pc_addr[i] = 0;
			branh_dest_addr[i] = 0;
			pre_hist[i] = 0;
		end
		max_use_times = 0;
	end

	//write entry
	always @(posedge clk or posedge rst) begin
		max_use_times = 0;
		max_use_times = replace_bit[0] > max_use_times ? replace_bit[0] : max_use_times;
		max_use_times = replace_bit[1] > max_use_times ? replace_bit[1] : max_use_times;
		max_use_times = replace_bit[2] > max_use_times ? replace_bit[2] : max_use_times;
		max_use_times = replace_bit[3] > max_use_times ? replace_bit[3] : max_use_times;
		max_use_times = replace_bit[4] > max_use_times ? replace_bit[4] : max_use_times;
		max_use_times = replace_bit[5] > max_use_times ? replace_bit[5] : max_use_times;
		max_use_times = replace_bit[6] > max_use_times ? replace_bit[6] : max_use_times;
		max_use_times = replace_bit[7] > max_use_times ? replace_bit[7] : max_use_times;
		if (rst) begin
			// reset
			Valid[0] = 0;
			Valid[1] = 0;
			Valid[2] = 0;
			Valid[3] = 0;
			Valid[4] = 0;
			Valid[5] = 0;
			Valid[6] = 0;
			Valid[7] = 0;
			max_use_times = 0;
		end else if (op) begin
			replace_bit[0] = replace_bit[0] + 1;
			replace_bit[1] = replace_bit[1] + 1;
			replace_bit[2] = replace_bit[2] + 1;
			replace_bit[3] = replace_bit[3] + 1;
			replace_bit[4] = replace_bit[4] + 1;
			replace_bit[5] = replace_bit[5] + 1;
			replace_bit[6] = replace_bit[6] + 1;
			replace_bit[7] = replace_bit[7] + 1;
			max_use_times = max_use_times + 1;
			if (entry_hit) begin
				replace_bit[pc_addr_pos] = 0;
				if (is_success) begin
					case (pre_hist[pc_addr_pos]) 
						// 2'b00: pre_hist[pc_addr_pos] = pre_hist[pc_addr_pos] + 1;
						// 2'b01: pre_hist[pc_addr_pos] = 2'b11;
						2'b10: pre_hist[pc_addr_pos] = pre_hist[pc_addr_pos] + 1;
						2'b11: pre_hist[pc_addr_pos] = pre_hist[pc_addr_pos];
					endcase
				end else begin
					case (pre_hist[pc_addr_pos]) 
						2'b00: pre_hist[pc_addr_pos] = pre_hist[pc_addr_pos];
						2'b01: pre_hist[pc_addr_pos] = pre_hist[pc_addr_pos] - 1;
						// 2'b10: pre_hist[pc_addr_pos] = 2'b00;
						// 2'b11: pre_hist[pc_addr_pos] = pre_hist[pc_addr_pos] - 1;
					endcase
				end 
			end else begin
				branch_pc_addr[pos] = pc_addr;
				branh_dest_addr[pos] = dest_addr;
				replace_bit[pos] = 0;
				pre_hist[pos] = is_success ? 2'b10 : 2'b01;
				Valid[pos] = 1;
			end
		end else;
	end
endmodule


