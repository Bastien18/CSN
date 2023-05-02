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
    signal Q_pres_s, Q_fut_s, add_1_s, sub_1_s, mode_auto_s, mode_manu_s, going_up_s, going_down_s : std_logic_vector(10 downto 0);
    
    signal det_min_s, det_max_s, det_out_range_s, enable_count_s : std_logic;

    signal count_value_s    : unsigned(10 downto 0);

    -- Constant
    constant COUNT_MAX : unsigned(10 downto 0) := "11111001111"; -- unsigned 1999
    constant COUNT_MIN : unsigned(10 downto 0) := "01111100111"; -- unsigned 999
    constant COUNT_MID : unsigned(10 downto 0) := "10111011011"; -- unsigned 1499

begin

    -- TO COMPLETE: Calculate position
    -- Intern signal to enable the flipflop during max Ton of the pwm
    enable_count_s <= top_2ms_i;

    count_value_s   <= unsigned(Q_pres_s);
    add_1_s         <= std_logic_vector(count_value_s + 1);
    sub_1_s         <= std_logic_vector(count_value_s - 1);

    det_max_s       <= '1' when count_value_s = COUNT_MAX else '0';
    det_min_s       <= '1' when count_value_s = COUNT_MIN else '0';
    det_out_range_s <= '1' when (count_value_s < COUNT_MIN OR count_value_s > COUNT_MAX) else '0';

    -- Decoder of futur state
    -- Incremental/decremental signal 
    going_up_s      <=  std_logic_vector(COUNT_MAX) when det_max_s = '1' else
                        add_1_s;

    going_down_s    <=  std_logic_vector(COUNT_MIN) when det_min_s = '1' else 
                        sub_1_s;

    -- Auto mode decomposition
    mode_auto_s     <=  std_logic_vector(COUNT_MIN) when det_max_s = '1' else
                        add_1_s;

    mode_manu_s     <=  going_up_s when up_i = '1' else
                        going_down_s when down_i = '1' else 
                        Q_pres_s;

    Q_fut_s         <=  std_logic_vector(COUNT_MID) when (center_i = '1' OR det_out_range_s = '1') else
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