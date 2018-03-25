

module forward_unit(
    input  logic [4:0]    rs1,
    input  logic [4:0]    rs2,
    input  logic  ex_regWrite,
    input  logic [4:0] ex_RegAdd,
    input  logic  mem_regWrite,
    input  logic [4:0] mem_RegAdd,

    output logic [1:0] forwardA,
    output logic [1:0] forwardB
);
always_comb begin
    if (ex_regWrite && ex_RegAdd!=5'b0 && (ex_RegAdd == rs1))
        forwardA <= 2'b10;
    else if (mem_regWrite && mem_RegAdd!=5'b0 && (mem_RegAdd == rs1))
        forwardA <= 2'b01;
    else 
        forwardA <= 2'b00;
    if (ex_regWrite && ex_RegAdd!=5'b0 && (ex_RegAdd == rs2))
        forwardB <= 2'b10;
    else if (mem_regWrite && mem_RegAdd!=5'b0 && (mem_RegAdd == rs2))
        forwardB <= 2'b01;
    else    
        forwardB <= 2'b00;
end

endmodule