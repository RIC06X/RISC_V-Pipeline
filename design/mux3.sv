`timescale 1ns / 1ps


module mux3
    #(parameter WIDTH = 9)
    (input logic [WIDTH-1:0] d0, d2,        //pc+4   rs1+ imme
     input logic [31:0] d1,                 //pc+imme
     input logic b,                         //branch_control
     input logic[1:0] v,                    //mux output select
     output logic [WIDTH-1:0] y,            //next pc
     output logic [31:0] z                  //write_data to register file 
     );

  always_comb begin 
    if (b == 1'b1 && v == 2'b00)            //branch
        y <= d1[WIDTH-1:0];
    else if (v == 2'b01)            //auipc
        z <= d1; 
    else if (v == 2'b10)            //jal
        begin 
            z <= {23'b0,d0}; 
            y <= d1[WIDTH-1:0];
        end
    else if (v == 2'b11)            //jalr
        begin
            z <= d0; 
            y <= d2;
        end
    else 
        begin
            y <= d0;    
        end
  end
endmodule