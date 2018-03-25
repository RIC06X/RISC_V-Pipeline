`timescale 1ns / 1ps

module andgate
    #(parameter WIDTH = 1)
    (input logic [WIDTH-1:0] a, b,
     output logic [WIDTH-1:0] y);


assign y = a & b;

endmodule
