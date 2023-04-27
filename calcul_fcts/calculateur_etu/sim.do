#!/usr/bin/tclsh

# Main proc at the end #

#------------------------------------------------------------------------------
proc compil_vhdl { } {
  global Path_VHDL

  puts "\nVHDL compilation :"

  # Ajouter les composants de votre solution
  vcom -2008 $Path_VHDL/addn.vhd
  vcom -2008 $Path_VHDL/calcul_fcts_top.vhd
}

#------------------------------------------------------------------------------
proc sim_auto_start { } {
  global Path_TB

  vcom -2008 $Path_TB/calcul_fcts_tb.vhd

  vsim -t 1ns work.calcul_fcts_tb

  set NumericStdNoWarnings 1
  set StdArithNoWarnings 1
  run 0 ns
  set NumericStdNoWarnings 0
  set StdArithNoWarnings 0
  
  #do wave.do
  add wave -divider "Tesbench signals"
  add wave /*
  add wave -divider "DUT signals"
  add wave dut/*
  wave refresh

  run -all
}

#------------------------------------------------------------------------------
proc sim_manuelle_start { } {
  global Path_TB

  # test-bench compilation
  vcom -2008 $Path_TB/console_sim.vhd
  #vcom -reportprogress 300 -work work   $Path_TB/console_sim.vhd
  # Chargement fichier pour la simulation
  vsim work.console_sim

  # ajout signaux composant simuler dans la fenetre wave
  #do wave.do
  add wave -divider "Tesbench signals"
  add wave /*
  add wave -divider "DUT signals"
  add wave dut/*
  wave refresh

  #lance la console REDS
  do /opt/tools_reds/REDS_console.tcl
}

#------------------------------------------------------------------------------
proc do_all { } {
  compil_vhdl
  sim_auto_start
}

## MAIN #######################################################################
if {$argc==1} {
  if {[string compare $1 "help"] == 0} {
    puts "Call this script with one of the following options:"
    puts "    all         : compiles and run auto sim"
    puts "    comp        : compiles all the vhdl files"
    puts "    sim_auto    : start an automatique simulation"
    puts "    sim_man     : start a manuelle simulation"
    puts "    help        : prints this help"
    puts "    no argument : compiles and run auto sim"
    puts ""
  }
}

# Compile folder ----------------------------------------------------
if {[file exists work] == 0} {
  vlib work
}

quietly set Path_VHDL     "../src"
quietly set Path_TB       "../src_tb"

global Path_VHDL
global Path_TB

# start of sequence -------------------------------------------------

if {$argc>0} {
  if {[string compare $1 "all"] == 0} {
    do_all
  } elseif {[string compare $1 "comp"] == 0} {
    compil_vhdl
  } elseif {[string compare $1 "sim_auto"] == 0} {
    sim_auto_start
  } elseif {[string compare $1 "sim_man"] == 0} {
    sim_manuelle_start
  } 
} else {
  do_all
}