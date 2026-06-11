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

    reg [31:0] pc;
    wire [31:0] next_pc;
    wire [31:0] instruction;

    // Program Counter (PC)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'h00000000;
        } else if (stall) begin
            // PC holds its value if stalled
            pc <= pc;
        } else begin
            pc <= next_pc;
        end
    end

    // Placeholder for Instruction Memory
    // In a real implementation, this would be an actual memory block
    // For simulation, we can use a simple combinational read or a ROM model
    assign instruction = 32'h00000013; // NOP instruction for now

    assign next_pc = pc + 4;

    // IF/ID Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            if_id_pc_plus_4 <= 32'h00000000;
            if_id_instruction <= 32'h00000000;
        } else if (flush) begin
            if_id_pc_plus_4 <= 32'h00000000;
            if_id_instruction <= 32'h00000013; // Inject NOP on flush
        } else if (~stall) begin
            if_id_pc_plus_4 <= next_pc;
            if_id_instruction <= instruction;
        end
    end

endmodule
