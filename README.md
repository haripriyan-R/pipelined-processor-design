# Pipelined Processor Design: Enhancing Performance through Concurrent Execution

## Overview
A high-performance 5-stage Pipelined Processor implemented using Verilog HDL, designed to maximize throughput and hardware efficiency.

## Operations Supported
- **R-Type:** ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
- **I-Type:** ADDI, SLTI, XORI, ORI, ANDI, LW, JALR
- **S-Type:** SW
- **B-Type:** BEQ, BNE
- **U-Type:** LUI, AUIPC
- **J-Type:** JAL

## Files
- `pipelined_processor.v` : Top-level Design
- `if_stage.v` : Instruction Fetch Stage
- `id_stage.v` : Instruction Decode Stage
- `ex_stage.v` : Execute Stage (ALU)
- `mem_stage.v` : Memory Access Stage
- `wb_stage.v` : Write-Back Stage
- `hazard_detection_unit.v` : Hazard Management
- `forwarding_unit.v` : Data Forwarding Logic
- `tb_pipelined_processor.v` : Testbench

## Key Features
- **5-Stage Pipeline:** IF, ID, EX, MEM, WB for concurrent execution.
- **Hazard Mitigation:** Advanced logic to detect and resolve structural, data, and control hazards.
- **Data Forwarding:** Implements bypassing to minimize pipeline stalls.

## Tools Used
- Verilog HDL
- EDA Playground
- Vivado
- ModelSim
- Quartus Prime

## Author
Haripriyan
