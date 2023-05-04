################################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# File         : comp_acqu_pos_top.tcl
#
# Description  : Script de compilation des fichiers
#
# Auteur       : Etienne Messerli
# Date         : 07.12.2015
# Version      : 0.0
#
# Used in      : Compilation projet Acquisition de position table tournante
#                fichier comp_acqu_pos_top.vhd
#
#--| Modifications |------------------------------------------------------------
# Version   Auteur      Date               Description
# 0.0       EMI         07.12.2015         Initial version.
# 0.1       LFR         24.04.2023         2023 version.
################################################################################

################################################################################
# create library work
vlib work

# map library work to work
vmap work work

# subcomponents file compilation
vcom -reportprogress 300 -work work   ../src/mss_det_rot.vhd
vcom -reportprogress 300 -work work   ../src/cpt_pos.vhd

# top file compilation
vcom -reportprogress 300 -work work   ../src/acqu_pos_top.vhd
################################################################################