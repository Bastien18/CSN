################################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# File         : comp_calcul_fcts.tcl
#
# Description  : Script de compilation des fichiers du calculateur de fonctions
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

# addn file compilation
vcom -reportprogress 300 -work work   ../src/addn.vhd

# Ajouter les composants que vous avez créé
#...

# calcul_fcts_top file compilation
vcom -reportprogress 300 -work work   ../src/calcul_fcts_top.vhd

################################################################################