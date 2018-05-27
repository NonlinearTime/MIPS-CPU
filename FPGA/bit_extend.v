module bit_extend(IMM16_in, IMM26_in, SHMAT_in, IMM16_out, IMM26_out, SHMAT_out);
    input[15:0] IMM16_in;
    input[25:0] IMM26_in;
    input[4:0] SHMAT_in;                                  // ϵͳʱ��
    output[31:0] IMM16_out;
    output[31:0] IMM26_out;
    output[31:0] SHMAT_out;                             // ��Ƶ���ʱ��
	assign IMM26_out = {6'b0, IMM26_in};
	assign IMM16_out = {{16{IMM16_in[15]}}, IMM16_in};
	assign SHMAT_out = {27'b0, SHMAT_in};
	                                                 // ����ʵ��
endmodule
