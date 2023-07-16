---
marp: true
paginate: true
theme: gaia
size: 16:9
header: 'The MAFIA Project'
author: 'Amichai Ben David'
date: '2023-06-01'
---

# FPGA Multi-Agent FabrIc Architecture (MAFIA)

[![mafia_sanity](https://github.com/amichai-bd/fpga_mafia/actions/workflows/mafia_sanity.yml/badge.svg)](https://github.com/amichai-bd/fpga_mafia/actions/workflows/mafia_sanity.yml)

---

Contributors:
- Amichai Ben David
- Daniel Kaufman
- Noam Sabban
- Shmuel Sfez
- Yeonatan Perelman

---


## Current Development Status:

This project is currently a work in progress (WIP). We are in the process of enabling and integrating individual IPs.  
Our team is working diligently to deliver a fully functional fabric by August 1, 2023.

---

# Welcome to the MAFIA Project

A initiative aimed at designing a System-on-a-Chip (SoC) Tile-based mesh fabric.  
Our architecture is designed to be highly versatile, capable of incorporating a variety of functionalities.

---

# Functionality includes

- RISCV mini-cores and big-cores
- Hardware accelerators
- IO devices such as UART, keyboard, VGA, and DE10-Lite FPGA IO

---

# Project Overview

The MAFIA Project is developed by final year Electrical and Computer Engineering students at Bar-Ilan University and the Technion in Israel.

---

# Key Features

- Acceleration of distributed workloads, particularly beneficial for AI inference and learning.
- Traditional program acceleration by utilizing a pipelining approach.
- This SoC design provides a robust platform for versatile tasks, offering improved speed and efficiency

---

## Technology Stack

- The project's RTL is written in SystemVerilog.
- We utilize the GNU GCC for the RISCV software stack, which includes linker, assembly, and C source files.
- Python is employed for build scripts, post-processing, GUI, and other utilities.

---

## Main Components

Our architecture consists of the following key elements:
- A 4-way Router coupled with a local Endpoint.
- A 3-stage Mini Core that is RV32I compatible.
- A 7-stage Big Core, which is RV32IM CSR compatible and supports MMIO (VGA, UART, FPGA IO, PS2 Keyboard).
- A Memory Subsystem equipped with L1 Instruction and Data Cache, as well as a Memory Controller.

---

## Software Stack to run on SoC

Our system runs on a simple proprietary RISCV embedded OS like system and includes:
- A software library for VGA graphical capabilities.
- A software library for accessing the FPGA MMIO and special control registers.
- Software examples demonstrating the utilization of many cores for distributed calculations and parallel computation.

---

![w:650](https://user-images.githubusercontent.com/81047407/218485725-d4442e94-7129-48b9-92bb-8f2ce52a301c.png)

---

## Getting Started

For best exporence we recomended using a windows machin running vscode + gitbash.  

To see the build and run options, use the following command:
```python build.py -h ```

---

# Prerequisite

Before you start, make sure you have the following tools and software installed:
- [RISCV gcc releases](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases/) & [install](https://xpack.github.io/riscv-none-embed-gcc/install/), a Windows gcc for RISCV ISA.  
- [Intel design SW for windows](https://www.intel.com/content/www/us/en/software-kit/660907/intel-quartus-prime-lite-edition-design-software-version-20-1-1-for-windows.html) , modelsim + quartus + MAX10 (de10-lite). used to compile, simulate & load to FPGA the HW systemverilog design.

---

## Inspiration Behind the Project  

This project draws inspiration from innovative players in the field of computing.  
These include:  
- [HammerBlade Manycore:Bespoke Silicon Group](https://www.bsg.ai/) | [Watch the video on Youtube](https://www.youtube.com/watch?v=gTM7Tc5DCA8)
- [Tesla: DOJO](https://www.tesla.com/AI) | [Watch the video on Youtube](https://www.youtube.com/watch?v=DSw3IwsgNnc)  
- [Tenstorrent: Wormhole & more](https://tenstorrent.com/) | [Watch the video on Youtube](https://www.youtube.com/watch?v=32CRYenTcdw)  
- [Esperanto: ET-SoC-1](https://www.esperanto.ai/)  | [Watch the video on Youtube](https://www.youtube.com/watch?v=5foT3huJ_Gg)

---

## Troubleshooting Common Issues

'ModuleNotFoundError: No module named 'termcolor''
```markdown
pip install termcolor
```

---

## Troubleshooting Common Issues

Issue: 'riscv-none-embed-gcc.exe' is not recognized as an internal or external command

**Solution**: Add the following line to your ~/.bashrc file:  

```bash
export PATH=$PATH:/c/Users/'user_name'/AppData/Roaming/xPacks/riscv-none-embed-gcc/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin
```

Then, reload the bashrc file with this command:

```bash
source ~/.bashrc
```

---

## Quick Access Commands

For easy access, you can run the following commands in the GitBash shell for Windows:

```bash
./build.py -h  
./build.py -dut big_core -tests alive -app -hw -sim
./build.py -dut cache -tests cache_alive -hw -sim -pp
./build.py -dut sc_core -tests alive -full_run
```

---

# Stay Tuned for Updates!
Thank You for Your Interest in the MAFIA Project!

---
