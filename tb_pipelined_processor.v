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
// tb_pipelined_processor.v
`timescale 1ns / 1ps

module tb_pipelined_processor;
    reg clk, reset;
    pipelined_processor dut (.clk(clk), .reset(reset));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_pipelined_processor);
        clk = 0; reset = 1;
        #20 reset = 0;
        #200;
        $display("Simulation Finished.");
        $finish;
    end

    initial begin
        $display("Time\t PC\t Instr\t\t X2\t X3\t X4\t X5");
        forever begin
            @(posedge clk);
            #1;
            $display("%0t\t %h\t %h\t %d\t %d\t %d\t %d", 
                     $time, dut.if_stage_inst.pc, dut.if_id_instruction,
                     dut.id_stage_inst.reg_file[2], dut.id_stage_inst.reg_file[3],
                     dut.id_stage_inst.reg_file[4], dut.id_stage_inst.reg_file[5]);
        end
    end
endmodule
endmodule
