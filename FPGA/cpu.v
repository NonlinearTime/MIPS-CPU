module CPU(RST, clk, stop, continue, low_fre, para_of_clk, out_select, RAM_select, an, seg);
	input RST, clk, stop, continue, low_fre; // 清零信号，时钟信号，暂停信号
	input[2:0] para_of_clk, out_select;
	input[3:0] RAM_select;
	output[7:0] an, seg;

	/*	分频器模块
	输入： 	clk：时钟输入
			para_of_clk: 分频系数
	输出： 	CLK:分配后的时钟。频率为f(clk) * 16^para_ofclk */
	wire CLK;
	Divider dv1(clk, low_fre, para_of_clk, RST, stop, CLK);

	//Ctrl
	wire Pause, Power, CTRL, PcCtrl, En;
	Ctrl ctrl(.En(En), .Pause(Pause), .power(Power), .Ctrl(CTRL), .PcCtrl(PcCtrl));


	/*相关数据统计。如总周期数量，B型指令数，J型指令数，B型指令成功跳转数?*/
	wire EQUAL, LESS; 

	/*相关数据统计。如总周期数量，B型指令数，J型指令数，B型指令成功跳转数?*/
	wire[15:0] ALL, BR, B, J;
	wire [29:0] Istr_EX;
	InstCounter ic1(.clk(CLK),.rst(RST),.halt(CTRL),.EQUAL(EQUAL),.LESS(LESS),.Istr(Istr_EX),.J(J),.B(B),.Br(BR),.All(ALL));
	
	//pc寄存器
	wire[31:0] M4_out, pc, PcIn, AddrOut;
	wire AddrSel;
	Register PC_REG(PcIn, PcCtrl, CLK, RST, pc); 

	//BHT
	wire [31:0] pc_addr_ex, if_pre_pc_addr, if_pre_dest_addr, pre_pc_addr, pre_dest_addr, Addr_EX;
	wire isBranch, entry_hit, pre_result;
	assign pc_addr_ex = Addr_EX - 1;
	BHT BHTable(.clk(CLK), .rst(RST), .if_pc_addr(pc), .pc_addr(pc_addr_ex), .dest_addr(M4_out), .is_success(AddrSel), .op(isBranch), 
				.if_pre_pc_addr(if_pre_pc_addr), .if_pre_dest_addr(if_pre_dest_addr), .pre_result(pre_result), .pre_pc_addr(pre_pc_addr), 
				.pre_dest_addr(pre_dest_addr), .entry_hit(entry_hit));

	//Address transformation
	wire [31:0] PcOut;
	wire BHT_Pre;
	Address Addr (.AddrIn(pc[9:0]), .AddrBranch(M4_out), .AddrSel(AddrSel), .BHT_Pre(BHT_Pre), .AddrOut(AddrOut), .PcOut(PcOut));

	assign PcIn = pre_result ? if_pre_dest_addr : PcOut;

	//ROM
	wire[31:0] Command, CommandOut, Addr_ID;
	insMem rom(pc[9:0], Command);

	//piptline interface
	wire BHT_PRE_ID;
	pipelineInterface IF_ID(.CLK(CLK), .SynClr(AddrSel ^ BHT_Pre), .AsynClr(RST), .statIn(PcCtrl),
							.b32In2(Command), .b32In1(AddrOut), .DispIn(pre_result), 
					  		.b32Out1(Addr_ID), .b32Out2(CommandOut), .DispOut(BHT_PRE_ID));

	//Decoder
	wire[5:0] OP, FUNC;
	wire[4:0] rs, rt, rd, SHAMT;
	wire[15:0] IMM16;
	wire[25:0] IMM26;
	IstrSplit Decoder(.Istr(CommandOut), .RS(rs), .RT(rt), .RD(rd), .IMM16(IMM16),
	 .IMM26(IMM26), .SHAMT(SHAMT), .OP(OP), .FUNC(FUNC));

	//Alu
	wire[3:0] Alu, DmSel;
	wire[1:0] M1, M2, M3, M4;	
	wire [29:0] Istr;
	wire [4:0] Int_ctrl_ID;
	wire [31:0] RS_VAL, RT_VAL;
	wire DmLd, DmStr, Sha, Halt, Disp, BrCount, BCount, JCount, WE_ID;
	controller c1(.OP(OP), .FUNC(FUNC), .RS(RS_VAL), .RT(RT_VAL), .Rd(rd), .Rt(rt), .instruct(CommandOut), 
		.Alu(Alu), .RegWrite(WE_ID), 
		.DmLd(DmLd), .DmStr(DmStr), .DmSel(DmSel), .Sha(Sha), 
		.Halt(Halt), .Disp(Disp), .BrCount(BrCount), .Bcount(BCount), 
		.JCount(JCount), .M1(M1), .M2(M2), .M3(M3), .M4(M4), .Istr(Istr), .Int_ctrl(Int_ctrl_ID)); 
	
	//entender
	wire[31:0] IMM16_extend, IMM26_extend, SHAMT_extend;
	bit_extend extender(IMM16, IMM26, SHAMT, IMM16_extend, IMM26_extend, SHAMT_extend);

	//register file
	wire[31:0] M3_out;
	wire[4:0] M1_out, Int_ctrl_EX ;
	wire RegWrite, ID_EX_CLEAR, WE_WB;
	wire [4:0] M1_Out_WB;
	wire [4:0] rs_EX, rt_EX, rd_EX;
	register_file reg_file(.rA(rs), .rB(rt), .rW(M1_Out_WB),
	 	.W(M3_out), .WE(WE_WB), .clk(CLK), .A(RS_VAL), .B(RT_VAL));// Command register.

	//conflict ctrl(bubble)
	ConfilctCtrl ConfilctCtrl1(.RS(rs), .RT(rt), .RD_ID(rd), .RD_EX(M1_out), .RD_MEM(5'b0), .Istr(Istr), .Istr1(Istr_EX), .Istr2(30'b0), .IF_ID_STOP(Power), .ID_EX_CLEAR(ID_EX_CLEAR));

	//ID/EX interface
	wire [31:0] RS_VAL_EX, RT_VAL_EX, IMM16_EX, IMM26_EX, SHAMT_EX;
	wire DmLd_EX, DmStr_EX, Sha_EX, Disp_EX, Halt_Ex, Pause_EX, WE_EX;
	wire[3:0] Alu_EX, DmSel_EX;
	wire[1:0] M1_EX, M2_EX, M3_EX, M4_EX, M4_EX_OUT;
	pipelineInterface  ID_EX(.CLK(CLK), .SynClr(ID_EX_CLEAR || AddrSel ^ BHT_Pre), .AsynClr(RST), 
	.statIn(CTRL), .IstrIn(Istr), .R1In(RS_VAL), .R2In(RT_VAL), .b32In1(Addr_ID), .b32In2(IMM16_extend), .b32In3(IMM26_extend), .b32In4(SHAMT_extend), .b5In1(Int_ctrl_ID), .b5In2(rs), .b5In3(rt), .b5In4(rd),
	.AluIn(Alu), .DmSelIn(DmSel), .shaIn(Sha), .DmLdIn(DmLd), .DmStrIn(DmStr), .RegWriteIn(WE_ID), .M4In(M4), .M3In(M3), .M2In(M2), .M1In(M1), .DispIn(BHT_PRE_ID),
	.IstrOut(Istr_EX), .R1Out(RS_VAL_EX), .R2Out(RT_VAL_EX), .b32Out1(Addr_EX), .b32Out2(IMM16_EX), .b32Out3(IMM26_EX), .b32Out4(SHAMT_EX), .b5Out1(Int_ctrl_EX), .b5Out2(rs_EX), .b5Out3(rt_EX), .b5Out4(rd_EX),
	.AluOut(Alu_EX), .DmSelOut(DmSel_EX), .shaOut(Sha_EX), .DmLdOut(DmLd_EX), .DmStrOut(DmStr_EX), .RegWriteOut(WE_EX), .M4Out(M4_EX), .M3Out(M3_EX), .M2Out(M2_EX), .M1Out(M1_EX), .DispOut(BHT_Pre));

	//branch
	wire [31:0] RS_Redir_Out, RT_Redir_Out;
	Branch Branch1(.Istr(Istr_EX), .RS(RS_Redir_Out), .RT(RT_Redir_Out), .M4In(M4_EX), .M4Out(M4_EX_OUT), .Disp(Disp_EX), .Halt(Halt_Ex), .Equal(EQUAL), .Less(LESS), .Pause(Pause_EX), .isBranch(isBranch));

	//ALU
	wire[31:0] ShaMux_out;
	wire[31:0] Alu_result;
	wire[31:0] M2_out;
	Alu u_alu(
    	.X      (ShaMux_out),
    	.Y      (M2_out),
    	.AluOP  (Alu_EX),
    	// .Equal  (EQUAL),
    	.Result (Alu_result)
	);

	//redirect
	wire [1:0] RS_Sel, RT_Sel;
	wire [4:0] M1_Out_MEM;
	wire [29:0] Istr_MEM;
	wire [29:0] Istr_WB;
	Redirect Redirecter (.RS(rs_EX), .RT(rt_EX), .RD_MEM(M1_Out_MEM), .RD_WB(M1_Out_WB), .Istr(Istr_EX), .Istr1(Istr_MEM), .Istr2(Istr_WB), .RT_Sel(RT_Sel), .RS_Sel(RS_Sel));

	Two_path_selector ShaMux(RS_Redir_Out, RT_Redir_Out, Sha_EX, ShaMux_out);


	Four_path_selector Mux2(RT_Redir_Out, IMM16_EX, SHAMT_EX, RS_Redir_Out, M2_EX, M2_out);

	Four_path_selector Mux1(rt_EX, rd_EX, 5'h1f, 5'h0, M1_EX, M1_out);

	assign AddrSel = $unsigned(M4_EX_OUT) > $unsigned(2'b00) ;
	Four_path_selector Mux4(Addr_EX, IMM26_EX, IMM16_EX + Addr_EX, ShaMux_out, M4_EX_OUT, M4_out);


	wire [31:0] DmAddrSel_out;
	Four_path_selector RS_Redirect(RS_VAL_EX, DmAddrSel_out, M3_out, DmAddrSel_out, RS_Sel, RS_Redir_Out);
	Four_path_selector RT_Redirect(RT_VAL_EX, DmAddrSel_out, M3_out, DmAddrSel_out, RT_Sel, RT_Redir_Out);

	//EX/MEM
	wire [4:0] Int_ctrl_MEM;
	wire [1:0] M3_MEM;
	wire [3:0] DmSel_MEM;
	wire[31:0] Alu_result_MEM, Addr_MEM, RT_Redir_Out_MEM;
	wire Disp_MEM, Halt_MEM, WE_MEM, Pause_MEM, DmLd_MEM, DmStr_MEM;
	pipelineInterface  EX_MEM (.CLK(CLK), .SynClr(1'b0), .AsynClr(RST), 
	.statIn(CTRL), .IstrIn(Istr_EX), .b32In1(Alu_result), .b32In2(Addr_EX), .b32In3(RT_Redir_Out),  .b5In1(Int_ctrl_EX), .b5In2(M1_out), .PauseIn(Pause_EX),
	.HaltIn(Halt_Ex), .DmSelIn(DmSel_EX), .DmLdIn(DmLd_EX), .DmStrIn(DmStr_EX), .RegWriteIn(WE_EX), .M3In(M3_EX), .DispIn(Disp_EX),
	.IstrOut(Istr_MEM), .b32Out1(Alu_result_MEM), .b32Out2(Addr_MEM), .b32Out3(RT_Redir_Out_MEM),  .b5Out1(Int_ctrl_MEM), .b5Out2(M1_Out_MEM), .PauseOut(Pause_MEM),
	.HaltOut(Halt_MEM), .DmSelOut(DmSel_MEM), .DmLdOut(DmLd_MEM), .DmStrOut(DmStr_MEM), .RegWriteOut(WE_MEM), .M3Out(M3_MEM), .DispOut(Disp_MEM));

	wire efc;
	assign efc = Int_ctrl_MEM[0];
	Two_path_selector DmAddrSel(Alu_result_MEM, 1'b1, efc, DmAddrSel_out);

	wire [31:0] DmCtrl_Out;
	RomShm DmCtrl(.DataIn(RT_Redir_Out_MEM), .SelIn(DmSel_MEM), .DataOut(DmCtrl_Out));

	 wire[31:0] SYSCALL_OUT;
	Register Syscall_REG(DmCtrl_Out, Disp_MEM, CLK, RST, SYSCALL_OUT);

	//ram
	wire[31:0] RAM_out, RAM_show_out;	
	dataMemory DataMem(.showin(RAM_select),.addr(DmAddrSel_out[13:2]),.datain(DmCtrl_Out),
		.str(DmStr_MEM),.ld(DmLd_MEM),.sel(DmSel_MEM),.clk(CLK),.clr(RST),.dataout(RAM_out),.showout(RAM_show_out));

	//MEM/WB
	wire [4:0] Int_ctr3;
	wire [1:0] M3_WB;
	wire Halt_WB, Pause_WB;
	wire[31:0] RAM_out_WB, Addr_WB, DmAddrSel_out_WB;
	pipelineInterface  MEM_WB(.CLK(CLK), .SynClr(1'b0), .AsynClr(RST), 
	.statIn(CTRL), .IstrIn(Istr_MEM), .b32In1(RAM_out), .b32In2(Addr_MEM), .b32In3(DmAddrSel_out), .b5In1(Int_ctrl_MEM), .b5In2(M1_Out_MEM), .PauseIn(Pause_MEM),
	.HaltIn(Halt_MEM), .RegWriteIn(WE_MEM), .M3In(M3_MEM),
	 .IstrOut(Istr_WB), .b32Out1(RAM_out_WB), .b32Out2(Addr_WB), .b32Out3(DmAddrSel_out_WB), .b5Out1(Int_ctr3), .b5Out2(M1_Out_WB), .PauseOut(Pause_WB),
	.HaltOut(Halt_WB), .RegWriteOut(WE_WB), .M3Out(M3_WB));	

	Four_path_selector Mux3(DmAddrSel_out_WB, RAM_out_WB, Addr_WB, 'b1, M3_WB, M3_out);

	//Lock
	Lock lock(.EN(Halt_WB), .CLK(CLK), .RST(RST), .CONT(continue), .pauseIn(Pause_WB), .En(En), .Pause(Pause));

	//七段数码管显示模块
	reg[31:0] show_out;
	display dp1(show_out, clk, an, seg);

	always @(posedge clk) 
	begin
		case(out_select)
			0: show_out = SYSCALL_OUT;
			1: show_out = pc;
			2: show_out = Command;
			3: show_out = {16'b0, ALL};
			4: show_out = {16'b0, J};
			5: show_out = {16'b0, B};
			6: show_out = {16'b0, BR};
			7: show_out = RAM_show_out; //Display the data in RAM.
			default: show_out = show_out;
		endcase
	end
endmodule