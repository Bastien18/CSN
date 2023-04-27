-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : top_gen.vhd
--
-- Description  : G�n�re le signal PWM � partir du duty cycle (seuil) en entr�e
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

entity pwm is
    port (
        -- Sync
        clock_i     : in std_logic;
        reset_i     : in std_logic;
        -- Inputs
        top_1MHz_i  : in std_logic;
        seuil_i     : in std_logic_vector(14 downto 0);
        -- Outputs
        pwm_o       : out std_logic
    );
end entity pwm;

architecture comp of pwm is
    -- Signals declaration
    signal Q_pres_s, Q_fut_s, add_1_s      : std_logic_vector(14 downto 0);
    signal enable_count_s                  : std_logic;

    signal count_value_s                   : integer;
    signal seuil_value_s                   : integer;

    -- Constant
    constant COUNT_MAX : integer := 19999;

begin

    -- TO COMPLETE: Sawtooth counter generation
    -- Intern signal to enable the register at 1MHz
    enable_count_s <= top_1MHz_i;

    -- Intern signal which make it easier to deal with the counter value
    count_value_s  <= to_integer(unsigned(Q_pres_s));
    add_1_s        <= std_logic_vector(to_unsigned(count_value_s + 1, Q_pres_s'length));

    -- Decoder of futur state
    Q_fut_s        <=   (others => '0') when count_value_s = COUNT_MAX else 
                        add_1_s;

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

    -- TO COMPLETE: PWM signal generation and output
    seuil_value_s <= to_integer(unsigned(seuil_i));
    pwm_o         <= '1' when count_value_s < seuil_value_s else '0';
    

end architecture;