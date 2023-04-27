################################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# File         : run_comp_calcul_fcts_sim.tcl
#
# Description  : Script de compilation des fichiers et de lancement
#                de la simulation  manuelle du calculateur de fonctions
# 
# Auteur       : L. Fournier
# Date         : 17.02.2023
# Version      : 0.0
#
# Dependencies :
#
#--| Modifications |------------------------------------------------------------
# Version   Auteur      Date               Description
# 0.0       LFR         17.02.2023         Initial version.                        
################################################################################

################################################################################
#create library work        
vlib work

#map library work to work
vmap work work

# src compilation
do comp_calcul_fcts.tcl

# top_sim compilation
vcom -reportprogress 300 -work work   ../src_tb/console_sim.vhd

#Chargement fichier pour la simulation
vsim -voptargs="+acc" work.console_sim 

#ajout signaux composant simuler dans la fenetre wave
add wave UUT/*

#lance la console REDS
do /opt/tools_reds/REDS_console.tcl
################################################################################