###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : run_comp_dff_en_tb.tcl
# Description  : Script de compilation des fichiers et 
#                de lancement de la simulation
# 
# Auteur       : Etienne Messerli
# Date         : 17.09.2014
# Version      : 1.0
#
# Utilise      : Compilation et simulation dff_en.vhd
#
#--| Modifications |--------------------------------------------------------
# Ver  Aut.  Date   Description
# 1.1  EMI   04.04.2019  Modifie l'entete
#                         
############################################################################

#create library work        
vlib work
#map library work to work
vmap work work

# bin-lin file compilation
#decommenter la ligne de la description souhaitee
vcom -reportprogress 300 -work work   ../src/dff_en.vhd

# test-bench compilation
vcom -reportprogress 300 -work work   ../src_tb/dff_en_tb.vhd

#Chargement fichier pour la simulation
vsim -voptargs="+acc" work.dff_en_tb 

#ajout signaux composant simuler dans la fenetre wave
add wave UUT/*

#ouvre le fichier format predefini
#do wave_bin_lin_2to4_tb.do


