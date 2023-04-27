-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : flipflop_rs.vhd
-- Auteur       : Etienne Messerli,  20.04.2017
-- Description  : Flip-flop RS
-- 
-- 
-- Utilise      : Exos description d'elements memoire en VHDL synthetisable
--| Modifications |------------------------------------------------------------
-- Vers.  Qui   Date         Description
--
-------------------------------------------------------------------------------

--   Table de fonctionnement synchrone
--   du flip-flop RS
--
--    R  S |   Q+
--   ------+-------
--    0  0 |   Q
--    0  1 |   1
--    1  0 |   0
--    1  1 | interdit




library ieee;
  use ieee.std_logic_1164.all;

entity flipflop_rs is
   port(clk_i    : in     std_logic;
        reset_i  : in     std_logic;  --asynchrone
        R_i      : in     std_logic;  --synchrone
        S_i      : in     std_logic;  --synchrone
        Q_o      : out    std_logic
   );
end flipflop_rs ;


architecture comport of flipflop_rs is
  signal RS_s     : std_logic_vector(1 downto 0);
  signal Q_pres_s : std_logic;
  signal Q_fut_s  : std_logic;

begin
  --Adaptation polarite
  RS_s    <= R_i & S_i;
  with RS_s select
    Q_fut_s <=  Q_pres_s    when "00",
                '1'         when "01",
                '0'         when "10",
                '1'         when "11",
                'X'         when others;
  Q_o <= Q_pres_s;
  
  process(reset_i, clk_i)
  begin
    -- reset the flip flop
    if reset_i= '1' then
        Q_pres_s  <= '0';
    elsif rising_edge(clk_i) then
        Q_pres_s  <= Q_fut_s;
    end if;
  end process;


end comport;
