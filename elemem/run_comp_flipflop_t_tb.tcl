###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : run_comp_flipflop_t_tb.tcl
# Description  : Script de compilation des fichiers et 
#                de lancement de la simulation
# 
# Auteur       : Etienne Messerli
# Date         : 17.09.2014
# Version      : 1.0
#
# Utilise      : Compile et simule composant flipflop_t.vhd et le tb
#
#--| Modifications |--------------------------------------------------------
# Ver  Aut.  Date      Description
# 1.1  EMI  03.04.2019 Changer nom fichiers => flipflop_t et
#                      modifie l'entete
#                         
############################################################################

#create library work        
vlib work
#map library work to work
vmap work work

# bin-lin file compilation
#decommenter la ligne de la description souhaitee
vcom -reportprogress 300 -work work   ../src/flipflop_t.vhd

# test-bench compilation
vcom -reportprogress 300 -work work   ../src_tb/flipflop_t_tb.vhd

#Chargement fichier pour la simulation
vsim -voptargs="+acc" work.flipflop_t_tb 

#ajout signaux composant simuler dans la fenetre wave
add wave UUT/*

#ouvre le fichier format predefini
#do wave_bin_lin_2to4_tb.do


