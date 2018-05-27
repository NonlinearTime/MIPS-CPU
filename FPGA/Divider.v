`timescale 1ns / 1ps
module Seg_7_display(clk, choose, in, an, seg);
    input[2:0] choose;
    input[3:0] in;
    input clk;
    output reg[7:0] an;
    output reg[7:0] seg;
    always @(*)
    begin
        an = 'b11111111;
        an[choose] = 1'b0;
        case(in)    
            'h0: seg = 'b11000000;
            'h1: seg = 'b11111001;
            'h2: seg = 'b10100100;
            'h3: seg = 'b10110000;
            'h4: seg = 'b10011001;
            'h5: seg = 'b10010010;
            'h6: seg = 'b10000010;
            'h7: seg = 'b11111000;
            'h8: seg = 'b10000000;
            'h9: seg = 'b10010000;
            'ha: seg = 'b10001000;
            'hb: seg = 'b10000011;
            'hc: seg = 'b11000110;
            'hd: seg = 'b10100001;
            'he: seg = 'b10000110;
            'hf: seg = 'b10001110;
            default: seg = 'b11111111;
        endcase
    end
endmodule

module Divider(clk_in, low_fre, para_of_clk, rst, stop, clk_out);
    input clk_in, rst, stop, low_fre;
    input[2:0] para_of_clk;
    output clk_out;
    reg[31:0] counter = 0;
    assign clk_out = low_fre ? counter[21] : counter[para_of_clk];
    always @(posedge clk_in or posedge rst) 
        if(rst) counter = 0;
        else 
        begin
            if(stop) counter = counter;
            else counter = counter + 1;
        end
endmodule

module display(data_in, clk, an, seg);
    input clk;
    input[31:0] data_in;
    output [7:0] an, seg;
    reg[3:0] in;
    reg[2:0] choose = 0;
    reg[16:0] n_clk = 0;
    Seg_7_display sd1(clk,choose, in, an, seg);
    always @(posedge clk)
    begin
        n_clk = n_clk + 1;
        if(n_clk == 100_000)
        begin
            choose = choose + 1;
            in = {data_in[choose * 4 + 3], data_in[choose * 4 + 2], data_in[choose * 4 + 1], data_in[choose * 4]};
            n_clk = 0;
        end;
    end
endmodule

module Divider_test;
    reg clk_in = 0, rst = 0, stop = 0;
    reg[2:0] para_of_clk = 0;
    wire clk_out;
    Divider dv1(clk_in, para_of_clk, rst, stop, clk_out);
    initial
    begin
        stop <= #30 1;
        stop <= #100 0;
        para_of_clk <= #200 1;
        rst <= #1000 1;
        forever clk_in = #5 ~clk_in;
    end
 endmodule
 
 module display_test;
    reg[31:0] data_in = 'h89abcdef;
    reg clk = 0;
    wire[7:0] an, seg;
    display dddd(data_in, clk, an, seg);
    initial forever clk = #5 ~clk;
 endmodule