package reg_pkg;

typedef struct packed{
    logic [8:0] pc_next;
    logic [31:0] instr;
}if_reg;

typedef struct packed{
    //if_stage
    logic [8:0] pc_next;
    
    //EX
    logic ALUSrc;   //0: The second ALU operand comes from the second register file output (Read data 2); 
                    //1: The second ALU operand is the sign-extended; lower 16 bits of the instruction.
    logic [1:0] ALUOp;

    //WB
    logic MemtoReg; //0: The value fed to the register Write data input comes from the ALU.
                    //1: The value fed to the register Write data input comes from the data memory.
    logic RegWrite; //The register on the Write register input is written with the value on the Write data input 
    logic [1:0] PC_Reg;     //Write_back signal

    //M
    logic MemRead;  //Data memory contents designated by the address input are put on the Read data output
    logic MemWrite; //Data memory contents designated by the address input are replaced by the value on the Write data input.
    logic Branch;   //0: branch is not taken; 1: branch is taken
    
    //regsister-output
    logic [31:0] Rs1;
    logic [31:0] Rs2;
    //imme ouput
    logic [31:0] imme;
    //For ALU controller
    logic [6:0] Funct7; // bits 25 to 31 of the instruction
    logic [2:0] Funct3; // bits 12 to 14 of the instruction

    logic [4:0] addRs1;
    logic [4:0] addRs2;
    //Write_Back register Address
    logic [4:0] WriteRegister;

    //Space left for Forwarding unit

}id_reg;

typedef struct packed{
    //if_stage
    logic [8:0] pc_next;

    //WB
    logic MemtoReg; //0: The value fed to the register Write data input comes from the ALU.
                    //1: The value fed to the register Write data input comes from the data memory.
    logic RegWrite; //The register on the Write register input is written with the value on the Write data input 
    logic [1:0] PC_Reg;     //Write_back signal

    //M
    logic MemRead;  //Data memory contents designated by the address input are put on the Read data output
    logic MemWrite; //Data memory contents designated by the address input are replaced by the value on the Write data input.
    logic Branch;   //0: branch is not taken; 1: branch is taken
    logic [2:0] Funct3; // bits 12 to 14 of the instruction

    logic [31:0] PC_Imme;
    logic zero;
    logic [31:0] ALU_Result;
    logic [31:0] Rs2;
    
    //Write_Back register Address
    logic [4:0] WriteRegister;
}ex_reg;

typedef struct packed{
    //WB
    logic MemtoReg; //0: The value fed to the register Write data input comes from the ALU.
                    //1: The value fed to the register Write data input comes from the data memory.
    logic RegWrite; //The register on the Write register input is written with the value on the Write data input 
    logic [1:0] PC_Reg;     //Write_back signal

    logic [31:0] Mem_Data;
    logic [31:0] ALU_Result;
    
    logic [4:0] WriteRegister;    
    logic [31:0] PC_Data;  //Come from the 2 to 1 mux

}mem_reg;

endpackage