def load_hex(path):
    with open(path) as f:
        lines = f.readlines()
    mem = {}
    addr = 0
    for line in lines:
        if line.startswith('@'):
            addr = int(line[1:], 16)
        else:
            mem[addr] = line.strip()
            addr += 1
    return mem

def write_merged(mem0, mem1, out_path):
    merged = {**mem0, **mem1}
    with open(out_path, 'w') as f:
        for addr in sorted(merged.keys()):
            f.write(f"@{addr:08X}\n{merged[addr]}\n")

if __name__ == "__main__":
    mem0 = load_hex("thread0.hex")             # Loaded at 0x0000
    mem1 = load_hex("thread1.hex")             # Loaded at 0x8000
    # Shift thread1’s addresses to 0x8000 / 4 = 0x2000
    mem1 = {addr + 0x2000: val for addr, val in mem1.items()}
    write_merged(mem0, mem1, "inst_mem.sv")
