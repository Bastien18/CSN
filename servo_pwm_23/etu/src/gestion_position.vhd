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
    signal Q_pres_s, Q_fut_s, add_1_s, mode_auto_s, mode_manu_s : std_logic_vector(10 downto 0);
    
    signal det_max_s, det_out_range_s, enable_count_s : std_logic;

    signal count_value_s    : integer;

    -- Constant
    constant COUNT_MAX : integer := 1999;
    constant COUNT_MIN : integer := 999;
    constant COUNT_MID : integer := 1499;

begin

    -- TO COMPLETE: Calculate position
    -- Intern signal to enable the flipflop during max Ton of the pwm
    enable_count_s <= top_2ms_i;

    count_value_s   <= to_integer(unsigned(Q_pres_s));
    add_1_s         <= std_logic_vector(to_unsigned(count_value_s + 1, Q_pres_s'length));

    det_max_s       <= '1' when count_value_s = COUNT_MAX else '0';
    det_out_range_s <= '1' when (count_value_s < 999 OR count_value_s > 1999) else '0';

    -- Decoder of futur state
    -- Auto mode decomposition
    mode_auto_s     <=  std_logic_vector(to_unsigned(COUNT_MID, mode_auto_s'length)) when det_out_range_s = '1' else
                        std_logic_vector(to_unsigned(COUNT_MIN, mode_auto_s'length)) when det_max_s = '1' else
                        add_1_s;

    mode_manu_s     <=  std_logic_vector(to_unsigned(COUNT_MAX, mode_manu_s'length)) when up_i = '1' else
                        std_logic_vector(to_unsigned(COUNT_MIN, mode_manu_s'length)) when down_i = '1' else 
                        Q_pres_s;

    Q_fut_s         <=  std_logic_vector(to_unsigned(COUNT_MID, Q_fut_s'length)) when center_i = '1' else
                        mode_auto_s when mode_i = '1' else
                        mode_manu_s;

    -- Process of a enabled flipflop
    process(reset_i, clock_i)
    begin
        -- reset the flip flop
        if reset_i = '1' then
            Q_pres_s  <= (others => '0');
        elsif rising_edge(clock_i) then
            if enable_count_s = '1' then
                Q_pres_s  <= Q_fut_s;
            end if;
        end if;
  
    end process;

    -- TO COMPLETE: Position output
    position <= Q_pres_s;

end logic;