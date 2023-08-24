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
        self.tests_vars = {}  # Dictionary to store each test variable
        self.tests_enabled_var = tk.BooleanVar(self)
        self.app_var = tk.BooleanVar(self)
        self.hw_var = tk.BooleanVar(self)
        self.regress_enabled_var = tk.BooleanVar(self)

        # Descriptions
        self.desc = {
            "-dut": "Specify the Device Under Test.",
            "-tests": "Specify the tests you'd like to run.",
            "-app": "Specify if application mode.",
            "-hw": "Specify if hardware mode.",
            "-regress": "Specify the regression you'd like to run."
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

        # -app checkbox
        self.add_checkbox_option("-app", self.app_var)

        # -hw checkbox
        self.add_checkbox_option("-hw", self.hw_var)

        # Command display
        self.cmd_display = tk.Text(self, height=2, width=50)
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
        selected_tests = [test for test, var in self.tests_vars.items() if var.get()]
        if selected_tests and self.regress_enabled_var.get():
            messagebox.showerror("Error", "Can't run regression & tests - choose one or the other")
            return

        if selected_tests:
            cmd += " -test " + " ".join(selected_tests)

        if self.regress_enabled_var.get():
            cmd += f" -regress {self.regress_var.get()}"

        if self.app_var.get():
            cmd += " -app"
        if self.hw_var.get():
            cmd += " -hw"

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
