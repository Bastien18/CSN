-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : top_gen.vhd
--
-- Description  : Gère le duty cycle du signal PWM en fonction de l'état des
--                  entrées
-- Auteur       : Anthony I. Jaccard
-- Date         : 31.03.2023
-- Version      : 1.0
-- 
-- Utilise      : Laboratoire sur les systèmes séquentiels simples
-- 
--| Modifications |------------------------------------------------------------
-- Vers.  Qui   Date         Description
-- 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gestion_position is
    port (
        -- Sync
        clock_i     : in std_logic;
        reset_i     : in std_logic;
        -- Inputs
        down_i      : in std_logic;
        up_i        : in std_logic;
        mode_i      : in std_logic;
        top_2ms_i   : in std_logic;
        center_i    : in std_logic;
        -- Outputs
        position    : out std_logic_vector(10 downto 0)
    );
end entity gestion_position;

architecture logic of gestion_position is
    -- TO COMPLETE: Signals declaration
    signal reg_pres_s, reg_fut_s : std_logic_vector(position'range);
    signal reg_plus_one_s        : std_logic_vector(position'range);
    signal lesser_than_999_s  , equal_to_999_s  : std_logic;
    signal greater_than_1999_s, equal_to_1999_s : std_logic;

    signal sub_carry_s           : std_logic;
    signal cst_one_s             : std_logic_vector(position'range);

    signal center_out_limits_s   : std_logic;
    signal manual_limits_hold_s  : std_logic;
    signal tmp_s                 : std_logic_vector(position'range);

    --| Components |------------------------------------------------------------
    component addn is
      generic (N : positive range 1 to 31 := 11);
      port (nbr_a_i   : in  std_logic_vector(N-1 downto 0);
            nbr_b_i   : in  std_logic_vector(N-1 downto 0);
            cin_i     : in  std_logic;
            somme_o   : out std_logic_vector(N-1 downto 0);
            cout_o    : out std_logic
      );
    end component;
    for all : addn use entity work.addn(flot_don);

begin
    --sub_carry_s <= not up_i;
    sub_carry_s <= down_i and not up_i;
    cst_one_s   <= (0 => '0', others => '1') when sub_carry_s = '1' else
                   (0 => '1', others => '0');

    -- Adder that manage the PWM period: [0 and 20000]
    period_adder : addn
      generic map(N => 11)
      port map(nbr_a_i => reg_pres_s,
               nbr_b_i => cst_one_s,
               cin_i   => sub_carry_s,
               somme_o => reg_plus_one_s,
               cout_o  => open
      );

    -- TO COMPLETE: Calculate position
    center_out_limits_s  <= center_i or lesser_than_999_s or greater_than_1999_s;
    manual_limits_hold_s <= (up_i and equal_to_1999_s) or (down_i and equal_to_999_s);

    tmp_s <= std_logic_vector(to_unsigned(999, tmp_s'length)) when equal_to_1999_s = '1' else
             reg_plus_one_s;

    reg_fut_s <= reg_pres_s                       when top_2ms_i = '1'            else
                 std_logic_vector(to_unsigned(1499, reg_fut_s'length)) when center_out_limits_s = '1' else
                 tmp_s                            when mode_i = '1'               else
                 reg_pres_s                       when manual_limits_hold_s = '1' else
                 reg_plus_one_s;

    -- D Flip-Flop / Register
    process(reset_i, clock_i)
      --
    begin
      if reset_i = '1' then
        reg_pres_s <= (others => '0');
      elsif rising_edge(clock_i) then
        reg_pres_s <= reg_fut_s;
      end if;
    end process;
    

    -- TO COMPLETE: Position output
    position <= reg_pres_s;

    lesser_than_999_s <= '1' when unsigned(reg_pres_s) < 999 else
                         '0';
    equal_to_999_s    <= '1' when unsigned(reg_pres_s) = 999 else
                         '0';

    greater_than_1999_s <= '1' when unsigned(reg_pres_s) > 1999 else
                           '0';
    equal_to_1999_s     <= '1' when unsigned(reg_pres_s) = 1999 else
                           '0';

end logic;
