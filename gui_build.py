#! /usr/bin/env python

import os
import tkinter as tk
from tkinter import ttk
from tkinter import messagebox

class CommandLineBuilder(tk.Tk):

    def __init__(self):
        super().__init__()

        self.title("Command Line Builder")

        # Variables for options
        self.dut_var = tk.StringVar(self)
        self.regress_var = tk.StringVar(self)
        self.regress_enabled_var = tk.BooleanVar(self)
        self.tests_vars = {}  # Dictionary to store each test variable
        self.tests_enabled_var = tk.BooleanVar(self)
        self.app_var = tk.BooleanVar(self)
        self.hw_var = tk.BooleanVar(self)
        self.sim_var = tk.BooleanVar(self)
        self.full_run_var = tk.BooleanVar(self)
        self.pp_var = tk.BooleanVar(self)
        self.mif_var = tk.BooleanVar(self)
        self.clean_var = tk.BooleanVar(self)
        self.cmd_var = tk.BooleanVar(self)

        # Descriptions
        self.desc = {
            "-dut"      : "Specify the Device Under Test.",
            "-tests"    : "Choose which tests you'd like to run.",
            "-regress"  : "Specify the regression that has pre-determine test lists to run.",
            "-app"      : "For CPU tests that needs to compile a C code to create the elf to load to DUT memory.",
            "-hw"       : "HW Compile the DUT system verilog using vlog.exe - according to the .f file list.",
            "-sim"      : "HW Elaborate the Compiled model + start running the TB (test-bench).",
            "-full_run" : "SW & HW compile + simulation (-app -hw -sim)",
            "-pp"       : "HW Post Processing - after simulation is done, run the post processing script ./verif/<dut>/<dut>_pp.py.",
            "-mif"      : "create the mif memory files for the FPGA load",
            "-clean"    : "Clean the build directory before building.",
            "-cmd"      : "Without executing, display the commands that will be executed.",
        }

        # -dut drop-down
        self.create_combobox_option("DUT", "-dut", self.get_dut_options)


        # -tests checkbox options
        self.tests_frame = ttk.LabelFrame(self, text="-tests Options")
        self.tests_frame.pack(anchor="w", padx=10, pady=5, fill="x")

        tests_check_frame = ttk.Frame(self)  # New frame to encapsulate both the checkbox and its description
        tests_check_frame.pack(anchor="w", padx=10, pady=5, fill="x")

        self.tests_check = ttk.Checkbutton(tests_check_frame, text="-tests", variable=self.tests_enabled_var, command=self.toggle_test_visibility)
        self.tests_check.pack(side="left", anchor="w")  # Removed the padx from here

        ttk.Label(tests_check_frame, text=self.desc["-tests"], foreground="gray").pack(side="left", anchor="w", padx=10)

        self.update_test_checkboxes()

        # -regress checkbox and dropdown
        self.create_combobox_option_with_checkbox("Regression", "-regress", self.get_regress_options)

        # simple checkboxes
        self.add_checkbox_option("-app", self.app_var)
        self.add_checkbox_option("-hw", self.hw_var)
        self.add_checkbox_option("-sim", self.sim_var)
        self.add_checkbox_option("-full_run", self.full_run_var)
        self.add_checkbox_option("-pp", self.pp_var)
        self.add_checkbox_option("-clean", self.clean_var)
        self.add_checkbox_option("-mif", self.mif_var)
        self.add_checkbox_option("-cmd", self.cmd_var)

        # Command display
        self.cmd_display = tk.Text(self, height=2, width=150)
        self.cmd_display.pack(padx=10, pady=10)

        # Initial setup
        self.toggle_test_visibility()  # Hide test options by default
        self.update_command_display()

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

    def update_test_checkboxes(self):
        for widget in self.tests_frame.winfo_children():
            widget.destroy()

        tests = self.get_test_options()
        for test in tests:
            frame = ttk.Frame(self.tests_frame)
            frame.pack(anchor="w", fill="x")
            var = self.tests_vars.get(test) or tk.BooleanVar(self)
            self.tests_vars[test] = var
            cb = ttk.Checkbutton(frame, text=test, variable=var, command=self.update_command_display)
            cb.pack(anchor="w", side="left", padx=5)

    def update_dropdown_options(self, dropdown, fetch_option):
        dropdown["values"] = fetch_option()

    def get_dut_options(self):
        return os.listdir("verif")

    def get_test_options(self):
        test_path = f"verif/{self.dut_var.get()}/tests"
        if os.path.exists(test_path):
            return os.listdir(test_path)
        else:
            return []

    def get_regress_options(self):
        regress_path = f"verif/{self.dut_var.get()}/regress"
        if os.path.exists(regress_path):
            return os.listdir(regress_path)
        else:
            return []

    def on_combobox_select(self, event):
        if event.widget.cget("textvariable") == str(self.dut_var):
            self.update_test_checkboxes()
        self.update_command_display()

    def update_command_display(self):
        cmd = "python build.py"
        
        cmd += f" -dut {self.dut_var.get()}"
        
        # Collect checked tests
        # Can't select regression & tests
        selected_tests = [test for test, var in self.tests_vars.items() if var.get()]
        if selected_tests and self.regress_enabled_var.get():
            messagebox.showerror("Error", "Can't run regression & tests - choose one or the other")
            # uncheck the regression checkbox
            self.regress_enabled_var.set(False)
            return
        # Can't select full_run & (app or hw or sim)
        if self.full_run_var.get() and (self.app_var.get() or self.hw_var.get() or self.sim_var.get()):
            messagebox.showerror("Error", "Can't run full_run & (app or hw or sim) - choose one or the other")
            # uncheck the full_run checkbox
            self.full_run_var.set(False)
            return
        # make sure that the file "./verif/<dut>/<dut>_pp.py." exists
        if self.pp_var.get():
            pp_path = f"verif/{self.dut_var.get()}/{self.dut_var.get()}_pp.py"
            if not os.path.exists(pp_path):
                messagebox.showerror("Error", f"Can't run pp - {pp_path} doesn't exist")
                # uncheck the pp checkbox
                self.pp_var.set(False)
                return

        if selected_tests:
            cmd += " -test " + " '" + " ".join(selected_tests) + " '"

        if self.regress_enabled_var.get():
            cmd += f" -regress {self.regress_var.get()}"
        if self.app_var.get():
            cmd += " -app"
        if self.hw_var.get():
            cmd += " -hw"
        if self.sim_var.get():
            cmd += " -sim"
        if self.pp_var.get():
            cmd += " -pp"
        if self.full_run_var.get():
            cmd += " -full_run"
        if self.clean_var.get():
            cmd += " -clean"
        if self.mif_var.get():
            cmd += " -mif"
        if self.cmd_var.get():
            cmd += " -cmd"

        self.cmd_display.delete(1.0, tk.END)
        self.cmd_display.insert(tk.END, cmd)

    def toggle_test_visibility(self):
        if self.tests_enabled_var.get():
            self.tests_frame.pack(anchor="w", padx=10, pady=5, fill="x")
        else:
            self.tests_frame.pack_forget()
        self.update_command_display()

if __name__ == "__main__":
    app = CommandLineBuilder()
    app.mainloop()
