// pipelined_processor.v
// Top-level module for a 5-stage pipelined processor

module pipelined_processor (
    input wire clk,
    input wire reset
);

    // Wires for inter-stage communication
    // IF/ID Register
    wire [31:0] if_id_pc_plus_4;
    wire [31:0] if_id_instruction;

    // ID/EX Register
    wire [31:0] id_ex_pc_plus_4;
    wire [31:0] id_ex_read_data1;
    wire [31:0] id_ex_read_data2;
    wire [4:0]  id_ex_rs1_addr;
    wire [4:0]  id_ex_rs2_addr;
    wire [4:0]  id_ex_rd_addr;
    wire [31:0] id_ex_immediate;
    wire [2:0]  id_ex_alu_op;
    wire        id_ex_mem_read;
    wire        id_ex_mem_write;
    wire        id_ex_mem_to_reg;
    wire        id_ex_reg_write;

    // EX/MEM Register
    wire [31:0] ex_mem_pc_plus_4;
    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_write_data;
    wire [4:0]  ex_mem_rd_addr;
    wire        ex_mem_mem_read;
    wire        ex_mem_mem_write;
    wire        ex_mem_mem_to_reg;
    wire        ex_mem_reg_write;

    // MEM/WB Register
    wire [31:0] mem_wb_alu_result;
    wire [31:0] mem_wb_read_data;
    wire [4:0]  mem_wb_rd_addr;
    wire        mem_wb_mem_to_reg;
    wire        mem_wb_reg_write;

    // Hazard detection and forwarding unit signals
    wire        stall_if;
    wire        stall_id;
    wire        flush_if;
    wire        flush_id;
    wire [1:0]  forward_a;
    wire [1:0]  forward_b;

    // Instruction Fetch (IF) Stage
    if_stage if_stage_inst (
        .clk(clk),
        .reset(reset),
        .stall(stall_if),
        .flush(flush_if),
        .if_id_pc_plus_4(if_id_pc_plus_4),
        .if_id_instruction(if_id_instruction)
    );

    // Instruction Decode (ID) Stage
    id_stage id_stage_inst (
        .clk(clk),
        .reset(reset),
        .stall(stall_id),
        .flush(flush_id),
        .if_id_pc_plus_4(if_id_pc_plus_4),
        .if_id_instruction(if_id_instruction),
        .id_ex_pc_plus_4(id_ex_pc_plus_4),
        .id_ex_read_data1(id_ex_read_data1),
        .id_ex_read_data2(id_ex_read_data2),
        .id_ex_rs1_addr(id_ex_rs1_addr),
        .id_ex_rs2_addr(id_ex_rs2_addr),
        .id_ex_rd_addr(id_ex_rd_addr),
        .id_ex_immediate(id_ex_immediate),
        .id_ex_alu_op(id_ex_alu_op),
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_mem_write(id_ex_mem_write),
        .id_ex_mem_to_reg(id_ex_mem_to_reg),
        .id_ex_reg_write(id_ex_reg_write),
        .mem_wb_rd_addr(mem_wb_rd_addr),
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_read_data(mem_wb_read_data),
        .mem_wb_mem_to_reg(mem_wb_mem_to_reg),
        .mem_wb_reg_write(mem_wb_reg_write)
    );

    // Execute (EX) Stage
    ex_stage ex_stage_inst (
        .clk(clk),
        .reset(reset),
        .id_ex_pc_plus_4(id_ex_pc_plus_4),
        .id_ex_read_data1(id_ex_read_data1),
        .id_ex_read_data2(id_ex_read_data2),
        .id_ex_rs1_addr(id_ex_rs1_addr),
        .id_ex_rs2_addr(id_ex_rs2_addr),
        .id_ex_rd_addr(id_ex_rd_addr),
        .id_ex_immediate(id_ex_immediate),
        .id_ex_alu_op(id_ex_alu_op),
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_mem_write(id_ex_mem_write),
        .id_ex_mem_to_reg(id_ex_mem_to_reg),
        .id_ex_reg_write(id_ex_reg_write),
        .ex_mem_pc_plus_4(ex_mem_pc_plus_4),
        .ex_mem_alu_result(ex_mem_alu_result),
        .ex_mem_write_data(ex_mem_write_data),
        .ex_mem_rd_addr(ex_mem_rd_addr),
        .ex_mem_mem_read(ex_mem_mem_read),
        .ex_mem_mem_write(ex_mem_mem_write),
        .ex_mem_mem_to_reg(ex_mem_mem_to_reg),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_rd_addr(mem_wb_rd_addr),
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_read_data(mem_wb_read_data),
        .mem_wb_mem_to_reg(mem_wb_mem_to_reg),
        .mem_wb_reg_write(mem_wb_reg_write),
        .ex_mem_rd_addr_in(id_ex_rd_addr),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    // Memory (MEM) Stage
    mem_stage mem_stage_inst (
        .clk(clk),
        .reset(reset),
        .ex_mem_pc_plus_4(ex_mem_pc_plus_4),
        .ex_mem_alu_result(ex_mem_alu_result),
        .ex_mem_write_data(ex_mem_write_data),
        .ex_mem_rd_addr(ex_mem_rd_addr),
        .ex_mem_mem_read(ex_mem_mem_read),
        .ex_mem_mem_write(ex_mem_mem_write),
        .ex_mem_mem_to_reg(ex_mem_mem_to_reg),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_read_data(mem_wb_read_data),
        .mem_wb_rd_addr(mem_wb_rd_addr),
        .mem_wb_mem_to_reg(mem_wb_mem_to_reg),
        .mem_wb_reg_write(mem_wb_reg_write)
    );

    // Write Back (WB) Stage
    wb_stage wb_stage_inst (
        .clk(clk),
        .reset(reset),
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_read_data(mem_wb_read_data),
        .mem_wb_rd_addr(mem_wb_rd_addr),
        .mem_wb_mem_to_reg(mem_wb_mem_to_reg),
        .mem_wb_reg_write(mem_wb_reg_write)
    );

    // Hazard Detection Unit
    hazard_detection_unit hdu_inst (
        .if_id_instruction(if_id_instruction),
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_rd_addr(id_ex_rd_addr),
        .ex_mem_mem_read(ex_mem_mem_read),
        .ex_mem_rd_addr(ex_mem_rd_addr),
        .id_ex_rs1_addr(id_ex_rs1_addr),
        .id_ex_rs2_addr(id_ex_rs2_addr),
        .stall_if(stall_if),
        .stall_id(stall_id),
        .flush_if(flush_if),
        .flush_id(flush_id)
    );

    // Forwarding Unit
    forwarding_unit fu_inst (
        .id_ex_rs1_addr(id_ex_rs1_addr),
        .id_ex_rs2_addr(id_ex_rs2_addr),
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_rd_addr(ex_mem_rd_addr),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_rd_addr(mem_wb_rd_addr),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

endmodule
