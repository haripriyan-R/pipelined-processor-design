// ============================================================================
// hazard_detection_unit.v
// Hazard Detection Unit
// Detects Load-Use Data Hazards
// ============================================================================

module hazard_detection_unit (

    input wire [31:0] if_id_instruction,
    input wire        id_ex_mem_read,
    input wire [4:0]  id_ex_rd_addr,

    output reg        stall_if,
    output reg        stall_id,
    output reg        flush_if,
    output reg        flush_id

);

    // ------------------------------------------------------------------------
    // Load-Use Hazard Detection
    // ------------------------------------------------------------------------
    wire load_use_hazard_rs1;
    wire load_use_hazard_rs2;

    assign load_use_hazard_rs1 =
           id_ex_mem_read &&
           (id_ex_rd_addr != 5'b00000) &&
           (id_ex_rd_addr == if_id_instruction[19:15]);

    assign load_use_hazard_rs2 =
           id_ex_mem_read &&
           (id_ex_rd_addr != 5'b00000) &&
           (id_ex_rd_addr == if_id_instruction[24:20]);

    // ------------------------------------------------------------------------
    // Hazard Detection Logic
    // ------------------------------------------------------------------------
    always @(*) begin

        // Default operation
        stall_if = 1'b0;
        stall_id = 1'b0;
        flush_if = 1'b0;
        flush_id = 1'b0;

        // Load-Use Hazard Found
        if (load_use_hazard_rs1 || load_use_hazard_rs2) begin

            stall_if = 1'b1;
            stall_id = 1'b1;

            flush_if = 1'b0;
            flush_id = 1'b0;

        end

    end

endmodule
