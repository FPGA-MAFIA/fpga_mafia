
module idu 
// import idu_pkg::*;
(
    input logic [31:0] PC1_in,
    input logic [31:0] PC2_in,
    input logic [31:0] instr1,       
    input logic [31:0] instr2,
    output logic [31:0] PC1_out,
    output logic [31:0] PC2_out,      
    output logic [31:0] issue_instr1, // Instruction for primary issue
    output logic [31:0] issue_instr2,  // Instruction for secondary issue
    output logic issue2ValidN
);

    // General FIXME - should use parameters in package instead of direct opcode
    
    // Dependency Flags
    logic raw_dependency;  // Read-After-Write (RAW)
    logic waw_dependency;  // Write-After-Write (WAW)
    logic branch_jmp_instr;    // Branch detection
    logic mem_access_instr1; // Memory access detection for instr1
    logic mem_access_instr2; // Memory access detection for instr2
    logic flip_instructions;
    logic ebreak_instruction;

    logic [6:0] opcode1, opcode2;    // Opcode fields for instr1 and instr2
    logic [4:0] rd1, rs1_1, rs2_1;  // Fields for instr1
    logic [4:0] rd2, rs1_2, rs2_2;  // Fields for instr2
    logic rd1_valid, rs1_2_valid,rs2_2_valid;

    assign opcode1 = instr1[6:0];
    assign opcode2 = instr2[6:0];

    assign rd1 = instr1[11:7];
    assign rs1_1 = instr1[19:15];
    assign rs2_1 = instr1[24:20];

    assign rd2 = instr2[11:7];
    assign rs1_2 = instr2[19:15];
    assign rs2_2 = instr2[24:20];

    assign rd1_valid    = (opcode1 != 7'b0100011) && (opcode1 != 7'b1100011) && (opcode1 != 7'b0001111);
    assign rs1_2_valid  = (opcode2 != 7'b0010111) && (opcode2 != 7'b0110111);
    assign rs2_2_valid  = (opcode2 == 7'b0110011) || (opcode2 == 7'b0100011) || (opcode2 == 7'b1100011) && rs1_2_valid;

    assign raw_dependency =  rd1_valid && (((rs1_2 == rd1) && (rs1_2_valid) && (rd1 != 5'b0)) || ((rs2_2 == rd1) && (rs2_2_valid) && (rd1 != 5'b0)));

    assign waw_dependency = (rd1 == rd2) && (rd1 != 5'b0);

    // Branch Detection
    assign branch_jmp_instr = (opcode1 == 7'b1100011) || (opcode1 == 7'b1101111 ) ||  (opcode1 == 7'b1100111  ) ||
                              (opcode2 == 7'b1100011) || (opcode2 == 7'b1101111 ) ||  (opcode2 == 7'b1100111  ); 

    // Memory Access Detection
    assign mem_access_instr1 = (opcode1 == 7'b0000011) || // Load instructions
                               (opcode1 == 7'b0100011);  // Store instructions

    assign mem_access_instr2 = (opcode2 == 7'b0000011) || // Load instructions
                               (opcode2 == 7'b0100011);  // Store instructions
    
    // Ebrake call
    assign ebreak_instruction = (instr1 == 32'b000000000001_00000_000_00000_1110011 || instr1 == 32'b000000000000000000000000010011 || instr2 == 32'b000000000001_00000_000_00000_1110011 || instr2 == 32'b000000000000000000000000010011);

    assign issue2ValidN =  (raw_dependency || waw_dependency || branch_jmp_instr || (mem_access_instr2 && mem_access_instr1) || ebreak_instruction);

    assign flip_instructions = (mem_access_instr2 && mem_access_instr1 == 0) && !issue2ValidN;


    always_comb begin
        // Default assignments
        issue_instr1 = instr1;     
        issue_instr2 = instr2;
        PC1_out = PC1_in;
        PC2_out = PC2_in;     

        // Ensure memory access in primary issue
        if (flip_instructions) begin
            issue_instr1 = instr2;
            issue_instr2 = instr1;
            PC1_out = PC2_in;
            PC2_out = PC1_in;   
        end
    end

endmodule
