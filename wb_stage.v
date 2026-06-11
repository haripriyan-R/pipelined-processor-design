// wb_stage.v
// Write Back Stage

module wb_stage (
    input wire clk,
    input wire reset,

    input wire [31:0] mem_wb_alu_result,
    input wire [31:0] mem_wb_read_data,
    input wire [4:0]  mem_wb_rd_addr,
    input wire        mem_wb_mem_to_reg,
    input wire        mem_wb_reg_write
);

    // The actual write-back to the register file happens in the ID stage
    // This module primarily acts as a pipeline register for the WB stage signals
    // and can be used for debugging or further processing if needed.

endmodule
