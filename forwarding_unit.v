// ============================================================================
// forwarding_unit.v
// Data Forwarding Unit
// ============================================================================

module forwarding_unit (

    input wire [4:0] id_ex_rs1_addr,
    input wire [4:0] id_ex_rs2_addr,

    input wire       ex_mem_reg_write,
    input wire [4:0] ex_mem_rd_addr,

    input wire       mem_wb_reg_write,
    input wire [4:0] mem_wb_rd_addr,

    output reg [1:0] forward_a,
    output reg [1:0] forward_b

);

always @(*) begin

    // Default = No Forwarding
    forward_a = 2'b00;
    forward_b = 2'b00;

    // ==========================================================
    // Highest Priority : EX/MEM Stage
    // ==========================================================

    if (ex_mem_reg_write &&
        (ex_mem_rd_addr != 5'b00000) &&
        (ex_mem_rd_addr == id_ex_rs1_addr))
    begin
        forward_a = 2'b01;
    end

    else if (mem_wb_reg_write &&
             (mem_wb_rd_addr != 5'b00000) &&
             (mem_wb_rd_addr == id_ex_rs1_addr))
    begin
        forward_a = 2'b10;
    end

    // ==========================================================
    // Forwarding for RS2
    // ==========================================================

    if (ex_mem_reg_write &&
        (ex_mem_rd_addr != 5'b00000) &&
        (ex_mem_rd_addr == id_ex_rs2_addr))
    begin
        forward_b = 2'b01;
    end

    else if (mem_wb_reg_write &&
             (mem_wb_rd_addr != 5'b00000) &&
             (mem_wb_rd_addr == id_ex_rs2_addr))
    begin
        forward_b = 2'b10;
    end

end

endmodule
