###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : run_comp_flipflop_rs_tb.tcl
# Description  : Script de compilation des fichiers et 
#                de lancement de la simulation
# 
# Auteur       : Etienne Messerli
# Date         : 20.04.2020
# Version      : 1.0
#
# Utilise      : Compile et simule composant flipflop_t.vhd et le tb
#
#--| Modifications |--------------------------------------------------------
# Ver  Aut.  Date      Description
#
#                         
############################################################################

#create library work        
vlib work
#map library work to work
vmap work work

# bin-lin file compilation
#decommenter la ligne de la description souhaitee
vcom -reportprogress 300 -work work   ../src/flipflop_rs.vhd

# test-bench compilation
vcom -reportprogress 300 -work work   ../src_tb/flipflop_rs_tb.vhd

#Chargement fichier pour la simulation
vsim -voptargs="+acc" work.flipflop_rs_tb 

#ajout signaux composant simuler dans la fenetre wave
add wave UUT/*

#ouvre le fichier format predefini
#do wave_flipflop_rs_tb.do


