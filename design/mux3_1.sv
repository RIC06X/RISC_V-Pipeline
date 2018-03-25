`timescale 1ns / 1ps
module mux3_1
    #(parameter WIDTH = 32)
  (input logic [WIDTH-1:0] d0, d1, d2,
     input logic [1:0] s,
     output logic [WIDTH-1:0] 
     y);

always_comb begin
    if (s == 2'b00)
        y <= d0;
    if (s == 2'b01)
        y <= d1;
    if (s == 2'b10)
        y <= d2; 
end

endmodule
