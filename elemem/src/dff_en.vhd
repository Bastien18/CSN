-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : dff_en_ok_a.vhd
--
-- Description  : 
-- 
-- Auteur       : Etienne Messerli
-- Date         : 22.10.2014
-- Version      : 0.0
-- 
-- Utilise      : Exercice de description d'elements memoire
--                en VHDL synthetisable
-- 
--| Modifications |------------------------------------------------------------
-- Vers.    Qui                 Date         Description
-- 1.1      Bastien Pillonel    11.04.2023   Solution
-- 
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity dff_en is
   port( 
      clk_i    : in     std_logic;
      nReset_i : in     std_logic;
      D_i      : in     std_logic;
      en_i     : in     std_logic;
      Q_o      : out    std_logic
   );
end dff_en ;


architecture comport of dff_en is

signal Q_fut_s   : std_logic;
signal Q_pres_s  : std_logic;
signal reset_s : std_logic;

begin
  --Adaptation polarite
  reset_s <= not nReset_i;
  Q_fut_s <= Q_pres_s when en_i = '0' else D_i;
  
  --Assignation sortie
  Q_o <= Q_pres_s;
  
  --Flip flop D
  process(reset_s, clk_i)
  begin
  -- reset the flip flop
    if reset_s = '1' then
        Q_pres_s  <= '0';
    elsif rising_edge(clk_i) then
        Q_pres_s  <= Q_fut_s;
        
    end if;
  end process;

end comport;
