-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : dff_ar_tb.vhd
-- Description  : Testbench pour la simulation du fichier DFF.vhd
--                
-- Auteur       : E. Messerli
-- Date         : 01.12.00
-- Version      : 1.2 
--
-- Utilise      : Exercice formation VHDL
--                                                                              
--| Modifications |-----------------------------------------------------------
-- Version   Auteur Date         Description                              
-- 1.1       GBR    07.04.2004    Mise à jour  
-- 1.2       YNG    19.09.2007    Mise à jour entete 
-- 2.0       EMI    22.10.2014    Adaptation pour nouveau fichier VHDL
--                                Changer le nom du fichier
-- 2.1       GAA    21.03.2017    Adaptation pour dff_ar
------------------------------------------------------------------------------

library IEEE;
  use IEEE.Std_Logic_1164.all;
  --use IEEE.Numeric_Std.all;

entity dff_ar_tb is

end dff_ar_tb;

------------------------------------------------------------------------
-- Architecture du testbench VHDL 
------------------------------------------------------------------------

architecture test_bench of dff_ar_tb is

  component dff_ar 
   port (clk_i   : in     std_logic;
         reset_i : in     std_logic; --reset asynchrone actif haut
         D_i     : in     std_logic;
         Q_o     : out    std_logic;
         nQ_o    : out    std_logic
        );
  end component;
  for all : dff_ar use entity work.dff_ar(comport);

constant Periode_c   : time := 100 ns;
constant Pulse_c     : time := 4 ns;

signal Erreur_s : Std_Logic := '0';
shared variable Nbr_Err_v : Natural; --partagee process stimuli et verif

--signaux de base pour la simulation sequentiel (HORLOGE)
signal Sim_End : boolean := false;
signal Horloge_int : std_logic;           -- signal d'horloge

--signaux de detection des erreurs (check), propre a l'application
signal Q_ref, nQ_ref : std_logic := '0';

--signaux intermediares pour la simulation, propre a l'application
signal D_sti, Reset_sti, Q_obs, nQ_obs : std_logic;


---------------------------------------------------------------------------
-- Procedure permettant plusieurs cycles d'horloge
-- Le premier appel de la procedure termine le cycle precedent si celui-ci
-- n'etait pas complet (par exemple : si on a fait quelques pas de 
-- simulation non synchronises avant, reset asynchrone, combinatoire, ...)
---------------------------------------------------------------------------

procedure cycle (nombre_de_cycles : Integer := 1) is
  begin
    for i in 1 to nombre_de_cycles loop
      wait until Falling_Edge(Horloge_Int);
      wait for 2 ns; --assigne stimuli 2ns apres flanc montant 
    end loop;
end cycle;

begin

------------------------------------------------------------------
--Process de generation de l'horloge
------------------------------------------------------------------

  process
  begin
    while not Sim_End loop
      Horloge_Int <= '1', '0' after Periode_c/2;
      wait for Periode_c;
    end loop;
    wait;
  end process;

---------------------------------------------------------------------------
-- Interconnexion du module VHDL a simuler
---------------------------------------------------------------------------
uut: dff_ar port map (clk_i   => Horloge_int,
                      reset_i => Reset_sti,
                      D_i     => D_sti,
                      Q_o     => Q_obs,
                      nQ_o    => nQ_obs);

---------------------------------------------------------------------------
-- Debut des pas de simulation
---------------------------------------------------------------------------

  process
  begin
     report ">> Debut de la simulation";
     Nbr_Err_v := 0; -- initialise compteur d'erreur

-----Test de la remise a zero asynchrone
	Reset_sti <= '1';
	D_sti <= 'X';
        -- action asynchrone, references changent de suite
	Q_ref <= '0';
	nQ_ref <= '1';
        cycle(2);
      
	Reset_sti <= '0'; --Desactive le reset

-----Test du chargement avec D= 1
	D_sti <= '1';
        wait until Rising_Edge(Horloge_Int);
	Q_ref <= '1'; --Etat pas modifie
	nQ_ref <= '0';
        cycle;

-----Test du chargement avec D= 0
	D_sti <= '0';
	 wait until Rising_Edge(Horloge_Int);
	Q_ref <=  '0'; 
	nQ_ref <= '1';
        cycle;

        -----Test du chargement avec D= 1
	D_sti <= '1';
        wait until Rising_Edge(Horloge_Int);
	Q_ref <= '1'; --Etat pas modifie
	nQ_ref <= '0';
        cycle;

        -----Test de la remise a zero asynchrone
        --   avec Q a l'etat '1'
	Reset_sti <= '1';
	D_sti <= '1';
        -- action asynchrone, references changent de suite
	Q_ref <= '0';
	nQ_ref <= '1';
        cycle;

     report ">>Nombre d'erreur détectée = " & integer'image(Nbr_Err_v);
     report ">>Fin de la simulation";

    sim_end <= true;
    wait; --Attente infinie, stop la simulation
  end process;
  
---------------------------------------------------------------------------
-- Process de verification
---------------------------------------------------------------------------
  process
  begin
    while not Sim_End loop
      wait until Falling_Edge(Horloge_Int);
      wait for (Periode_c/2)- 2 ns;
    --Verification asynchrone
      if Q_obs /= Q_ref then
        Erreur_s <= '1', '0' after Pulse_c;
        Nbr_Err_v := Nbr_Err_v + 1;
        report"Erreur sur Q lors verif Sortie, asynch"
          severity ERROR;
      end if;
      
      if nQ_obs /= nQ_ref then
        Erreur_s <= '1', '0' after Pulse_c;
        Nbr_Err_v := Nbr_Err_v + 1;
        report"Erreur sur Q_L lors verif Sortie, asynch"
          severity ERROR;
      end if;
      
      wait until Rising_Edge(Horloge_Int);
      wait for (Periode_c/2)- 2 ns;
    --Verification synchrone
      if Q_obs /= Q_ref then
        Erreur_s <= '1', '0' after Pulse_c;
        Nbr_Err_v := Nbr_Err_v + 1;
        report"Erreur sur Q lors verif Sortie, synch"
          severity ERROR;
      end if;

      if nQ_obs /= nQ_ref then
        Erreur_s <= '1', '0' after Pulse_c;
        Nbr_Err_v := Nbr_Err_v + 1;
        report"Erreur sur Q_L lors verif Sortie, synch"
          severity ERROR;
      end if;
    
    end loop;
    wait;
  end process;

end test_bench;







