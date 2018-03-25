`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2018 10:10:33 PM
// Design Name: 
// Module Name: Datapath
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
import reg_pkg::*;
module Datapath #(
    parameter PC_W = 9, // Program Counter
    parameter INS_W = 32, // Instruction Width
    parameter RF_ADDRESS = 5, // Register File Address
    parameter DATA_W = 32, // Data WriteData
    parameter DM_ADDRESS = 9, // Data Memory Address
    parameter ALU_CC_W = 4 // ALU Control Code Width
    )
    (
    input logic clk, rst, // global clock                   // reset , sets the PC to zero
    output logic [DATA_W-1:0] WB_Data                           //ALU_Result
    );
    //PC
    logic [PC_W-1:0] PC, PC_1, PC_Next;
    logic [DATA_W-1:0]  PC_2, PC_Data;
    logic zero, br_mux;
    //    IF/ID
    logic [INS_W-1:0] Instr;
    logic [DATA_W-1:0] Reg1, Reg2;
    logic ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch;
    logic [1:0] ALUop;
    logic [1:0] PC_Reg;
    logic [6:0] Funct7;
    logic [2:0] Funct3;
    logic [3:0] Operation;
    logic [DATA_W-1:0] ExtImm;
    logic [DATA_W-1:0] SrcB, ALUResult;
    logic [DATA_W-1:0] Data_out;
    logic [DATA_W-1:0] PResult,Result;

    //  Forward_Unit
    logic [1:0] forwardA, forwardB;

    //Hazard Detection
    logic stall_ID;
    logic stall_EX;
    logic stall_PC;

    // next PC      NEED TO BE MODIFIED
    adder #(9) pcadd (PC, 9'b100, PC_1);
    mux3  #(9) mux3_pc(PC_1, exreg.ALU_Result[PC_W-1:0], exreg.PC_Imme, br_mux, exreg.PC_Reg, PC_Next, PC_Data);
    flopr #(9) pcreg(clk, rst, stall_PC, PC_Next, PC);      // Need to be modified

    //  IF/ID
    instructionmemory instr_mem (PC, Instr);
    //need modify 
    //need modify

    if_reg  ifreg;
    always_ff @(posedge clk) begin
    if(rst==1'b1 || stall_ID ==1'b1)
        begin
        ifreg.pc_next <= 9'b0;
        ifreg.instr <= 32'b0 ; 
        end
    else
        begin
        ifreg.pc_next <= PC;
        ifreg.instr <= Instr; 
        end
    end
    //need modify
    RegFile rf(clk, rst, memreg.RegWrite, memreg.WriteRegister, ifreg.instr[19:15], ifreg.instr[24:20], Result, Reg1, Reg2);
    
    Controller c(ifreg.instr[6:0], ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUop, PC_Reg);
    imm_Gen Ext_Imm (ifreg.instr, ExtImm);
    //need modify
    hazdet haz(ifreg.instr[19:15], ifreg.instr[24:20], idreg.WriteRegister, idreg.MemRead, stall_ID, stall_EX, stall_PC);

    //  ID/EX
    id_reg  idreg;
    always_ff @(posedge clk) begin
        if(rst==1'b1 || stall_EX==1'b1 )
            begin
                idreg.pc_next   <= 9'b0;
                idreg.ALUSrc    <= 1'b0;
                idreg.ALUOp     <= 2'b0;
                idreg.MemtoReg  <= 1'b0;
                idreg.RegWrite  <= 1'b0;
                idreg.PC_Reg    <= 2'b0;
                idreg.MemRead   <= 1'b0;
                idreg.MemWrite  <= 1'b0;
                idreg.Branch    <= 1'b0;
                idreg.Rs1       <= 32'b0;
                idreg.Rs2       <= 32'b0;
                idreg.imme      <= 32'b0;
                idreg.Funct3    <= 3'b0;
                idreg.Funct7    <= 7'b0;
                idreg.addRs1    <= 5'b0;
                idreg.addRs2    <= 5'b0;
                idreg.WriteRegister  <= 5'b0;
            end
        else
            begin
                idreg.pc_next   <= ifreg.pc_next;
                idreg.ALUSrc    <= ALUSrc;
                idreg.ALUOp     <= ALUop;
                idreg.MemtoReg  <= MemtoReg;
                idreg.RegWrite  <= RegWrite;
                idreg.PC_Reg    <= PC_Reg;
                idreg.MemRead   <= MemRead;
                idreg.MemWrite  <= MemWrite;
                idreg.Branch    <= Branch;
                idreg.Rs1       <= Reg1;
                idreg.Rs2       <= Reg2;
                idreg.imme      <= ExtImm;
                idreg.Funct3    <= ifreg.instr[14:12];
                idreg.Funct7    <= ifreg.instr[31:25];
                idreg.addRs1    <= ifreg.instr[19:15];
                idreg.addRs2    <= ifreg.instr[24:20];
                idreg.WriteRegister  <= ifreg.instr[11:7];
            end
    end

    adder #(32) immadd ({23'b0, idreg.pc_next}, idreg.imme, PC_2);

    logic [3:0] ALU_CC_Output;
    ALUController ac(idreg.ALUOp, idreg.Funct7 , idreg.Funct3, ALU_CC_Output);

    logic [31:0] outputA;
    logic [31:0] outputB;
    mux3_1 inputA(idreg.Rs1 , exreg.ALU_Result,memreg.ALU_Result, forwardA, outputA);
    mux3_1 inputB(idreg.Rs2 , exreg.ALU_Result,memreg.ALU_Result, forwardB, outputB);

    mux2 #(32) srcbmux(outputB, idreg.imme, idreg.ALUSrc, SrcB);
    alu alu_module(outputA, SrcB, ALU_CC_Output, ALUResult, zero);

    //Foward unit
    forward_unit fdu(idreg.addRs1, idreg.addRs2, exreg.RegWrite, exreg.WriteRegister, memreg.RegWrite, memreg.WriteRegister, forwardA, forwardB);

    //  EX/MEM
    ex_reg exreg;
    always_ff @(posedge clk) begin
        if(rst==1'b1)
            begin
                exreg.pc_next   <= 9'b0;
                exreg.MemtoReg  <= 1'b0;
                exreg.RegWrite  <= 1'b0;
                exreg.PC_Reg    <= 2'b0;
                exreg.MemRead   <= 1'b0;
                exreg.MemWrite  <= 1'b0;
                exreg.Branch    <= 1'b0; 
                exreg.Funct3    <= 3'b0;
                exreg.PC_Imme   <= 32'b0;
                exreg.zero      <= 1'b0;
                exreg.ALU_Result<= 32'b0;
                exreg.Rs2       <= 32'b0;
                exreg.WriteRegister <= 5'b0;
            end
        else
            begin
                exreg.pc_next   <= idreg.pc_next;
                exreg.MemtoReg  <= idreg.MemtoReg;
                exreg.RegWrite  <= idreg.RegWrite;
                exreg.PC_Reg    <= idreg.PC_Reg;
                exreg.MemRead   <= idreg.MemRead;
                exreg.MemWrite  <= idreg.MemWrite;
                exreg.Branch    <= idreg.Branch ; 
                exreg.Funct3    <= idreg.Funct3 ;
                exreg.PC_Imme   <= idreg.imme;
                exreg.zero      <= zero;
                exreg.ALU_Result<= ALUResult;
                exreg.Rs2       <= idreg.Rs2;
                exreg.WriteRegister <= idreg.WriteRegister;
            end
    end
    andgate #(1) b_andgate(exreg.Branch, exreg.zero , br_mux);
	  datamemory data_mem (clk, exreg.MemRead , exreg.MemWrite, exreg.ALU_Result[DM_ADDRESS-1:0], exreg.Rs2 , exreg.Funct3 , Data_out);

    //  MEM/WB
    mem_reg   memreg;
    always_ff @(posedge clk) begin
        if(rst==1'b1)
            begin
                memreg.MemtoReg <= 1'b0;
                memreg.RegWrite <= 1'b0;
                memreg.PC_Reg   <= 2'b0;
                memreg.Mem_Data <=  32'b0;
                memreg.ALU_Result <= 32'b0;
                memreg.WriteRegister <= 5'b0;
                memreg.PC_Data  <= 32'b0;
            end
        else
            begin 
                memreg.MemtoReg <= exreg.MemtoReg;
                memreg.RegWrite <= exreg.RegWrite;
                memreg.PC_Reg   <= exreg.PC_Reg;
                memreg.Mem_Data <=  Data_out;
                memreg.ALU_Result <= exreg.ALU_Result;
                memreg.WriteRegister <= exreg.WriteRegister;
                memreg.PC_Data  <= PC_Data;
            end
    end

    mux2 #(32) presmux(memreg.ALU_Result, memreg.Mem_Data, memreg.MemtoReg, PResult);
    mux2_2 #(32) resmux(PResult,memreg.PC_Data, memreg.PC_Reg,Result);
    
    assign WB_Data = Result; 
    //final result, for check only
     
endmodule