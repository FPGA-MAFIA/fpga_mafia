#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "10.0 MHz" [get_ports ADC_CLK_10]
create_clock -period "50.0 MHz" [get_ports MAX10_CLK1_50]
create_clock -period "50.0 MHz" [get_ports MAX10_CLK2_50]




# SDRAM CLK
#create_generated_clock -source [get_pins {u1|sdram_pll0_inst|altpll_component|auto_generated|pll1|clk[1]}] \
                      -name clk_dram_ext [get_ports {DRAM_CLK}]


#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************
## suppose +- 100 ps skew
## Board Delay (Data) + Propagation Delay - Board Delay (Clock)
## max 5.4(max) +0.4(trace delay) +0.1  = 5.9
## min 2.7(min) +0.4(trace delay) -0.1 = 3.0
#set_input_delay -max -clock clk_dram_ext 5.9 [get_ports DRAM_DQ*]
#set_input_delay -min -clock clk_dram_ext 3.0 [get_ports DRAM_DQ*]

#shift-window
#set_multicycle_path -from [get_clocks {clk_dram_ext}] \
                    -to [get_clocks {u1|sdram_pll0_inst|altpll_component|auto_generated|pll1|clk[0]}] \
						  -setup 2
						  
#**************************************************************
# Set Output Delay
#**************************************************************
## suppose +- 100 ps skew
## max : Board Delay (Data) - Board Delay (Clock) + tsu (External Device)
## min : Board Delay (Data) - Board Delay (Clock) - th (External Device)
## max 1.5+0.1 =1.6
## min -0.8-0.1 = 0.9
#set_output_delay -max -clock clk_dram_ext 1.6  [get_ports {DRAM_DQ* DRAM_*DQM}]
#set_output_delay -min -clock clk_dram_ext -0.9 [get_ports {DRAM_DQ* DRAM_*DQM}]
#set_output_delay -max -clock clk_dram_ext 1.6  [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]
#set_output_delay -min -clock clk_dram_ext -0.9 [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************



