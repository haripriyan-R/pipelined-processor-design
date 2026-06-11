// tb_pipelined_processor.v
// Testbench for the Pipelined Processor

`timescale 1ns / 1ps

module tb_pipelined_processor;

    // Parameters
    parameter CLK_PERIOD = 10;

    // Signals
    reg clk;
    reg reset;

    // Instantiate the Device Under Test (DUT)
    pipelined_processor dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always begin
        clk = 1'b0;
        #(CLK_PERIOD / 2) clk = 1'b1;
        #(CLK_PERIOD / 2);
    end

    // Test sequence
    initial begin
        // Initialize signals
        reset = 1'b1;
        #(CLK_PERIOD * 2) reset = 1'b0; // De-assert reset after a few clock cycles

        // Add your test instructions here
        // For example, you can modify the instruction memory in if_stage.v
        // or provide a mechanism to load instructions into it.

        // Example: Run for a certain number of clock cycles
        #(CLK_PERIOD * 100);

        $finish; // End simulation
    end

    // Optional: Display messages or monitor signals
    initial begin
        $display("Starting simulation...");
        $monitor("Time=%0t, PC=%h, Instruction=%h", $time, dut.if_stage_inst.pc, dut.if_id_instruction);
    end

endmodule
