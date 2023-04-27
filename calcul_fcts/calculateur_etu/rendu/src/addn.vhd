--------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- File         : addn.vhd
--
-- Description  : Additionneur n bits avec carry in & carry out
--
-- Author       : Brasey Loic et Bastien Pillonel
-- Date         : 06.02.2023
-- Version      : 1.0
--------------------------------------------------------------------------------

--| Library |-------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
--------------------------------------------------------------------------------

--| Entity |--------------------------------------------------------------------
entity addn is
  generic( N : positive range 1 to 31 := 26);
  port (nbr_a_i   : in  std_logic_Vector(N-1 downto 0);
        nbr_b_i   : in  std_logic_Vector(N-1 downto 0);
        cin_i     : in  std_logic;
        somme_o   : out std_logic_Vector(N-1 downto 0);
        cout_o    : out std_Logic
        );
end addn;
--------------------------------------------------------------------------------

--| Architecture |--------------------------------------------------------------
architecture comportement of addn is

  --| Signals |-----------------------------------------------------------------
  signal nbr_a_s : unsigned(N downto 0);
  signal nbr_b_s : unsigned(N downto 0);
  signal somme_s : unsigned(N downto 0);
  signal cin_s   : unsigned(0 downto 0);
  ------------------------------------------------------------------------------
  
begin

  -- Assignation of intern signals
  nbr_a_s   <= "0" & unsigned(nbr_a_i);
  nbr_b_s   <= "0" & unsigned(nbr_b_i);
  cin_s(0)  <= cin_i;
  somme_s   <= nbr_a_s + nbr_b_s + cin_s;
  
  -- Output
  somme_o   <= std_logic_Vector(somme_s(N-1 downto 0));
  cout_o    <= somme_s(N);

end comportement;
--------------------------------------------------------------------------------
