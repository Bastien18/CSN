onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider UUT
add wave -noupdate -radix decimal /calcul_fcts_tb/UUT/na_i
add wave -noupdate -radix decimal /calcul_fcts_tb/UUT/nb_i
add wave -noupdate /calcul_fcts_tb/UUT/sel_i
add wave -noupdate -radix decimal /calcul_fcts_tb/UUT/f_o
add wave -noupdate -radix decimal /calcul_fcts_tb/result_dut_s
add wave -noupdate -divider TB
add wave -noupdate -radix decimal /calcul_fcts_tb/na_sti
add wave -noupdate -radix decimal /calcul_fcts_tb/nb_sti
add wave -noupdate /calcul_fcts_tb/sel_sti
add wave -noupdate -radix decimal /calcul_fcts_tb/f_obs
add wave -noupdate -radix decimal /calcul_fcts_tb/result_tb_s
add wave -noupdate /calcul_fcts_tb/end_of_sim_s
add wave -noupdate /calcul_fcts_tb/err_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {169162 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 130
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {212100 ns}
