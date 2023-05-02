-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : top_gen.vhd
--
-- Description  : G�n�re un pulse d'un tick avec une p�riode renseign�e dans 
--                  le param�tre g�n�rique
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

entity servo_pwm_top is
    generic (
        TEST_SPEED_FAC : integer range 1 to 30 := 1
    );
    port (
        --Sync
        clock_i     : in std_logic;
        nReset_i    : in std_logic;
        -- Inputs
        down_i      : in std_logic;
        up_i        : in std_logic;
        mode_i      : in std_logic;
        center_i    : in std_logic;
        -- Outputs
        pwm_o       : out std_logic;
        --top_2ms_o   : out std_logic
        top_2ms     : out std_logic
    );
end entity servo_pwm_top;

architecture struct of servo_pwm_top is

    component top_gen is
        generic (
            PERIOD : integer range 1 to 1073741824 -- Limit counter size to 30 bits
        );
        port (
            --Sync
            clock_i     : in std_logic;
            reset_i     : in std_logic;
            --Inputs
            en_i  : in std_logic;
            --Outputs
            top_o   : out std_logic
        );
    end component top_gen;
    for all : top_gen use entity work.top_gen(calc);

    component gestion_position is
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
    end component gestion_position;
    for all : gestion_position use entity work.gestion_position(logic);

    component pwm is
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
    end component pwm;
    for all : pwm use entity work.pwm(comp);

    signal top_1MHz_s, top_2ms_s, reset_s   : std_logic;
    signal pos_s        : std_logic_vector(10 downto 0);
    signal pos_ext_s    : std_logic_vector(14 downto 0);

begin

    gen_top_1MHz: top_gen
        generic map (
            PERIOD => 30 / TEST_SPEED_FAC
        )
        port map (
            en_i => '1',
            top_o  => top_1MHz_s,
            clock_i     => clock_i,
            reset_i     => reset_s
        );

    gen_top_2ms: top_gen
    generic map (
        PERIOD => 2000
    )
    port map (
        en_i => top_1MHz_s,
        top_o  => top_2ms_s,
        clock_i     => clock_i,
        reset_i     => reset_s
    );
    
    gest_pos: gestion_position
        port map (
            down_i      => down_i,
            up_i        => up_i,
            mode_i      => mode_i,
            center_i    => center_i,
            top_2ms_i   => top_2ms_s,
            position    => pos_s,
            clock_i     => clock_i,
            reset_i     => reset_s
        );

    pwm_inst: pwm
        port map (
            top_1MHz_i  => top_1MHz_s,
            seuil_i     => pos_ext_s,
            pwm_o       => pwm_o,
            clock_i     => clock_i,
            reset_i     => reset_s
        );

    reset_s <= not(nReset_i);

    pos_ext_s(pos_s'range) <= pos_s(pos_s'range);
    pos_ext_s(pos_ext_s'left downto pos_s'length) <= (others => '0');

    --top_2ms_o <= top_2ms_s;
    top_2ms <= top_2ms_s;

end architecture;