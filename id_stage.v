// id_stage.v
// Instruction Decode Stage

module id_stage (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,

    input wire [31:0] if_id_pc_plus_4,
    input wire [31:0] if_id_instruction,

    output reg [31:0] id_ex_pc_plus_4,
    output reg [31:0] id_ex_read_data1,
    output reg [31:0] id_ex_read_data2,
    output reg [4:0]  id_ex_rs1_addr,
    output reg [4:0]  id_ex_rs2_addr,
    output reg [4:0]  id_ex_rd_addr,
    output reg [31:0] id_ex_immediate,
    output reg [2:0]  id_ex_alu_op,
    output reg        id_ex_mem_read,
    output reg        id_ex_mem_write,
    output reg        id_ex_mem_to_reg,
    output reg        id_ex_reg_write,

    input wire [4:0]  mem_wb_rd_addr,
    input wire [31:0] mem_wb_alu_result,
    input wire [31:0] mem_wb_read_data,
    input wire        mem_wb_mem_to_reg,
    input wire        mem_wb_reg_write
);

    // Internal signals for instruction decoding
    wire [6:0] opcode = if_id_instruction[6:0];
    wire [4:0] rs1    = if_id_instruction[19:15];
    wire [4:0] rs2    = if_id_instruction[24:20];
    wire [4:0] rd     = if_id_instruction[11:7];
    wire [2:0] funct3 = if_id_instruction[14:12];
    wire [6:0] funct7 = if_id_instruction[31:25];

    // Register File
    reg [31:0] reg_file [0:31];
    wire [31:0] read_data1_from_regfile;
    wire [31:0] read_data2_from_regfile;

    // Initialize register file (for simulation purposes)
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            reg_file[i] = 32'h00000000;
        end
        reg_file[2] = 32'h7ffffff0; // Stack pointer
        reg_file[3] = 32'h10000000; // Global pointer
    end

    assign read_data1_from_regfile = (rs1 != 5'b00000) ? reg_file[rs1] : 32'b0;
    assign read_data2_from_regfile = (rs2 != 5'b00000) ? reg_file[rs2] : 32'b0;

    // Write back to register file
    always @(posedge clk) begin
        if (mem_wb_reg_write) begin
            if (mem_wb_rd_addr != 5'b00000) begin
                if (mem_wb_mem_to_reg) begin
                    reg_file[mem_wb_rd_addr] <= mem_wb_read_data;
                } else begin
                    reg_file[mem_wb_rd_addr] <= mem_wb_alu_result;
                end
            end
        end
    end

    // Control Unit (simplified for common R-type, I-type, S-type, U-type, J-type instructions)
    reg [2:0] alu_op_ctrl;
    reg mem_read_ctrl, mem_write_ctrl, mem_to_reg_ctrl, reg_write_ctrl;
    reg [31:0] immediate_ctrl;

    always @(*) begin
        // Default values
        alu_op_ctrl = 3'b000; // ALU_ADD
        mem_read_ctrl = 1'b0;
        mem_write_ctrl = 1'b0;
        mem_to_reg_ctrl = 1'b0;
        reg_write_ctrl = 1'b0;
        immediate_ctrl = 32'b0;

        case (opcode)
            7'b0110011: begin // R-type (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU)
                reg_write_ctrl = 1'b1;
                mem_to_reg_ctrl = 1'b0;
                case (funct3)
                    3'b000: alu_op_ctrl = (funct7 == 7'b0000000) ? 3'b000 : 3'b001; // ADD/SUB
                    3'b001: alu_op_ctrl = 3'b010; // SLL
                    3'b010: alu_op_ctrl = 3'b011; // SLT
                    3'b011: alu_op_ctrl = 3'b100; // SLTU
                    3'b100: alu_op_ctrl = 3'b101; // XOR
                    3'b101: alu_op_ctrl = (funct7 == 7'b0000000) ? 3'b110 : 3'b111; // SRL/SRA
                    3'b110: alu_op_ctrl = 3'b000; // OR (placeholder)
                    3'b111: alu_op_ctrl = 3'b000; // AND (placeholder)
                endcase
            end
            7'b0010011: begin // I-type (ADDI, SLTI, SLTUI, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
                reg_write_ctrl = 1'b1;
                mem_to_reg_ctrl = 1'b0;
                immediate_ctrl = {{20{if_id_instruction[31]}}, if_id_instruction[31:20]}; // Sign-extend
                case (funct3)
                    3'b000: alu_op_ctrl = 3'b000; // ADDI
                    3'b010: alu_op_ctrl = 3'b011; // SLTI
                    3'b011: alu_op_ctrl = 3'b100; // SLTUI
                    3'b100: alu_op_ctrl = 3'b101; // XORI
                    3'b110: alu_op_ctrl = 3'b000; // ORI (placeholder)
                    3'b111: alu_op_ctrl = 3'b000; // ANDI (placeholder)
                    3'b001: alu_op_ctrl = 3'b010; // SLLI
                    3'b101: alu_op_ctrl = (funct7 == 7'b0000000) ? 3'b110 : 3'b111; // SRLI/SRAI
                endcase
            end
            7'b0000011: begin // I-type (Load instructions: LB, LH, LW, LBU, LHU)
                mem_read_ctrl = 1'b1;
                reg_write_ctrl = 1'b1;
                mem_to_reg_ctrl = 1'b1;
                alu_op_ctrl = 3'b000; // ADD for address calculation
                immediate_ctrl = {{20{if_id_instruction[31]}}, if_id_instruction[31:20]}; // Sign-extend
            end
            7'b0100011: begin // S-type (Store instructions: SB, SH, SW)
                mem_write_ctrl = 1'b1;
                reg_write_ctrl = 1'b0;
                mem_to_reg_ctrl = 1'b0;
                alu_op_ctrl = 3'b000; // ADD for address calculation
                immediate_ctrl = {{20{if_id_instruction[31]}}, if_id_instruction[31:25], if_id_instruction[11:7]}; // Sign-extend
            end
            7'b0110111: begin // U-type (LUI)
                reg_write_ctrl = 1'b1;
                mem_to_reg_ctrl = 1'b0;
                alu_op_ctrl = 3'b000; // No ALU op, just load immediate
                immediate_ctrl = {if_id_instruction[31:12], 12'b0}; // U-type immediate
            end
            7'b0010111: begin // U-type (AUIPC)
                reg_write_ctrl = 1'b1;
                mem_to_reg_ctrl = 1'b0;
                alu_op_ctrl = 3'b000; // ADD for PC + immediate
                immediate_ctrl = {if_id_instruction[31:12], 12'b0}; // U-type immediate
            end
            7'b1101111: begin // J-type (JAL)
                reg_write_ctrl = 1'b1;
                mem_to_reg_ctrl = 1'b0;
                alu_op_ctrl = 3'b000; // ADD for PC + 4
                immediate_ctrl = 32'b0; // Simplified
            end
            7'b1100111: begin // I-type (JALR)
                reg_write_ctrl = 1'b1;
                mem_to_reg_ctrl = 1'b0;
                alu_op_ctrl = 3'b000; // ADD for PC + 4
                immediate_ctrl = {{20{if_id_instruction[31]}}, if_id_instruction[31:20]}; // Sign-extend
            end
            7'b1100011: begin // B-type (Branch instructions)
                reg_write_ctrl = 1'b0;
                mem_to_reg_ctrl = 1'b0;
                mem_read_ctrl = 1'b0;
                mem_write_ctrl = 1'b0;
                immediate_ctrl = 32'b0; // Simplified
                case (funct3)
                    3'b000: alu_op_ctrl = 3'b000; // BEQ
                    3'b001: alu_op_ctrl = 3'b000; // BNE
                endcase
            end
            default: begin
                alu_op_ctrl = 3'b000;
                mem_read_ctrl = 1'b0;
                mem_write_ctrl = 1'b0;
                mem_to_reg_ctrl = 1'b0;
                reg_write_ctrl = 1'b0;
                immediate_ctrl = 32'b0;
            end
        endcase
    end

    // ID/EX Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            id_ex_pc_plus_4 <= 32'h00000000;
            id_ex_read_data1 <= 32'h00000000;
            id_ex_read_data2 <= 32'h00000000;
            id_ex_rs1_addr <= 5'b0;
            id_ex_rs2_addr <= 5'b0;
            id_ex_rd_addr <= 5'b0;
            id_ex_immediate <= 32'h00000000;
            id_ex_alu_op <= 3'b000;
            id_ex_mem_read <= 1'b0;
            id_ex_mem_write <= 1'b0;
            id_ex_mem_to_reg <= 1'b0;
            id_ex_reg_write <= 1'b0;
        } else if (~stall) begin
            if (flush) begin
                id_ex_pc_plus_4 <= 32'h00000000;
                id_ex_read_data1 <= 32'h00000000;
                id_ex_read_data2 <= 32'h00000000;
                id_ex_rs1_addr <= 5'b0;
                id_ex_rs2_addr <= 5'b0;
                id_ex_rd_addr <= 5'b0;
                id_ex_immediate <= 32'h00000000;
                id_ex_alu_op <= 3'b000;
                id_ex_mem_read <= 1'b0;
                id_ex_mem_write <= 1'b0;
                id_ex_mem_to_reg <= 1'b0;
                id_ex_reg_write <= 1'b0;
            } else begin
                id_ex_pc_plus_4 <= if_id_pc_plus_4;
                id_ex_read_data1 <= read_data1_from_regfile;
                id_ex_read_data2 <= read_data2_from_regfile;
                id_ex_rs1_addr <= rs1;
                id_ex_rs2_addr <= rs2;
                id_ex_rd_addr <= rd;
                id_ex_immediate <= immediate_ctrl;
                id_ex_alu_op <= alu_op_ctrl;
                id_ex_mem_read <= mem_read_ctrl;
                id_ex_mem_write <= mem_write_ctrl;
                id_ex_mem_to_reg <= mem_to_reg_ctrl;
                id_ex_reg_write <= reg_write_ctrl;
            end
        end
    end

endmodule
