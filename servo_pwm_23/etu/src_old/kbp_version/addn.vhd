-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : addn.vhd
-- Description  : Additionneur N bits avec carry in & carry out
--
-- Auteur       : E. Messerli
-- Date         : 10.10.2014
-- Version      : 1.0
--
-- Utilise      : Exercice cours VHDL
--
--| Modifications |-----------------------------------------------------------
-- Ver   Auteur  Date        Description
-- 2.0   KBP     2023.03.23  Additionneur N bits avec carry in/out
--
------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity addn is
  generic (N : positive range 1 to 31 := 17);
  port (nbr_a_i   : in  std_logic_vector(N-1 downto 0); -- N-1: counting from 0, the MSB is N-1
        nbr_b_i   : in  std_logic_vector(N-1 downto 0);
        cin_i     : in  std_logic;
        somme_o   : out std_logic_vector(N-1 downto 0);
        cout_o    : out std_logic
        );
end addn;

architecture flot_don of addn is
  -- internal signals
  signal nbr_a_s, nbr_b_s : unsigned(N downto 0); -- Work with N+1bits because we operate on N
  signal somme_s          : unsigned(N downto 0); -- This allows to easily recover the carry with an internal signal
  signal cin_vect_s       : unsigned(0 downto 0); -- By using a size's vector of 1, we use the ability to 
                                                  -- compute unsigned with different length (cin_i with nbr_a/b_s)

begin
  -- concurrent instru.
  nbr_a_s <= unsigned('0' & nbr_a_i);
  nbr_b_s <= unsigned('0' & nbr_b_i);
  cin_vect_s(0) <= cin_i;

  somme_s <= nbr_a_s + nbr_b_s + cin_vect_s;
  somme_o <= std_logic_vector(somme_s(N-1 downto 0));
  cout_o <= somme_s(somme_s'high); -- MSB pos.

end flot_don;
