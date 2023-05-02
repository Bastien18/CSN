################################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# File         : run_comp_bin_lin_2to4_tb.tcl
#
# Description  : Script de compilation des fichiers et de lancement
#                de la simulation automatique du bin-lin 2a4
# 
# Auteur       : Etienne Messerli
# Date         : 17.09.2014
# Version      : 1.0
#
# Dependencies :
#
#--| Modifications |------------------------------------------------------------
# Version   Auteur      Date               Description
# 0.0       EMI         17.09.2014         Initial version.                        
################################################################################

################################################################################
#create library work        
vlib work

#map library work to work
vmap work work

# file compilation
vcom -reportprogress 300 -work work   ../src/ilog_pkg.vhd
vcom -reportprogress 300 -work work   ../src/top_gen.vhd
#vcom -reportprogress 300 -work work   ../src/triangle_gen.vhd
vcom -reportprogress 300 -work work   ../src/gestion_position.vhd
vcom -reportprogress 300 -work work   ../src/pwm.vhd
vcom -reportprogress 300 -work work   ../src/servo_pwm_top.vhd

# test-bench compilation
vcom -reportprogress 300 -work work   ../src_tb/servo_pwm_tb.vhd

#Chargement fichier pour la simulation
vsim -voptargs="+acc" work.servo_pwm_tb 

#ajout signaux composant simuler dans la fenetre wave
#add wave UUT/*

#ouvre le fichier format predefini
do wave_servo_pwm_tb.do
################################################################################
