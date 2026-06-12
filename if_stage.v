// if_stage.v
// Instruction Fetch Stage

module if_stage (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,

    output reg [31:0] if_id_pc_plus_4,
    output reg [31:0] if_id_instruction
);

    // ==========================================================
    // Program Counter
    // ==========================================================
    reg [31:0] pc;

    wire [31:0] next_pc;
    wire [31:0] instruction;

    // ==========================================================
    // Instruction Memory
    // ==========================================================
    reg [31:0] instr_mem [0:255];

    initial begin

        // Sample program

        instr_mem[0] = 32'h00500113; // addi x2,x0,5
        instr_mem[1] = 32'h00A00193; // addi x3,x0,10
        instr_mem[2] = 32'h00310233; // add  x4,x2,x3
        instr_mem[3] = 32'h403102B3; // sub  x5,x2,x3

        // Fill remaining memory with NOP

        integer i;
        for(i = 4; i < 256; i = i + 1)
            instr_mem[i] = 32'h00000013;

    end

    // ==========================================================
    // Next PC Logic
    // ==========================================================
    assign next_pc = pc + 32'd4;

    // ==========================================================
    // Instruction Fetch
    // ==========================================================
    assign instruction = instr_mem[pc[9:2]];

    // ==========================================================
    // Program Counter Update
    // ==========================================================
    always @(posedge clk or posedge reset) begin

        if (reset)
            pc <= 32'h00000000;

        else if (~stall)
            pc <= next_pc;

    end

    // ==========================================================
    // IF/ID Pipeline Register
    // ==========================================================
    always @(posedge clk or posedge reset) begin

        if (reset) begin

            if_id_pc_plus_4   <= 32'h00000000;
            if_id_instruction <= 32'h00000000;

        end

        else if (flush) begin

            // Insert NOP during flush

            if_id_pc_plus_4   <= 32'h00000000;
            if_id_instruction <= 32'h00000013;

        end

        else if (~stall) begin

            if_id_pc_plus_4   <= next_pc;
            if_id_instruction <= instruction;

        end

    end

endmodule
