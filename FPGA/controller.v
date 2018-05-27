`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Group RuLaiFo
// Engineer: Haines	
// 
// Create Date: 2018/03/12 15:02:31
// Design Name: 
// Module Name: controller
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

`define OP_R 		6'b0
`define OP_ADDI 	6'h08	//addi
`define OP_ADDIU 	6'h09	//addiu
`define OP_ANDI 	6'h0c	//andi
`define OP_ORI 		6'h0d	//ori
`define OP_LW 		6'h23	//lw
`define OP_SW 		6'h2b	//sw
`define OP_BEQ 		6'h04	//beq
`define OP_BNE 		6'h05	//bne
`define OP_SLTI 	6'h0a	//slti
`define OP_J 		6'h02 	//j
`define OP_JAL 		6'h03	//jal
`define OP_SB 		6'h28	//CCMB: sb
`define OP_BLTZ 	6'h01	//CCMB: bltz

`define FUNC_ADD 	6'h20 	//add
`define FUNC_ADDU 	6'h21	//addu
`define FUNC_AND 	6'h24	//and
`define FUNC_SUB 	6'h22	//sub
`define FUNC_OR 	6'h25	//or
`define FUNC_NOR 	6'h27	//nor
`define FUNC_SLT 	6'h2a	//slt
`define FUNC_SLTU 	6'h2b	//sltu
`define FUNC_SLL 	6'h00	//sll
`define FUNC_SRA 	6'h03	//sra
`define FUNC_SRL 	6'h02 	//srl
`define FUNC_JR 	6'h08	//jr
`define FUNC_SYSCAL	6'h0c 	//syscall
`define FUNC_SRLV 	6'h06	//CCMB: srlv
`define FUNC_SRAV 	6'h07	//CCMB: srav


module controller(OP, FUNC, RS, RT, Rd, Rt, instruct, Alu, RegWrite, DmLd, DmStr, DmSel, Sha, Halt, Disp, BrCount, Bcount, JCount, M1, M2, M3, M4, Istr, Int_ctrl);

input [5:0] OP, FUNC;
input [4:0] Rd, Rt;
input [31:0] RS, RT, instruct; 
wire EQUAL;

output wire RegWrite, DmLd, DmStr, Sha, Halt, Disp, BrCount, Bcount, JCount;
output reg [3:0] Alu;
output wire [3:0] DmSel;
output wire [1:0] M1, M2, M3, M4;
output wire [31:0] Istr;
output wire [4:0] Int_ctrl;

wire addi, addiu, andi, ori, lw, sw, beq, bne, slti, j, jal;
wire add, addu, _and, sub, _or, _nor, slt, sltu, sll, sra, srl, jr, syscall;
wire sb, bltz, srlv, srav; //CCMB

wire opt_add, opt_sub, opt_and, opt_or, opt_sra, opt_srl, opt_sll, opt_nor, opt_cmpu;

wire MFC, MTC, eret, sti, cli, mfc, mtc;
wire [3:0] sel;

assign EQUAL = (RS == RT);

assign  add = (FUNC == `FUNC_ADD && OP == `OP_R) ? 1 : 0;
assign	addu = (FUNC == `FUNC_ADDU && OP == `OP_R) ? 1: 0;
assign	_and  = (FUNC == `FUNC_AND && OP == `OP_R) ? 1: 0;
assign	sub = (FUNC == `FUNC_SUB && OP == `OP_R) ? 1 : 0;
assign	_or = (FUNC == `FUNC_OR && OP == `OP_R) ? 1: 0;
assign	_nor = (FUNC == `FUNC_NOR && OP == `OP_R) ? 1: 0;
assign	slt = (FUNC == `FUNC_SLT && OP == `OP_R) ? 1: 0;
assign	sltu = (FUNC == `FUNC_SLTU && OP == `OP_R) ? 1: 0;
assign	sll = (FUNC == `FUNC_SLL && OP == `OP_R) ? 1: 0;
assign	sra = (FUNC == `FUNC_SRA && OP == `OP_R) ?1 : 0;
assign	srl = (FUNC == `FUNC_SRL && OP == `OP_R) ? 1: 0;
assign	jr = (FUNC == `FUNC_JR && OP == `OP_R) ? 1 : 0;
assign  srlv = (FUNC == `FUNC_SRLV && OP == `OP_R) ? 1 : 0;
assign  srav = (FUNC == `FUNC_SRAV && OP == `OP_R) ? 1 : 0;
assign	syscall = (FUNC == `FUNC_SYSCAL && OP == `OP_R) ? 1: 0;

assign	addi =( OP == `OP_ADDI && OP != `OP_R) ? 1: 0;
assign	addiu = (OP == `OP_ADDIU && OP != `OP_R) ? 1: 0;
assign	andi = (OP == `OP_ANDI && OP != `OP_R) ? 1: 0;
assign	ori = (OP == `OP_ORI && OP != `OP_R) ? 1 : 0;
assign	lw = (OP == `OP_LW && OP != `OP_R) ? 1: 0;
assign	sw = (OP == `OP_SW && OP != `OP_R) ? 1: 0;
assign	beq = (OP == `OP_BEQ && OP != `OP_R) ? 1 : 0 ;
assign	bne = (OP == `OP_BNE && OP != `OP_R) ? 1: 0;
assign	slti = (OP == `OP_SLTI && OP != `OP_R) ? 1:0;
assign	j = (OP == `OP_J && OP != `OP_R) ? 1 : 0;
assign	jal = (OP == `OP_JAL && OP != `OP_R) ? 1: 0;
assign 	bltz = (OP == `OP_BLTZ && OP != `OP_R) ? 1 : 0;
assign  sb = (OP == `OP_SB && OP !=`OP_R) ? 1 : 0;

assign	opt_add = addi | add | addiu | addu | lw | sw | sb;
assign	opt_sub = sub;
assign	opt_and = _and | andi;
assign	opt_or = _or | ori ; 
assign	opt_sra = sra | srav;
assign	opt_srl = srl | srlv;
assign	opt_sll = sll;
assign	opt_nor = _nor;
assign	opt_cmpu = slt | slti | sltu;

assign  MFC = instruct[31:21] == 11'h200;
assign  MTC = instruct[31:21] == 11'h204;
assign  sti = Rd == 0 && MFC;
assign  cli = Rt == 0 && MTC;
assign  mfc = Rd != 0 && MFC;
assign  mtc = Rt != 0 && MTC;
assign  eret = Istr == 32'h42000018;

assign  sel = RS[1:0] == 0 ? 4'h1 : (RS[1:0] == 1 ? 4'h2 : (RS[1:0] == 2 ? 4'h4 : 4'h8));

always @(*) begin
	case({opt_add,opt_sub,opt_and,opt_or,opt_sra,opt_srl,opt_sll,opt_cmpu,opt_nor})
		9'b000000001: Alu = 4'b1010;
		9'b000000010: Alu = 4'b1011;
		9'b000000100: Alu = 4'b0000;
		9'b000001000: Alu = 4'b0010;
		9'b000010000: Alu = 4'b0001;
		9'b000100000: Alu = 4'b1000;
		9'b001000000: Alu = 4'b0111;
		9'b010000000: Alu = 4'b0110;
		9'b100000000: Alu = 4'b0101;
		default : ;
	endcase
end

assign	RegWrite = ~(sw | beq | bne | j | syscall | jr);
assign	DmSel = sb ? sel : 4'hf;
assign	DmLd = lw;
assign	DmStr = sw | sb;
assign	Sha = sll | srl | sra | srlv | srav;
assign	Disp = (syscall == 1 && RS != 32'h0000000a) ? 1 : 0; 
assign	Halt = (syscall == 1 && RS == 32'h0000000a) ? 1 : 0; 
assign	M1[1] = sw | jal | sb;
assign	M1[0] = add | addu | _and | sll | sra | srl | sub | _or | _nor | sw | slt | sltu | srlv | srav | sb | mfc;
assign	M2[1] = sll | srl | jal | sra | srav | srlv;
assign	M2[0] = addiu | andi | addi | ori | lw | sw | jal | slti | sb | srav | srlv;
assign	M3[1] = jal;
assign	M3[0] = lw;
assign	M4[1] = jr;
assign	M4[0] = jr | jal | j;
assign	JCount = jr | jal | j;
assign	Bcount = beq | bne;
assign	BrCount = (EQUAL && beq) | (~EQUAL && bne);

assign  Int_ctrl = {eret, cli, sti, mtc, mfc};
assign  Istr = {MTC, MFC, syscall, jr, srl, sra, 
				sll, srav, srlv, sltu, slt, _nor,
				_or, sub, _and, addu, add, bltz, 
				sb, jal, j, slti, bne, beq, sw, 
				lw, ori, andi, addiu, addi};

endmodule
