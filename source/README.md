# RTL Source Files

This directory contains the RTL (Register Transfer Level) source files for the FPGA-MAFIA project. The directory is organized into several subdirectories, each containing specific components of the project.

## Directory Structure

- `big_core`: Contains the RTL files for the big core, which is a 7-stage RV32IM CSR compatible core with support for MMIO (VGA, UART, FPGA IO, PS2 Keyboard).
- `big_core_cachel1`: Contains the RTL files for the big core with L1 instruction and data cache.
- `common`: Contains common RTL files and packages used across different components of the project.
- `fabric`: Contains the RTL files for the fabric architecture, which includes the router and the tiles.
  - `router`: Contains the RTL files for the router, which is responsible for routing data between different tiles in the fabric.
- `lotr`: Contains the RTL files for the LOTR (Lord of the Rings) project, which is a part of the FPGA-MAFIA project.
- `mem_ss`: Contains the RTL files for the memory subsystem, which includes the L1 instruction and data cache, memory controller, and SDRAM controller.
- `mini_core`: Contains the RTL files for the mini core, which is a 3-stage RV32I compatible core.
- `mini_core_accel`: Contains the RTL files for the mini core with hardware accelerators.
- `mini_core_rrv`: Contains the RTL files for the mini core with RRV (Reduced Register Version) support.
- `sc_core`: Contains the RTL files for the single cycle core.
- `uart`: Contains the RTL files for the UART (Universal Asynchronous Receiver-Transmitter) module.

## Main Components

### Big Core
The big core is a 7-stage RV32IM CSR compatible core with support for MMIO (VGA, UART, FPGA IO, PS2 Keyboard). It is designed to handle complex computations and provide high performance.

### Mini Core
The mini core is a 3-stage RV32I compatible core. It is designed to be lightweight and efficient, making it suitable for simple computations and low-power applications.

### Fabric Architecture
The fabric architecture consists of a network of tiles connected by routers. Each tile can contain a core, memory, or other components. The router is responsible for routing data between different tiles in the fabric.

### Memory Subsystem
The memory subsystem includes the L1 instruction and data cache, memory controller, and SDRAM controller. It is designed to provide fast and efficient memory access for the cores.

### Hardware Accelerators
The mini core with hardware accelerators includes specialized hardware units for accelerating specific computations, such as matrix multiplication and neural network operations.

## Links to Subdirectories

- [Big Core](big_core)
- [Big Core with L1 Cache](big_core_cachel1)
- [Common RTL Files](common)
- [Fabric Architecture](fabric)
  - [Router](fabric/router)
- [LOTR Project](lotr)
- [Memory Subsystem](mem_ss)
- [Mini Core](mini_core)
- [Mini Core with Hardware Accelerators](mini_core_accel)
- [Mini Core with RRV Support](mini_core_rrv)
- [Single Cycle Core](sc_core)
- [UART Module](uart)
