
import subprocess
import os

asm_code = """.section .text
.org 0x0000
.global _start
_start:
    li x5, 10
    add x6, x5, x5
    add x7, x6, x5
    nop
    nop

.org 0x8000
.global _start1
_start1:
    li x10, 2
    add x11, x10, x10
    add x11, x11, x10
    nop
    nop
"""

with open("smt_test.S", "w") as f:
    f.write(asm_code)

# Assemble
subprocess.run(["riscv32-unknown-elf-as", "smt_test.S", "-o", "smt_test.o"], check=True)

# Convert to binary
subprocess.run(["riscv32-unknown-elf-objcopy", "-O", "binary", "smt_test.o", "smt_test.bin"], check=True)

# Merge into .mem file
with open("smt_test.bin", "rb") as f:
    bin_data = f.read()

mem = bytearray([0x00] * 65536)
for i in range(len(bin_data)):
    mem[i] = bin_data[i]

with open("program.mem", "w") as f:
    for i in range(0, len(mem), 4):
        word = mem[i:i+4]
        f.write(f"{int.from_bytes(word, 'little'):08x}\n")

print("✅ program.mem generated successfully.")
