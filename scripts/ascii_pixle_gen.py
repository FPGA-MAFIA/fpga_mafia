import tkinter as tk

def update_output():
    binary_representation = ['0b' + ''.join(['1' if pixels[row][col].get() else '0' for col in range(8)]) for row in range(8)]
    hex_representation = [hex(int(binary, 2))[2:].upper().zfill(2) for binary in binary_representation]
    
    for i, hex_val in enumerate(hex_representation):
        labels[i].config(text=f"0x{hex_val} -> {binary_representation[i][2:]} -> " + ''.join(['X' if bit == '1' else '_' for bit in binary_representation[i][2:]]))
    
    top_hex = ''.join(reversed(hex_representation[:4]))
    bottom_hex = ''.join(reversed(hex_representation[4:]))
    output_top_var.set(f"TOP HEX: 0x{top_hex}")
    output_bottom_var.set(f"BOTTOM HEX: 0x{bottom_hex}")

def create_pixel(master, row, col):
    var = tk.BooleanVar()
    chk = tk.Checkbutton(master, var=var, command=update_output)
    chk.grid(row=row, column=col, sticky='nsew')
    return var

def init_ui(master):
    for row in range(8):
        for col in range(8):
            pixels[row][col] = create_pixel(master, row, col)
        labels.append(tk.Label(master, text="0x00 -> 00000000 -> ________"))
        labels[-1].grid(row=row, column=8, sticky='nsew', padx=5)

    output_top = tk.Entry(master, textvariable=output_top_var, state='readonly', readonlybackground='white', fg='black')
    output_bottom = tk.Entry(master, textvariable=output_bottom_var, state='readonly', readonlybackground='white', fg='black')
    output_top.grid(row=8, column=0, columnspan=9, sticky='nsew', pady=(10,0))
    output_bottom.grid(row=9, column=0, columnspan=9, sticky='nsew')

if __name__ == "__main__":
    root = tk.Tk()
    root.title("8x8 Pixel Grid to Hex Converter")

    pixels = [[None for _ in range(8)] for _ in range(8)]
    labels = []
    output_top_var = tk.StringVar(root, value="TOP HEX: 0x00000000")
    output_bottom_var = tk.StringVar(root, value="BOTTOM HEX: 0x00000000")

    init_ui(root)

    root.mainloop()
