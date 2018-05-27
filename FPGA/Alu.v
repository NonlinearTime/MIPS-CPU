`timescale 1ns / 1ps

module Alu (
    input [31:0] X,
    input [31:0] Y,
    input [3:0] AluOP,
    output Equal,
    output reg [31:0] Result
);

assign Equal = (X == Y);
initial Result = 0;
always @(X or Y or AluOP)
begin
    case (AluOP)
        0: Result = X << Y;
        1: Result = $signed (X) >>> $signed (Y);
        2: Result = X >> Y;
        5: Result = X + Y;
        6: Result = X - Y;
        7: Result = X & Y;
        8: Result = X | Y;
        9: Result = X ^ Y;
        10: Result = ~(X | Y);
        11: Result = ($signed(X) < $signed(Y)) ? 1 : 0;
        12: Result = ($unsigned(X) < $unsigned(Y)) ? 1 : 0;
        default: Result = 0;
    endcase // AluOP
end

endmodule