--------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- File         : README.txt
--
-- Description  : Quelques explications pour le projet calcul fcts
--
-- Author       : L. Fournier
-- Date         : 17.02.2023
-- Version      : 0.0
--
-- Dependencies : 
--
--| Modifications |-------------------------------------------------------------
-- Version   Auteur      Date               Description
-- 0.0       LFR         17.02.2023         Initial version.
--------------------------------------------------------------------------------

--| A. Liste des fichiers/dossiers |--------------------------------------------
.
|- README.txt            Ce fichier: A lire avant l'utilisation du 
|                                       projet calcul_fcts. Il decrit 
|                                       l'utilisation des differents fichiers 
|                                       script (*.tcl)
|
|- comp_calcul_fcts.tcl             Script de compilation des fichiers sources
|                                       Il faut ajouter les composants créés
|
|- run_comp_calcul_fcts_sim.tcl     Script de compilation pour la simulation 
|                                       manuelle du calculateur de fonctions 
|                                       avec la console REDS
|
|- run_comp_calcul_fcts_tb.tcl      Script de compilation pour la simulation du 
|                                       calculateur de fonctions  avec un banc
|                                       de test  automatique
|
|- wave_calcul_fcts_tb.tcl          Ajoute les signaux pour la simulation avec 
|                                       tb 
|
|-- comp                            Dossier de travail pour la simulation
|                                       Repertoire de travail pour Questasim
|
|-- pr                              Repertoire pour realiser des syntheses de 
|                                       test du design
|
|-- pr_cpld                         Repertoire pour la synthese et le p+r pour 
|                                       l'integration dans le circuit MAX-V
|
|-- src                             Repertoire pour les sources du calculateur
|   |                                   de fonctions
|   |
|   |- addn.vhd                     Fichier source de l'additionneur
|   |
|   \- calcul_fcts_top.vhd          Fichier source du calculateur de fonctions
|
|-- src_cpld                        Repertoire contenant les tops pour 
|   |                                   l'integration dans carte MaxV 
|   |
|   \- maxv_top.vhd                 Fichier top pour integration du calculateur
|
|-- src_pr                          Repertoire contenant les fichiers a copier 
|   |                                   dans ./pr_cpld/ pour integration
|   |
|   |- maxv_top_pin_assignement.qsf Fichier pour assignation pin
|   |
|   \- maxv_top.sdc                 Fichier pour timing clock
|  
\-- src_tb
    |- console_sim.vhd              console_sim pour la simulation manuelle, a
    |                                   utiliser avec la Console_REDS.tcl
    |
    \- calcul_fcts_tb.vhd           Banc de test automatique pour la simulation
                                        automatique
--------------------------------------------------------------------------------

--| B. Simulations manuelles avec la console REDS_Console |---------------------
La marche a suivre pour la simulation manuelle avec console REDS_Console.tcl est
la suivante:
  1.  Ouvrir QuestaSim
  2.  Se placer dans le dossier .../comp (File -> Change Directory)
  3.  Lancer le script de compilation et de chargement
        do ../run_comp_calcul_fcts_sim.tcl
  4. Utiliser la console REDS pour generer les signaux.
--------------------------------------------------------------------------------

--| C. Simulations automatique avec le banc de test |---------------------------
La marche a suivre pour la simulation manuelle avec console REDS_Console.tcl est
la suivante:
  1.  Ouvrir QuestaSim
  2.  Se placer dans le dossier ../comp (File -> Change Directory)
  3.  Lancer le script de compilation et de chargement
        do ../run_comp_calcul_fcts_tb.tcl
  4. Lancer la simulation: run -all
--------------------------------------------------------------------------------