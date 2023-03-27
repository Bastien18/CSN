--------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- File         : calcul_fcts_top.vhd
--
-- Description  : 
--
-- Author       : L. Fournier
-- Date         : 06.02.2023
-- Version      : 1.0
--
-- Use          :
--
--| Modifications |-------------------------------------------------------------
-- Version   Auteur      Date               Description
-- 1.0       LFR         06.02.2023         Empty version.
--------------------------------------------------------------------------------

--| Library |-------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
--------------------------------------------------------------------------------

--| Entity |--------------------------------------------------------------------
entity calcul_fcts_top is
    port(
		na_i  : in  std_logic_vector(7 downto 0);
		nb_i  : in  std_logic_vector(7 downto 0);
		sel_i : in  std_logic;
		f_o   : out std_logic_vector(10 downto 0)-- A définir
    );
end calcul_fcts_top;
--------------------------------------------------------------------------------

--| Architecture |--------------------------------------------------------------
architecture struct of calcul_fcts_top is

    --| Signals |---------------------------------------------------------------
    signal na_sur_2_s: std_logic_vector(7 downto 0);
    signal na_and_sel_s: std_logic_vector(7 downto 0);
    signal nb_s: std_logic_vector(8 downto 0);
    signal n42_s : std_logic_vector(8 downto 0);
    signal rslt_add9_s: std_logic_vector(8 downto 0);
    signal operande_1_s: std_logic_vector(10 downto 0);
    signal operande_2_s: std_logic_vector(10 downto 0);
    signal f_s: std_logic_vector(10 downto 0);
    
    ----------------------------------------------------------------------------

    --| Components |------------------------------------------------------------
    component addn is
        generic( N : positive range 1 to 31 := 26);
        port (nbr_a_i   : in  std_logic_Vector(N-1 downto 0);
          nbr_b_i   : in  std_logic_Vector(N-1 downto 0);
          cin_i     : in  std_logic;
          somme_o   : out std_logic_Vector(N-1 downto 0);
          cout_o    : out std_Logic
        );
    end component;
    for all : addn use entity work.addn(comportement);
    ----    ------------------------------------------------------------------------

begin

    --| Components instanciation |----------------------------------------------
    na_sur_2_s(7 downto 6) <=  (others => na_i(7));
    na_sur_2_s(5 downto 0) <=  na_i(6 downto 1); 
    na_and_sel_s <= na_i when sel_i = '1' else (others => '0');
    --na_sur_2_s(5 downto 0) => na_i(6 downto 1); 
    
    
    add8: addn
    generic map ( N => 8 )
    port map(nbr_a_i   => na_sur_2_s,
             nbr_b_i   => na_and_sel_s,
             cin_i     => '0',
             somme_o   => operande_1_s(8 downto 1)
             -- cout_o 
             );
    
    operande_1_s(0) <= na_i(0);
    operande_1_s(10 downto 9) <= (others => na_i(na_i'high)); 
    
    
    nb_s <= nb_i(7) & nb_i when sel_i = '0' else not(nb_i(7) & nb_i); 
    n42_s <= '0' & x"2a" xor not(8 downto 0 => sel_i);
    --n42_s <= '0' & x"2a" when sel_i = '1' else not( '0' & x"2a");
    
    add9: addn
    generic map ( N => 9 )
    port map(nbr_a_i   => nb_s,
             nbr_b_i   => n42_S,
             cin_i     => '1',
             somme_o   => rslt_add9_s
             -- cout_o 
             );
    operande_2_s(9 downto 0) <= rslt_add9_s(8) & rslt_add9_s when sel_i ='1' else rslt_add9_s & '0';
    operande_2_s(10) <= operande_2_s(9);
    
    add11: addn
    generic map ( N => 11 )
    port map(nbr_a_i   => operande_1_s,
             nbr_b_i   => operande_2_s,
             cin_i     => '0',
             somme_o   => f_s
             -- cout_o 
             );
    
    
    
    f_o <= f_s;
    ----------------------------------------------------------------------------

    --| Outputs affectation |---------------------------------------------------
    
    ----------------------------------------------------------------------------

end struct;
--------------------------------------------------------------------------------
