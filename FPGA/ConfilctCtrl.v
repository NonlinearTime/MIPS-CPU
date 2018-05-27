`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/20 09:55:38
// Design Name: 
// Module Name: ConfilctCtrl
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


module ConfilctCtrl(RS, RT, RD_ID, RD_EX, RD_MEM, Istr, Istr1, Istr2, IF_ID_STOP, ID_EX_CLEAR);
	input [4:0] RS, RT, RD_ID, RD_EX, RD_MEM;
	input [29:0] Istr, Istr1, Istr2;
	output IF_ID_STOP, ID_EX_CLEAR;

	wire addi,addiu,andi,ori,lw,sw,beq,bne,slti,j,jal,sb,bltz,add,addu,_and,sub,_or,_nor,slt,sltu,srlv,srav,sll,sra,srl,jr,syscall,efc,etc;
	wire addi1,addiu1,andi1,ori1,lw1,sw1,beq1,bne1,slti1,j1,jal1,sb1,bltz1,add1,addu1,_and1,sub1,_or1,_nor1,slt1,sltu1,srlv1,srav1,sll1,sra1,srl1,jr1,syscall1,efc1,etc1;
	wire addi2,addiu2,andi2,ori2,lw2,sw2,beq2,bne2,slti2,j2,jal2,sb2,bltz2,add2,addu2,_and2,sub2,_or2,_nor2,slt2,sltu2,srlv2,srav2,sll2,sra2,srl2,jr2,syscall2,efc2,etc2;

	wire RD_RS1, RD_RT1, RD_RS2, RD_RT2;
	wire RS_RT, __RS, __RT, __RD1, __RD2;
	wire WriteReg1, WriteReg2;

	assign {etc, efc, syscall, jr ,srl, sra, sll, srav, srlv, sltu, slt, _nor, _or, sub, _and, addu, add, bltz, sb, jal, j, slti, bne, beq, sw, lw, ori, andi, addiu, addi} = Istr;
	assign {etc1, efc1, syscall1, jr1, srl1, sra1, sll1, srav1, srlv1, sltu1, slt1, _nor1, _or1, sub1, _and1, addu1, add1, bltz1, sb1, jal1, j1, slti1, bne1, beq1, sw1, lw1, ori1, andi1, addiu1, addi1} = Istr1;
	assign {etc2, efc2, syscall2, jr2, srl2, sra2, sll2, srav2, srlv2, sltu2, slt2, _nor2, _or2, sub2, _and2, addu2, add2, bltz2, sb2, jal2, j2, slti2, bne2, beq2, sw2, lw2, ori2, andi2, addiu2, addi2} = Istr2;
	
	assign RD_RS1 = (RS != 0) && (RD_EX == RS);
	assign RD_RT1 = (RT != 0) && (RD_EX == RT);
	assign RD_RS2 = (RS != 0) && (RD_MEM == RS);
	assign RD_RT2 = (RT != 0) && (RD_MEM == RT);

	assign RS_RT = sw || add || addu || _and || sub || _or || _nor || syscall || bne || beq || sltu || slt || srav || srlv || lw;
	assign __RS = addi || addiu || andi || ori || jal || jr || slti || bltz;
	assign __RT = sll || sb || etc || srl || sra;
	assign __RD1 = addi1 || _and1 || lw1 || addiu1 || slti1 || ori1 || jal1 || add1 || addu1 || _and1 || efc1 || _or1 || sub1 || slt1 || _nor1 || srlv1 || sltu1 || sll1 || srav1 || srl1 || sra1;
	assign __RD2 = addi2 || _and2 || lw2 || addiu2 || slti2 || ori2 || jal2 || add2 || addu2 || _and2 || efc2 || _or2 || sub2 || slt2 || _nor2 || srlv2 || sltu2 || sll2 || srav2 || srl2 || sra2;
	
	assign WriteReg1 = (RD_EX != 0) && __RD1;
	assign WriteReg2 = (RD_MEM != 0) && __RD2;

	assign IF_ID_STOP = lw1 == 0 ? 1 : 
						(~(((RD_RS1 || RD_RT1) && RS_RT && WriteReg1) || (RD_RT1 && __RT && WriteReg1) || (RD_RS1 && __RS && WriteReg1))) &&
						(~(((RD_RS2 || RD_RT2) && RS_RT && WriteReg2) || (RD_RT2 && __RT && WriteReg2) || (RD_RS2 && __RS && WriteReg2)));
	assign ID_EX_CLEAR = ~IF_ID_STOP;

endmodule
