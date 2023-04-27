onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /servo_pwm_tb/dut/clock_i
add wave -noupdate /servo_pwm_tb/dut/nReset_i
add wave -noupdate /servo_pwm_tb/dut/down_i
add wave -noupdate /servo_pwm_tb/dut/up_i
add wave -noupdate /servo_pwm_tb/dut/center_i
add wave -noupdate /servo_pwm_tb/dut/mode_i
add wave -noupdate /servo_pwm_tb/dut/pwm_o
add wave -noupdate /servo_pwm_tb/dut/top_2ms
add wave -noupdate /servo_pwm_tb/reference_ref.curr_duty
add wave -noupdate /servo_pwm_tb/skip_verif_pwm_s

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 224
configure wave -valuecolwidth 87
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ns} {956 ns}
