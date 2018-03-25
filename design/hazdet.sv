module hazdet(
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] id_regAdd,
    input logic id_memRead,

    output logic stall_ID,
    output logic stall_EX,
    output logic stall_PC
);
always_comb begin 
    if (id_memRead && ((id_regAdd == rs1) || (id_regAdd == rs2)))
        begin
            stall_ID <= 1'b1;
            stall_EX <= 1'b1;
            stall_PC <= 1'b1;
        end
    else 
        begin
            stall_ID <= 1'b0;
            stall_EX <= 1'b0;
            stall_PC <= 1'b0;
        end
end

endmodule