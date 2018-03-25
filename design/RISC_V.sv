`timescale 1ns / 1ps

module riscv #(
    parameter DATA_W = 32)
    (input logic clk, reset, // clock and reset signals
    output logic [31:0] WB_Data// The ALU_Result
    );

    Datapath dp(clk, reset,  WB_Data);
        
endmodule
