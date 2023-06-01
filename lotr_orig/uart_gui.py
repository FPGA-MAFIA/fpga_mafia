import tkinter as tk
import subprocess

def run_script(tile, script):
    script_name = f"tile{tile}_script{script}.py"
    subprocess.run(["python", script_name])

def update_positions(event):
    canvas_width = event.width
    canvas_height = event.height
    tile_positions = [
        ((canvas_width // 2) - (tile_size * 1.5), (canvas_height // 2) - (tile_size * 1.5)),
        ((canvas_width // 2) + (tile_size * 0.5), (canvas_height // 2) - (tile_size * 1.5)),
        ((canvas_width // 2) + (tile_size * 0.5), (canvas_height // 2) + (tile_size * 0.5)),
        ((canvas_width // 2) - (tile_size * 1.5), (canvas_height // 2) + (tile_size * 0.5)),
    ]

    for i, pos in enumerate(tile_positions):
        tiles[i].place(x=pos[0], y=pos[1])

    # Draw a new block next to the fpga_io tile
    fpga_io_block_pos = tile_positions[2][0] + tile_size*1.5, tile_positions[2][1]
    fpga_io_block = canvas.create_rectangle(fpga_io_block_pos[0], fpga_io_block_pos[1], fpga_io_block_pos[0] + tile_size, fpga_io_block_pos[1] + tile_size, fill="green")

    for arrow in arrow_objects:
        canvas.delete(arrow)

    arrow_objects.clear()
    arrow_coords = [
        (tile_positions[0][0] + tile_size, tile_positions[0][1] + tile_size // 2, tile_positions[1][0], tile_positions[1][1] + tile_size // 2),
        (tile_positions[1][0] + tile_size // 2, tile_positions[1][1] + tile_size, tile_positions[2][0] + tile_size // 2, tile_positions[2][1]),
        (tile_positions[2][0], tile_positions[2][1] + tile_size // 2, tile_positions[3][0] + tile_size, tile_positions[3][1] + tile_size // 2),
        (tile_positions[3][0] + tile_size // 2, tile_positions[3][1], tile_positions[0][0] + tile_size // 2, tile_positions[0][1] + tile_size),
    ]

    for coords in arrow_coords:
        arrow = canvas.create_line(*coords, arrow=tk.LAST, width=2)
        arrow_objects.append(arrow)

    global host_arrow
    canvas.delete(host_arrow)
    host_pos = (host_pos_x, host_pos_y)
    uart_io_pos = (tile_positions[3][0], tile_positions[3][1] + tile_size // 2)
    host_arrow = canvas.create_line(host_pos[0] + 10, host_pos[1] + tile_size // 2, uart_io_pos[0], uart_io_pos[1], arrow=tk.BOTH, width=2)

app = tk.Tk()
app.title("FPGA Tiles Control")

canvas = tk.Canvas(app, width=800, height=800)
canvas.pack(fill=tk.BOTH, expand=True)
canvas.bind('<Configure>', update_positions)

tile_size = 200

tile_names = [
    "GPC_4T Tile 1",
    "GPC_4T Tile 2",
    "FPGA MMIO Tile 3",
    "UART_IO Tile 4",
]

tiles = []
for i in range(4):
    tile = tk.Canvas(app, width=tile_size, height=tile_size, bg="blue")
    tile.create_text(tile_size // 2, tile_size // 2 - 40, text=tile_names[i], fill="white", font=('Arial', 14, 'bold'))

    button1 = tk.Button(tile, text="Script 1", command=lambda i=i: run_script(i + 1, 1), width=10, height=2)
    button1.place(x=tile_size // 4, y=tile_size // 2)

    button2 = tk.Button(tile, text="Script 2", command=lambda i=i: run_script(i + 1, 2), width=10, height=2)
    button2.place(x=tile_size // 4, y=tile_size // 2 + 60)

    tiles.append(tile)


host_pos_x = 20
host_pos_y = 500

arrow_objects = []
host_arrow = None

host = tk.Canvas(app, width=tile_size, height=tile_size, bg="red")
host.create_text(tile_size // 2, tile_size // 2, text="Host", fill="white", font=('Arial', 14, 'bold'))
host.place(x=host_pos_x, y=host_pos_y)

# General Command Buttons
gc_y_offset = 50
general_command_title = tk.Label(app, text="General Command", font=('Arial', 14, 'bold'))
general_command_title.place(x=40, y=gc_y_offset+50)

general_buttons = []
for i in range(5):
    general_button = tk.Button(app, text=f"Button {i+1}", width=15, height=2)
    general_button.place(x=40, y=gc_y_offset+100 + (i * 40))
    general_buttons.append(general_button)



# Proprietary Host to UART Write Command
x_offset_proprietary = 20
write_label = tk.Label(app, text="Write", font=('Arial', 14, 'bold'))
write_label.place(x=x_offset_proprietary+20, y=20)

target_label = tk.Label(app, text="Target", font=('Arial', 14, 'bold'))
target_label.place(x=x_offset_proprietary+110, y=20)

data_hex_label = tk.Label(app, text="Data Hex", font=('Arial', 14, 'bold'))
data_hex_label.place(x=x_offset_proprietary+210, y=20)

target_var = tk.StringVar(app)
target_var.set("LED")
target_dropdown = tk.OptionMenu(app, target_var, "LED", "7SEG")
target_dropdown.place(x=x_offset_proprietary+110, y=40)

data_hex_entry = tk.Entry(app)
data_hex_entry.place(x=x_offset_proprietary+210, y=40)

def write_data():
    # TODO: Add code to write data to the UART
    pass

write_button = tk.Button(app, text="Write", command=write_data, width=10, height=2)
write_button.place(x=x_offset_proprietary+20, y=40)

app.mainloop()
