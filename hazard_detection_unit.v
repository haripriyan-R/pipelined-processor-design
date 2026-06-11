// hazard_detection_unit.v
// Hazard Detection Unit

module hazard_detection_unit (
    input wire [31:0] if_id_instruction,
    input wire        id_ex_mem_read,
    input wire [4:0]  id_ex_rd_addr,
    input wire        ex_mem_mem_read,
    input wire [4:0]  ex_mem_rd_addr,
    input wire [4:0]  id_ex_rs1_addr,
    input wire [4:0]  id_ex_rs2_addr,

    output reg        stall_if,
    output reg        stall_id,
    output reg        flush_if,
    output reg        flush_id
);

    // Data Hazard Detection (Load-Use Hazard)
    // If the instruction in EX stage is a load and its destination register
    // is used by the instruction in ID stage as a source register (rs1 or rs2),
    // then stall the pipeline.
    wire load_use_hazard_rs1 = id_ex_mem_read && (id_ex_rd_addr != 5'b0) && (id_ex_rd_addr == if_id_instruction[19:15]);
    wire load_use_hazard_rs2 = id_ex_mem_read && (id_ex_rd_addr != 5'b0) && (id_ex_rd_addr == if_id_instruction[24:20]);

    always @(*) begin
        // Default to no stall/flush
        stall_if = 1'b0;
        stall_id = 1'b0;
        flush_if = 1'b0;
        flush_id = 1'b0;

        if (load_use_hazard_rs1 || load_use_hazard_rs2) begin
            stall_if = 1'b1; // Stall IF stage
            stall_id = 1'b1; // Stall ID stage
        end

        // Control Hazard Detection (simplified for branches/jumps)
        // If the instruction in ID stage is a branch or jump, flush IF and ID stages
        // This is a very basic approach and would need more sophisticated branch prediction
        // and target address calculation in a real processor.
        // Assuming opcode for branch is 7'b1100011 and for JAL is 7'b1101111
        // and for JALR is 7'b1100111
        if (if_id_instruction[6:0] == 7'b1100011 || // Branch
            if_id_instruction[6:0] == 7'b1101111 || // JAL
            if_id_instruction[6:0] == 7'b1100111) begin // JALR
            flush_if = 1'b1;
            flush_id = 1'b1;
        end
    end

endmodule
