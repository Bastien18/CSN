################################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# File         : run_acqu_pos_sim.tcl
#
# Description  : Script de compilation des fichiers et de lancement
#                de la simulation manuelle du labo acquisition de position avec 
#                la console REDS
#
# Auteur       : Etienne Messerli
# Date         : 07.12.2015
# Version      : 0.0
#
# Use          : Compilation/simulation manuelle acqu_pos_top.vhd
#
#--| Modifications |------------------------------------------------------------
# Version   Auteur      Date               Description
# 0.0       EMI         07.12.2015         Initial version. 
# 0.1       LFR         27.04.2023         maj pour lab 2023.                        
################################################################################

################################################################################
#compile src file 
do ../comp_acqu_pos_top.tcl

# tb file compilation
vcom -reportprogress 300 -work work   ../src_tb/console_sim_top.vhd

#Chargement fichier pour la simulation
vsim -voptargs="+acc" work.console_sim

#ajout signaux composant simuler dans la fenetre wave
add wave UUT/*

#lance la console REDS
do /opt/tools_reds/REDS_console.tcl
################################################################################