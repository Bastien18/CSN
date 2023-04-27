-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : flipflop_jk.vhd
-- Auteur       : Etienne Messerli,  20.04.2017
-- Description  : Flip-flop JK
-- 
-- 
-- Utilise      : Exos description d'elements memoire en VHDL synthetisable
--| Modifications |------------------------------------------------------------
-- Vers.  Qui   Date         Description
--
-------------------------------------------------------------------------------

--   Table de fonctionnement synchrone
--   du flip-flop JK
--
--    J  K |   Q+
--   ------+-------
--    0  0 |   Q
--    0  1 |   0
--    1  0 |   1
--    1  1 | not Q




library ieee;
  use ieee.std_logic_1164.all;

entity flipflop_jk is
   port(clk_i    : in     std_logic;
        reset_i  : in     std_logic;
        J_i      : in     std_logic;
        K_i      : in     std_logic;
        Q_o      : out    std_logic;
        nQ_o     : out    std_logic
   );
end flipflop_jk ;


architecture comport of flipflop_jk is

begin
  --Adaptation polarite
  
  

  
  process(reset_s, clk_i)
  begin

  
  
  end process;


end comport;
