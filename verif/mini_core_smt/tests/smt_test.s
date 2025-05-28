.section .text
.org 0x0000         # Thread 0 code
.global _start
_start:
    li x5, 10
    add x6, x5, x5
    add x7, x6, x5
    nop
    nop

.org 0x8000         # Thread 1 code
.global _start1
_start1:
    li x10, 2
    add x11, x10, x10
    add x11, x11, x10
    nop
    nop
