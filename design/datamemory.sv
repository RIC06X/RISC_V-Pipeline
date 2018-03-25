`timescale 1ns / 1ps

module datamemory#(
    parameter DM_ADDRESS = 9 ,
    parameter DATA_W = 32
    )(
    input logic clk,
	input logic MemRead , // comes from control unit
    input logic MemWrite , // Comes from control unit
    input logic [ DM_ADDRESS -1:0] a , // Read / Write address - 9 LSB bits of the ALU output
    input logic [ DATA_W -1:0] wd , // Write Data
    input logic [2:0] func3,
    output logic [ DATA_W -1:0] rd // Read Data
    );
    
    logic [DATA_W-1:0] mem [(2**DM_ADDRESS)-1:0];
    //Load
    always_comb 
    begin
       if(MemRead)
            case(func3)
                3'b000:
                    rd = {mem[a][7]? 24'hffffff:24'b0, mem[a][7:0]};                //LB
                3'b001:
                    rd = {mem[a][15]? 16'hffff:16'b0, mem[a][15:0]};                //LH
                3'b010:
                    rd = mem[a];                                                    //LW
                3'b100:
                    rd = {24'b0, mem[a][7:0]};                                      //LBU
                3'b101:
                    rd = {16'b0, mem[a][15:0]};                                     //LBU
            default:
                rd = mem[a];
            endcase
	end
    //Store
    always @(posedge clk) begin
       if (MemWrite)
            case(func3)
                3'b000:
                    mem[a] ={wd[7]? 24'hffffff:24'b0,wd[7:0]};                      //SB
                3'b001:
                    mem[a]= {wd[15]? 16'hffff:16'b0,wd[15:0]};                      //SH
                3'b010:
                    mem[a] = wd;                                                    //SW
            default:
                mem[a] = wd;
            endcase
    end
    
endmodule

