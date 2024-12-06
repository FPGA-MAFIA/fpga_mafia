# Mini Core

The mini core is a 3-stage RV32I compatible core designed to be lightweight and efficient. It is suitable for simple computations and low-power applications.

## Components

### Instruction Fetch (IF)
The Instruction Fetch stage is responsible for fetching instructions from the instruction memory. It calculates the next program counter (PC) value and fetches the instruction at that address.

### Instruction Decode (ID)
The Instruction Decode stage decodes the fetched instruction and generates control signals for the subsequent stages. It also reads the source registers from the register file and generates the immediate value if required.

### Execute (EX)
The Execute stage performs the actual computation specified by the instruction. It includes the ALU (Arithmetic Logic Unit) for arithmetic and logical operations, as well as the branch unit for branch instructions.

### Memory Access (MEM)
The Memory Access stage is responsible for accessing the data memory. It performs load and store operations based on the control signals generated in the ID stage.

### Write Back (WB)
The Write Back stage writes the result of the computation back to the destination register in the register file.

## Functionalities

### RV32I Compatibility
The mini core is fully compatible with the RV32I instruction set architecture (ISA). It supports all the instructions defined in the RV32I ISA, including arithmetic, logical, load/store, and control transfer instructions.

### Pipelining
The mini core uses a 3-stage pipeline to improve performance. The pipeline stages are IF, ID, and EX. The MEM and WB stages are combined with the EX stage to reduce the pipeline depth and minimize the control complexity.

### Hazard Detection and Forwarding
The mini core includes hazard detection and forwarding mechanisms to handle data hazards and control hazards. It detects hazards and stalls the pipeline or forwards the required data to resolve the hazards.

### Low Power Consumption
The mini core is designed to be power-efficient, making it suitable for low-power applications. It uses clock gating and other power-saving techniques to minimize power consumption.

## Conclusion
The mini core is a lightweight and efficient 3-stage RV32I compatible core. It is suitable for simple computations and low-power applications. It includes various components and functionalities to ensure efficient execution of instructions and low power consumption.
