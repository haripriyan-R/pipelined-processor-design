// mem_stage.v
// Memory Access Stage

module mem_stage (
    input wire clk,
    input wire reset,

    input wire [31:0] ex_mem_pc_plus_4,
    input wire [31:0] ex_mem_alu_result,
    input wire [31:0] ex_mem_write_data,
    input wire [4:0]  ex_mem_rd_addr,
    input wire        ex_mem_mem_read,
    input wire        ex_mem_mem_write,
    input wire        ex_mem_mem_to_reg,
    input wire        ex_mem_reg_write,

    output reg [31:0] mem_wb_alu_result,
    output reg [31:0] mem_wb_read_data,
    output reg [4:0]  mem_wb_rd_addr,
    output reg        mem_wb_mem_to_reg,
    output reg        mem_wb_reg_write
);

    // Placeholder for Data Memory
    reg [31:0] data_memory [0:1023]; // 4KB data memory
    wire [31:0] read_data_from_mem;

    initial begin
        // Initialize data memory (for simulation purposes)
        integer i;
        for (i = 0; i < 1024; i = i + 1) begin
            data_memory[i] = 32'h00000000;
        end
    end

    // Memory read operation
    assign read_data_from_mem = data_memory[ex_mem_alu_result[11:2]]; // Word-aligned access

    // Memory write operation
    always @(posedge clk) begin
        if (ex_mem_mem_write) begin
            data_memory[ex_mem_alu_result[11:2]] <= ex_mem_write_data;
        end
    end

    // MEM/WB Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_wb_alu_result <= 32'h00000000;
            mem_wb_read_data <= 32'h00000000;
            mem_wb_rd_addr <= 5'b0;
            mem_wb_mem_to_reg <= 1'b0;
            mem_wb_reg_write <= 1'b0;
        } else begin
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_read_data <= read_data_from_mem;
            mem_wb_rd_addr <= ex_mem_rd_addr;
            mem_wb_mem_to_reg <= ex_mem_mem_to_reg;
            mem_wb_reg_write <= ex_mem_reg_write;
        end
    end

endmodule
