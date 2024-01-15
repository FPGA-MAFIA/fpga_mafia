#! /usr/bin/env python
import os
import tkinter as tk
from tkinter import ttk
from tkinter import messagebox
import subprocess
import threading
import queue
import csv


MODEL_ROOT = subprocess.check_output('git rev-parse --show-toplevel', shell=True).decode().split('\n')[0]
os.chdir(MODEL_ROOT)
class CommandLineBuilder(tk.Tk):

    def __init__(self):
        super().__init__()
        self.protocol("WM_DELETE_WINDOW", self.close_app)

        self.title("Command Line Builder")

        # Variables for options
        self.dut_var = tk.StringVar(self)
        self.regress_var = tk.StringVar(self)
        self.regress_enabled_var = tk.BooleanVar(self)
        self.cfg_var = tk.StringVar(self)
        self.cfg_enabled_var = tk.BooleanVar(self)
        self.top_var = tk.StringVar(self)
        self.top_enabled_var = tk.BooleanVar(self)
        self.tests_vars = {}  # Dictionary to store each test variable
        self.tests_enabled_var = tk.BooleanVar(self)
        self.params_vars = {}  # Dictionary to store each test variable
        self.params_enabled_var = tk.BooleanVar(self)
        self.app_var = tk.BooleanVar(self)
        self.hw_var = tk.BooleanVar(self)
        self.sim_var = tk.BooleanVar(self)
        self.gui_var = tk.BooleanVar(self)
        self.full_run_var = tk.BooleanVar(self)
        self.pp_var = tk.BooleanVar(self)
        self.mif_var = tk.BooleanVar(self)
        self.fpga_var = tk.BooleanVar(self)
        self.keep_going_var = tk.BooleanVar(self)
        self.clean_var = tk.BooleanVar(self)
        self.cmd_var = tk.BooleanVar(self)

        # Descriptions
        self.desc = {
            "-dut"      : "Specify the Device Under Test.",
            "-cfg"      : "Choose which configuration you'd like to run.",
            "-tests"    : "Choose which tests you'd like to run.",
            "-regress"  : "Specify the regression that has pre-determine test lists to run.",
            "-top"      : "Specify the top module to elaboration & simulate the tb of the DUT.",
            "-app"      : "For CPU tests that needs to compile a C or Assembly code to create the elf to load to DUT memory.",
            "-hw"       : "HW Compile the DUT system verilog using vlog.exe - according to the .f file list.",
            "-sim"      : "HW Elaborate the Compiled model + start running the TB (test-bench).",
            "-gui"      :"Execute this option with the '-sim' flag to open the ModelSim GUI.",
            "-full_run" : "SW & HW compile + simulation (-app -hw -sim)",
            "-params"   : "Specify the parameters for the DUT  Example: -gV_TIMEOUT=1000 -gV_NUM_REQ=20.",
            "-pp"       : "HW Post Processing - after simulation is done, run the post processing script ./verif/<dut>/<dut>_pp.py.",
            "-mif"      : "create the mif memory files for the FPGA load",
            "-keep_going": "Keep going even if there are errors in one of the tests",
            "-fpga"     : "Run Compile & Synthesis for FPGA",
            "-clean"    : "Clean the build directory before building.",
            "-cmd"      : "Without executing, display the commands that will be executed.",
        }

        # -dut drop-down
        self.create_combobox_option("DUT", "-dut", self.get_dut_options)

        # -cfg checkbox and dropdown
        self.create_combobox_option_with_checkbox("Cfg", "-cfg", self.get_cfg_options)

        # -tests checkbox options
        self.tests_frame = ttk.LabelFrame(self, text="-tests Options")
        self.tests_frame.pack(anchor="w", padx=10, pady=5, fill="x")

        tests_check_frame = ttk.Frame(self)  # New frame to encapsulate both the checkbox and its description
        tests_check_frame.pack(anchor="w", padx=10, pady=5, fill="x")

        self.tests_check = ttk.Checkbutton(tests_check_frame, text="-tests", variable=self.tests_enabled_var, command=self.toggle_tests_visibility)
        self.tests_check.pack(side="left", anchor="w")  # Removed the padx from here

        ttk.Label(tests_check_frame, text=self.desc["-tests"], foreground="gray").pack(side="left", anchor="w", padx=10)

        self.update_tests_checkboxes()

        # -params checkbox options
        self.params_frame = ttk.LabelFrame(self, text="-params Options")
        self.params_frame.pack(anchor="w", padx=10, pady=5, fill="x")

        params_check_frame = ttk.Frame(self)  # New frame to encapsulate both the checkbox and its description
        params_check_frame.pack(anchor="w", padx=10, pady=5, fill="x")

        self.params_check = ttk.Checkbutton(params_check_frame, text="-params", variable=self.params_enabled_var, command=self.toggle_params_visibility)
        self.params_check.pack(side="left", anchor="w")  # Removed the padx from here

        ttk.Label(params_check_frame, text=self.desc["-params"], foreground="gray").pack(side="left", anchor="w", padx=10)

        self.update_params_checkboxes()


        # -regress checkbox and dropdown
        self.create_combobox_option_with_checkbox("Regression", "-regress", self.get_regress_options)

        # -top checkbox and dropdown
        self.create_combobox_option_with_checkbox("Top", "-top", self.get_top_options)


        # simple checkboxes
        self.add_checkbox_option("-app", self.app_var)
        self.add_checkbox_option("-hw", self.hw_var)
        self.add_checkbox_option("-sim", self.sim_var)
        self.add_checkbox_option("-gui", self.gui_var) 
        self.add_checkbox_option("-full_run", self.full_run_var)
        self.add_checkbox_option("-pp", self.pp_var)
        self.add_checkbox_option("-clean", self.clean_var)
        self.add_checkbox_option("-mif", self.mif_var)
        self.add_checkbox_option("-fpga", self.fpga_var)
        self.add_checkbox_option("-keep_going", self.keep_going_var)
        self.add_checkbox_option("-cmd", self.cmd_var)
        

        # Command display
        self.cmd_display = tk.Text(self, height=2, width=150)
        self.cmd_display.pack(padx=10, pady=10)

        # Frame for buttons
        button_frame = ttk.Frame(self)
        button_frame.pack(pady=10)

        # Create the Execute button inside the button frame
        self.execute_btn = ttk.Button(button_frame, text="Run Command", command=self.execute_command)
        self.execute_btn.pack(side="left", padx=5)

        # Create the Print button inside the button frame
        self.print_btn = ttk.Button(button_frame, text="Print Command", command=self.print_command)
        self.print_btn.pack(side="left", padx=5)
        
        # Initial setup
        self.toggle_tests_visibility()  # Hide test options by default
        self.toggle_params_visibility()  # Hide test options by default
        self.update_command_display()
        # Parameter generation
        self.run_parameter_generation()

    
    def run_parameter_generation(self):
        script_path = os.path.join("./scripts", "gen_parameter_list.py")
        dut_list = self.get_dut_options()  # Assuming this method returns a list of DUT names

        for dut in dut_list:
            try:
                #print(f"Running parameter generation for {dut}...")
                subprocess.run(["python", script_path, dut], check=True)
            except subprocess.CalledProcessError as e:
                print(f"Error running parameter generation for {dut}: {e}")


    def create_combobox_option(self, label_text, flag, fetch_option):
        frame = ttk.Frame(self)
        frame.pack(anchor="w", padx=10, pady=5)

        label = ttk.Label(frame, text=label_text)
        label.pack(side="left")

        dropdown_var = getattr(self, f"{flag[1:]}_var")
        dropdown = ttk.Combobox(frame, textvariable=dropdown_var, postcommand=lambda: self.update_dropdown_options(dropdown, fetch_option))
        dropdown.bind("<<ComboboxSelected>>", self.on_combobox_select)
        dropdown.pack(side="left", padx=10)

        # Add description
        ttk.Label(frame, text=self.desc[flag], foreground="gray").pack(side="left", padx=10)

    def create_textbox_option_with_checkbox(self, label_text, flag, fetch_option):
        frame = ttk.Frame(self)
        frame.pack(anchor="w", padx=10, pady=5)

        check_var = getattr(self, f"{flag[1:]}_enabled_var")
        check = ttk.Checkbutton(frame, text=flag, variable=check_var, command=self.update_command_display)
        check.pack(side="left", anchor="w")
        
        textbox_var = getattr(self, f"{flag[1:]}_var")
        textbox = ttk.Entry(frame, textvariable=textbox_var, state=tk.DISABLED)
        textbox.pack(side="left", padx=10)
        
        check_var.trace_add('write', lambda *args: textbox.configure(state=tk.NORMAL if check_var.get() else tk.DISABLED))

        # Add description
        ttk.Label(frame, text=self.desc[flag], foreground="gray").pack(side="left", padx=10)

    def create_combobox_option_with_checkbox(self, label_text, flag, fetch_option):
        frame = ttk.Frame(self)
        frame.pack(anchor="w", padx=10, pady=5)

        check_var = getattr(self, f"{flag[1:]}_enabled_var")
        check = ttk.Checkbutton(frame, text=flag, variable=check_var, command=self.update_command_display)
        check.pack(side="left", anchor="w")
        
        dropdown_var = getattr(self, f"{flag[1:]}_var")
        dropdown = ttk.Combobox(frame, textvariable=dropdown_var, postcommand=lambda: self.update_dropdown_options(dropdown, fetch_option), state=tk.DISABLED)
        dropdown.bind("<<ComboboxSelected>>", self.on_combobox_select)
        dropdown.pack(side="left", padx=10)
        
        check_var.trace_add('write', lambda *args: dropdown.configure(state=tk.NORMAL if check_var.get() else tk.DISABLED))

        # Add description
        ttk.Label(frame, text=self.desc[flag], foreground="gray").pack(side="left", padx=10)

    def add_checkbox_option(self, flag, var):
        frame = ttk.Frame(self)
        frame.pack(anchor="w", padx=10, pady=5)
        cb = ttk.Checkbutton(frame, text=flag, variable=var, command=self.update_command_display)
        cb.pack(side="left")

        # Add description
        ttk.Label(frame, text=self.desc[flag], foreground="gray").pack(side="left", padx=10)


    def update_tests_checkboxes(self):
        # Clear existing widgets in the frame
        for widget in self.tests_frame.winfo_children():
            widget.destroy()

        # Get the tests and arrange them in a grid
        tests = self.get_test_options()
        row = 0
        col = 0
        for test in tests:
            var = self.tests_vars.get(test) or tk.BooleanVar(self)
            self.tests_vars[test] = var
            cb = ttk.Checkbutton(self.tests_frame, text=test, variable=var, command=self.update_command_display)
            cb.grid(row=row, column=col, sticky="w", padx=5, pady=2)
            col += 1
            if col == 7:  # Move to next row after every 3 checkboxes
                row += 1
                col = 0

    
    def update_params_checkboxes(self):
        # Clear existing widgets in the frame
        for widget in self.params_frame.winfo_children():
            widget.destroy()
    
        params = self.get_params_options()
        # print(f"Number of parameters: {len(params)}")  # Debug print
        row = 0
        col = 0
        for param_value_pair in params:
            # print(f"Adding checkbox for: {param_value_pair[0]}")
            param, value = param_value_pair  # Extract parameter name and value
            var = self.params_vars.get(param) or tk.BooleanVar(self)
            self.params_vars[param] = var

            # Create the Checkbutton with a text
            cb = ttk.Checkbutton(self.params_frame, text=param, variable=var)
            cb.grid(row=row, column=col*2, sticky="w", padx=5, pady=2)

            # Create the Entry next to the Checkbutton and insert the default value
            entry = ttk.Entry(self.params_frame)
            entry.grid(row=row, column=col*2+1, sticky="w", padx=5, pady=2)
            entry.insert(0, value)
            # Bind the text modification event to update the command display
            entry.bind("<KeyRelease>", self.on_entry_change)

            # Enable or disable the Entry based on the Checkbutton
            def toggle_entry_state(var=var, entry=entry):
                state = 'normal' if var.get() else 'disabled'
                entry.configure(state=state)
                self.update_command_display()
    
            # Bind the command to the Checkbutton
            cb.config(command=toggle_entry_state)

            # Initialize the Entry state based on the Checkbutton
            toggle_entry_state()
    
            col += 1
            if col == 4:  # Adjust the column count as needed
                row += 1
                col = 0


    def on_entry_change(self, event):
        # Call the update command display function
        self.update_command_display()

    def update_dropdown_options(self, dropdown, fetch_option):
        dropdown["values"] = fetch_option()

    def get_dut_options(self):
        return os.listdir("./verif")

    def get_cfg_options(self):
        cfg_path = f"./app/cfg"
        if os.path.exists(cfg_path):
            return os.listdir(cfg_path)
        else:
            return []
        
    def get_test_options(self):
        test_path = f"./verif/{self.dut_var.get()}/tests"
        if os.path.exists(test_path):
            return os.listdir(test_path)
        else:
            return []


    def get_params_options(self):
        param_path = f"./target/dut_parameters/{self.dut_var.get()}_parameter_list.csv"
        # print(f"Parameter path: {param_path}")  # Debug: Print the file path
        params_options = []
    
        if os.path.exists(param_path):
            with open(param_path, mode='r') as file:
                reader = csv.reader(file)
                for row in reader:
                    if row and len(row) >= 2:
                        # Assuming the CSV reader correctly parses the CSV file,
                        # row should already be a list with two elements.
                        param, value = row[0].strip(), row[1].strip()
                        params_options.append([param, value])
    
        # print(f"Number of parameters: {len(params_options)}")  # Debug: Print the number of parameters found
        return params_options

    def get_regress_options(self):
        regress_path = f"./verif/{self.dut_var.get()}/regress"
        if os.path.exists(regress_path):
            return os.listdir(regress_path)
        else:
            return []

    def get_top_options(self):
        top_path = f"./verif/{self.dut_var.get()}/tb/"
        if os.path.exists(top_path):
            # return only the files that end with _tb.sv
            return [f for f in os.listdir(top_path) if f.endswith("_tb.sv")]
        else:
            return []

    def on_combobox_select(self, event):
        if event.widget.cget("textvariable") == str(self.dut_var):
            self.update_tests_checkboxes()
            self.update_params_checkboxes()
        self.update_command_display()


    def update_command_display_on_trace(self, *args):
        self.update_command_display()

    def update_command_display(self):
        cmd = "python build.py"
        
        cmd += f" -dut {self.dut_var.get()}"
        
        # Collect checked tests
        # Can't select regression & tests
        #selected_tests = [test for test, var in self.tests_vars.items() if var.get()]
        selected_tests = [test.rsplit('.', 1)[0] for test, var in self.tests_vars.items() if var.get()]
        if selected_tests and self.regress_enabled_var.get():
            messagebox.showerror("[Error]", "Can't run regression & tests - choose one or the other")
            # uncheck the regression checkbox
            self.regress_enabled_var.set(False)
            return
        
        # Collect selected parameters and their values
        selected_params = []
        for param, var in self.params_vars.items():
            if var.get():  # If the parameter is selected
                entry_widget = self.find_param_entry_widget(param)
                if entry_widget:
                    value = entry_widget.get()
                    selected_params.append(f" -g{param}={value}")

        # Can't select full_run & (app or hw or sim)
        if self.full_run_var.get() and (self.app_var.get() or self.hw_var.get() or self.sim_var.get()):
            messagebox.showerror("[Error]", "Can't run full_run & (app or hw or sim) - choose one or the other")
            # uncheck the full_run checkbox
            self.full_run_var.set(False)
            return
        # make sure that the file "./verif/<dut>/<dut>_pp.py." exists
        if self.pp_var.get():
            pp_path = f"./verif/{self.dut_var.get()}/{self.dut_var.get()}_pp.py"
            if not os.path.exists(pp_path):
                messagebox.showerror("[Error]", f"Can't run pp - {pp_path} doesn't exist")
                # uncheck the pp checkbox
                self.pp_var.set(False)
                return
        
        # Can't run FPGA & regression - FPGA can only be run with 1 test
        if self.fpga_var.get() and self.regress_enabled_var.get():
            messagebox.showerror("[Error]", "Can't run FPGA & regression - FPGA can only be run with 1 test")
            # uncheck the fpga checkbox
            self.fpga_var.set(False)
            return

        if self.cfg_enabled_var.get():
            cmd += f" -cfg {self.cfg_var.get().rsplit('.', 1)[0]}"
        if self.top_enabled_var.get():
            # and the top file without the .sv
            cmd += f" -top {self.top_var.get().rsplit('.', 1)[0]}"
        if selected_tests:
            cmd += " -tests " + "\"" + " ".join(selected_tests) + "\""
        if selected_params:
            cmd += " -params " + "\"" + " ".join(selected_params) + "\""
        if self.regress_enabled_var.get():
            cmd += f" -regress {self.regress_var.get()}"
        if self.app_var.get():
            cmd += " -app"
        if self.hw_var.get():
            cmd += " -hw"
        if self.sim_var.get():
            cmd += " -sim"
        if self.gui_var.get():
            cmd += " -gui"    
        if self.pp_var.get():
            cmd += " -pp"
        if self.full_run_var.get():
            cmd += " -full_run"
        if self.clean_var.get():
            cmd += " -clean"
        if self.mif_var.get():
            cmd += " -mif"
        if self.fpga_var.get():
            cmd += " -fpga"
        if self.keep_going_var.get():
            cmd += " -keep_going"
        if self.cmd_var.get():
            cmd += " -cmd"

        self.cmd_display.delete(1.0, tk.END)
        self.cmd_display.insert(tk.END, cmd)
    
    def find_param_entry_widget(self, param):
        # Find the entry widget corresponding to a parameter
        for widget in self.params_frame.winfo_children():
            if isinstance(widget, ttk.Checkbutton) and widget.cget("text") == param:
                # Assuming the Entry is always after the Checkbutton
                entry_index = self.params_frame.winfo_children().index(widget) + 1
                if entry_index < len(self.params_frame.winfo_children()):
                    entry_widget = self.params_frame.winfo_children()[entry_index]
                    if isinstance(entry_widget, ttk.Entry):
                        return entry_widget
        return None
    def toggle_tests_visibility(self):
        if self.tests_enabled_var.get():
            self.tests_frame.pack(anchor="w", padx=10, pady=5, fill="x")
        else:
            self.tests_frame.pack_forget()
            # Add the following lines to unset all test variables:
            for test_var in self.tests_vars.values():
                test_var.set(False)
        self.update_command_display()

    def toggle_params_visibility(self):
        if self.params_enabled_var.get():
            self.params_frame.pack(anchor="w", padx=10, pady=5, fill="x")
        else:
            self.params_frame.pack_forget()
            # Add the following lines to unset all test variables:
            for test_var in self.params_vars.values():
                test_var.set(False)
        self.update_command_display()
#============================================================
# Running the command from the GUI on a separate thread, 
# and displaying the output in a separate window
#============================================================

    def run_command_in_thread(self, cmd):
        try:
            proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            while True:
                line = proc.stdout.readline()  # Read a line from the output
                if line:
                    self.output_queue.put(line)  # Put the line in the queue for the main thread to process
                if proc.poll() is not None:  # Check if the process has terminated
                    break
        except Exception as e:
            self.output_queue.put(f"[ERROR] : Command failed with error:\n{str(e)}")
        finally:
            self.output_queue.put(None)  # Sentinel value to indicate the command has finished executing

    def check_for_output(self):
        try:
            while True:  # Keep checking for all lines currently in the queue
                line = self.output_queue.get_nowait()  # Non-blocking get from the queue
                if line is None:  # Sentinel value indicating command finished
                    break  # Exit the loop
                else:
                    self.show_output(line)  # Update the display with the new line
        except queue.Empty:  # Raised when the queue is empty
            pass
        self.after_id = self.after(100, self.check_for_output)  # Schedule another check in 100ms

    @staticmethod
    def widget_exists(widget):
        try:
            widget.winfo_exists()
            return True
        except tk.TclError:
            return False

    def show_output(self, line):
        # Check if the output window is already created, if not, create it
        if not hasattr(self, "txt_output"):
            output_window = tk.Toplevel(self.master)  # Create a new window
            output_window.title("Command Output")
            output_window.geometry("1000x400")  # Adjust size as necessary

            # Bind the window's close event
            output_window.protocol("WM_DELETE_WINDOW", self.on_close)

            # Text widget to display output
            self.txt_output = tk.Text(output_window, wrap=tk.WORD)
            self.txt_output.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

            # Scrollbar for the Text widget
            scrollbar = tk.Scrollbar(output_window, command=self.txt_output.yview)
            scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
            self.txt_output.config(yscrollcommand=scrollbar.set)

            # Define a tag for the word "ERROR" with a red background
            self.txt_output.tag_configure("error", background="red")
            self.txt_output.tag_configure("good" , background="green")
            close_button = tk.Button(output_window, text="Close", command=self.on_close)
            close_button.pack(pady=10)

        # Check widget existence before appending the new line to the output display
        if CommandLineBuilder.widget_exists(self.txt_output):
            if "[ERROR]" in line:
                self.txt_output.insert(tk.END, line, "error")
            elif "status: FAILED" in line:
                self.txt_output.insert(tk.END, line, "error")
            elif "status: PASSED" in line:
                self.txt_output.insert(tk.END, line, "good")
            else:
                self.txt_output.insert(tk.END, line)

    def on_close(self):
        # Assuming check_for_output uses after method
        if hasattr(self, "after_id"):  # Check if after_id attribute exists
            self.after_cancel(self.after_id)  # Cancel any scheduled callbacks

        if hasattr(self, "txt_output"):
            # Destroy the Toplevel window containing the Text widget
            self.txt_output.master.destroy()
            del self.txt_output  # Remove the reference to the destroyed widget

    def close_app(self):
        # Add any required cleanup code here
        if hasattr(self, 'thread') and self.thread.is_alive():
            # Terminate the thread if it's running (this might be unsafe if your thread is doing crucial operations)
            # You might need more graceful handling depending on the operations your thread is performing.
            self.thread.join(timeout=1.0)  # Give it a second to finish
        self.destroy()

    def execute_command(self):
        cmd = self.cmd_display.get(1.0, tk.END).strip()  # Get the command from the Text widget

        # Create an empty output window immediately:
        self.show_output("Running command...\n")

        self.output_queue = queue.Queue()  # Initialize a queue for output data
        self.thread = threading.Thread(target=self.run_command_in_thread, args=(cmd,))
        self.thread.start()
        self.after(50, self.check_for_output)  # Reduce the delay to 50ms

    def print_command(self):
        cmd = self.cmd_display.get(1.0, tk.END).strip()  # Get the command from the Text widget
        # print the command to the original terminal
        print(cmd)


if __name__ == "__main__":
    app = CommandLineBuilder()
    app.mainloop()