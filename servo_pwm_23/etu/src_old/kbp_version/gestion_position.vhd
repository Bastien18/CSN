-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : top_gen.vhd
--
-- Description  : G�re le duty cycle du signal PWM en fonction de l'�tat des
--                  entr�es
-- Auteur       : Anthony I. Jaccard
-- Date         : 31.03.2023
-- Version      : 1.0
-- 
-- Utilise      : Laboratoire sur les syst�mes s�quentiels simples
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
    signal reg_pres_s, reg_fut_s : unsigned(position'range);
    signal reg_plus_minus_one_s  : unsigned(position'range);
    signal le_999_s , eq_999_s   : std_logic;
    signal gt_1999_s, eq_1999_s  : std_logic;

    signal sub_carry_s           : std_logic;
    signal cst_one_s             : unsigned(position'range);

    signal center_out_limits_s   : std_logic;
    signal manual_limits_hold_s  : std_logic;
    signal loop_auto_mode_s      : unsigned(position'range);


begin
    sub_carry_s <= down_i and not up_i and not mode_i;
    cst_one_s   <= not to_unsigned(1, cst_one_s'length) when sub_carry_s = '1' else
                   to_unsigned( 1, cst_one_s'length);

    -- Adder that manage the PWM period: [0 and 2000]
	 reg_plus_minus_one_s <= reg_pres_s + cst_one_s;

    -- TO COMPLETE: Calculate position
    center_out_limits_s  <= center_i or le_999_s or gt_1999_s;
    manual_limits_hold_s <= (up_i and eq_1999_s) or (down_i and eq_999_s);

    loop_auto_mode_s <= to_unsigned(999, loop_auto_mode_s'length) when eq_1999_s = '1' else
                        reg_plus_minus_one_s;

    reg_fut_s <= to_unsigned(1499, reg_fut_s'length) when center_out_limits_s = '1'  else
                 loop_auto_mode_s                    when mode_i = '1'               else
                 reg_pres_s                          when manual_limits_hold_s = '1' else
                 reg_plus_minus_one_s;

    -- D Flip-Flop / Register
    process(reset_i, clock_i)
      --
    begin
      if reset_i = '1' then
        reg_pres_s <= (others => '0');
      elsif rising_edge(clock_i) then
		  if top_2ms_i = '1' then
		    reg_pres_s <= reg_fut_s;
		  end if;
      end if;
    end process;
    

    -- TO COMPLETE: Position output
    position <= std_logic_vector(reg_pres_s);

    le_999_s <= '1' when reg_pres_s < 999 else
                '0';
    eq_999_s <= '1' when reg_pres_s = 999 else
                '0';

    gt_1999_s <= '1' when reg_pres_s > 1999 else
                 '0';
    eq_1999_s <= '1' when reg_pres_s = 1999 else
                 '0';

end logic;
