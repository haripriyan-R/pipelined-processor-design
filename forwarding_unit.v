// forwarding_unit.v
// Forwarding Unit

module forwarding_unit (
    input wire [4:0]  id_ex_rs1_addr,
    input wire [4:0]  id_ex_rs2_addr,

    input wire        ex_mem_reg_write,
    input wire [4:0]  ex_mem_rd_addr,
    input wire        mem_wb_reg_write,
    input wire [4:0]  mem_wb_rd_addr,

    output reg [1:0]  forward_a, // Forwarding control for ALU input A (rs1)
    output reg [1:0]  forward_b  // Forwarding control for ALU input B (rs2)
);

    always @(*) begin
        // Default: no forwarding
        forward_a = 2'b00;
        forward_b = 2'b00;

        // Forwarding for rs1 (ALU input A)
        // EX/MEM to EX forwarding
        if (ex_mem_reg_write && (ex_mem_rd_addr != 5'b0) && (ex_mem_rd_addr == id_ex_rs1_addr)) begin
            forward_a = 2'b01; // Forward from EX/MEM (ALU result)
        end
        // MEM/WB to EX forwarding
        if (mem_wb_reg_write && (mem_wb_rd_addr != 5'b0) && (mem_wb_rd_addr == id_ex_rs1_addr)) begin
            // In a full design, we'd handle the priority if both EX/MEM and MEM/WB match
            forward_a = 2'b10; // Forward from MEM/WB (Read data or ALU result)
        end

        // Forwarding for rs2 (ALU input B)
        // EX/MEM to EX forwarding
        if (ex_mem_reg_write && (ex_mem_rd_addr != 5'b0) && (ex_mem_rd_addr == id_ex_rs2_addr)) begin
            forward_b = 2'b01; // Forward from EX/MEM (ALU result)
        end
        // MEM/WB to EX forwarding
        if (mem_wb_reg_write && (mem_wb_rd_addr != 5'b0) && (mem_wb_rd_addr == id_ex_rs2_addr)) begin
            forward_b = 2'b10; // Forward from MEM/WB (Read data or ALU result)
        end
    end

endmodule
