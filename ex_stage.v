// ex_stage.v
// Execute Stage

module ex_stage (
    input wire clk,
    input wire reset,

    input wire [31:0] id_ex_pc_plus_4,
    input wire [31:0] id_ex_read_data1,
    input wire [31:0] id_ex_read_data2,
    input wire [4:0]  id_ex_rs1_addr,
    input wire [4:0]  id_ex_rs2_addr,
    input wire [4:0]  id_ex_rd_addr,
    input wire [31:0] id_ex_immediate,
    input wire [2:0]  id_ex_alu_op,
    input wire        id_ex_mem_read,
    input wire        id_ex_mem_write,
    input wire        id_ex_mem_to_reg,
    input wire        id_ex_reg_write,

    output reg [31:0] ex_mem_pc_plus_4,
    output reg [31:0] ex_mem_alu_result,
    output reg [31:0] ex_mem_write_data,
    output reg [4:0]  ex_mem_rd_addr,
    output reg        ex_mem_mem_read,
    output reg        ex_mem_mem_write,
    output reg        ex_mem_mem_to_reg,
    output reg        ex_mem_reg_write,

    input wire [4:0]  mem_wb_rd_addr,
    input wire [31:0] mem_wb_alu_result,
    input wire [31:0] mem_wb_read_data,
    input wire        mem_wb_mem_to_reg,
    input wire        mem_wb_reg_write,

    input wire [4:0]  ex_mem_rd_addr_in, // For forwarding unit
    input wire [1:0]  forward_a, // Forwarding control for ALU input A
    input wire [1:0]  forward_b  // Forwarding control for ALU input B
);

    wire [31:0] alu_operand1;
    wire [31:0] alu_operand2;
    wire [31:0] alu_result_wire;

    // Forwarding Unit logic for ALU operands
    // Operand 1 (rs1)
    always @(*) begin
        case (forward_a)
            2'b00: alu_operand1 = id_ex_read_data1; // No forwarding
            2'b01: alu_operand1 = mem_wb_alu_result; // Forward from MEM/WB (ALU result)
            2'b10: alu_operand1 = mem_wb_read_data; // Forward from MEM/WB (Memory read data)
            default: alu_operand1 = id_ex_read_data1;
        endcase
    end

    // Operand 2 (rs2)
    always @(*) begin
        case (forward_b)
            2'b00: alu_operand2 = id_ex_read_data2; // No forwarding
            2'b01: alu_operand2 = mem_wb_alu_result; // Forward from MEM/WB (ALU result)
            2'b10: alu_operand2 = mem_wb_read_data; // Forward from MEM/WB (Memory read data)
            default: alu_operand2 = id_ex_read_data2;
        endcase
    end

    // ALU (Arithmetic Logic Unit)
    alu alu_inst (
        .operand1(alu_operand1),
        .operand2(alu_operand2),
        .alu_op(id_ex_alu_op),
        .result(alu_result_wire)
    );

    // EX/MEM Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_mem_pc_plus_4 <= 32'h00000000;
            ex_mem_alu_result <= 32'h00000000;
            ex_mem_write_data <= 32'h00000000;
            ex_mem_rd_addr <= 5'b0;
            ex_mem_mem_read <= 1'b0;
            ex_mem_mem_write <= 1'b0;
            ex_mem_mem_to_reg <= 1'b0;
            ex_mem_reg_write <= 1'b0;
        } else begin
            ex_mem_pc_plus_4 <= id_ex_pc_plus_4;
            ex_mem_alu_result <= alu_result_wire;
            ex_mem_write_data <= alu_operand2; // For store instructions
            ex_mem_rd_addr <= id_ex_rd_addr;
            ex_mem_mem_read <= id_ex_mem_read;
            ex_mem_mem_write <= id_ex_mem_write;
            ex_mem_mem_to_reg <= id_ex_mem_to_reg;
            ex_mem_reg_write <= id_ex_reg_write;
        end
    end

endmodule

// ALU module (simplified)
module alu (
    input wire [31:0] operand1,
    input wire [31:0] operand2,
    input wire [2:0]  alu_op,
    output reg [31:0] result
);

    always @(*) begin
        case (alu_op)
            3'b000: result = operand1 + operand2; // ADD
            3'b001: result = operand1 - operand2; // SUB
            3'b010: result = operand1 << operand2; // SLL
            3'b011: result = (operand1 < operand2) ? 1 : 0; // SLT
            3'b100: result = ($unsigned(operand1) < $unsigned(operand2)) ? 1 : 0; // SLTU
            3'b101: result = operand1 ^ operand2; // XOR
            3'b110: result = operand1 >> operand2; // SRL
            3'b111: result = $signed(operand1) >>> operand2; // SRA
            default: result = 32'hxxxxxxxx; // Undefined
        endcase
    end

endmodule
