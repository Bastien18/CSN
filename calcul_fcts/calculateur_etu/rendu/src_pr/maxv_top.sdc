#**************************************************************
# Altera DE1-SoC SDC settings
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -name {main_clk} -period 1000 [get_ports Clk_Main_i]

set_false_path -from [get_ports {Con_25p_io[*]}] -to [get_cells -compatibility_mode *]
set_false_path -from [get_ports {Con_80p_io[*]}] -to [get_cells -compatibility_mode *]
# Encoder_A_i and Encoder_B_i unused in this design, generates a warning if left in .sdc file
# set_false_path -from [get_ports {Encoder_A_i}] -to [get_cells -compatibility_mode *]
# set_false_path -from [get_ports {Encoder_B_i}] -to [get_cells -compatibility_mode *]
set_false_path -from [get_ports {nButton_i[*]}] -to [get_cells -compatibility_mode *]
set_false_path -from [get_ports {nReset_i}] -to [get_cells -compatibility_mode *]
set_false_path -from [get_ports {Switch_i[*]}] -to [get_cells -compatibility_mode *]

set_false_path -from [get_cells -compatibility_mode *] -to [get_ports {Con_25p_io[*]}]
set_false_path -from [get_cells -compatibility_mode *] -to [get_ports {Con_80p_io[*]}]
set_false_path -from [get_cells -compatibility_mode *] -to [get_ports {nLed_o[*]}]
set_false_path -from [get_cells -compatibility_mode *] -to [get_ports {Led_RGB_o[*]}]
set_false_path -from [get_cells -compatibility_mode *] -to [get_ports {nSeven_Seg_o[*]}]
