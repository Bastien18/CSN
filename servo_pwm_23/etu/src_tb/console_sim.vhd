-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : console_sim.vhd
--
-- Description  : Ce fichier permet l'utilisation de la console generique du REDS.
-- 
-- Auteur       : Gilles Habegger
-- Date         : 20.04.2015
-- 
-- Utilise      : -
-- 
--| Modifications |------------------------------------------------------------
-- Version   	Auteur 	Date              Description
-- 0.0			 	GHR			20.04.2015				Premiere version de console_sim
--  
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;

entity console_sim is
  port(
    -- 16 switchs
    S0_sti       : in     std_logic;
    S1_sti       : in     std_logic;
    S2_sti       : in     std_logic;
    S3_sti       : in     std_logic;
    S4_sti       : in     std_logic;
    S5_sti       : in     std_logic;
    S6_sti       : in     std_logic;
    S7_sti       : in     std_logic;
    S8_sti       : in     std_logic;
    S9_sti       : in     std_logic;
    S10_sti      : in     std_logic;
    S11_sti      : in     std_logic;
    S12_sti      : in     std_logic;
    S13_sti      : in     std_logic;
    S14_sti      : in     std_logic;
    S15_sti      : in     std_logic;
    -- 2 valeurs sur 16 bits
    Val_A_sti    : in     std_logic_vector (15 downto 0);
    Val_B_sti    : in     std_logic_vector (15 downto 0);
    -- 16 LEDs
    L0_obs       : out    std_logic;
    L1_obs       : out    std_logic;
    L2_obs       : out    std_logic;
    L3_obs       : out    std_logic;
    L4_obs       : out    std_logic;
    L5_obs       : out    std_logic;
    L6_obs       : out    std_logic;
    L7_obs       : out    std_logic;
    L8_obs       : out    std_logic;
    L9_obs       : out    std_logic;
    L10_obs      : out    std_logic;
    L11_obs      : out    std_logic;
    L12_obs      : out    std_logic;
    L13_obs      : out    std_logic;
    L14_obs      : out    std_logic;
    L15_obs      : out    std_logic;
    -- 2 valeurs hexadecimales
    Hex0_obs     : out    Std_Logic_Vector ( 3 downto 0);
    Hex1_obs     : out    Std_Logic_Vector ( 3 downto 0);
    -- 2 resultats sur 16 bits
    Result_A_obs : out    std_logic_vector (15 downto 0);
    Result_B_obs : out    std_logic_vector (15 downto 0);
    -- 1 affichage 7 segments
    -- seg7_obs(0) -> DP (pas present)
    -- seg7_obs(1) -> G
    -- seg7_obs(2) -> F
    -- seg7_obs(3) -> E
    -- seg7_obs(4) -> D
    -- seg7_obs(5) -> C
    -- seg7_obs(6) -> B
    -- seg7_obs(7) -> A
    seg7_obs     : out    std_logic_vector ( 7 downto 0)
  );
end console_sim ;

architecture struct of console_sim is

  constant PERIODE : time := 100 ns;

  signal clock_s : std_logic := '0';

  component servo_pwm_top is
    port (
        -- Inputs
        down_i      : in std_logic;
        up_i        : in std_logic;
        mode_i      : in std_logic;
        center_i    : in std_logic;
        -- Outputs
        pwm_o       : out std_logic;
        top_2ms     : out std_logic;
        --Sync
        clock_i     : in std_logic;
        nReset_i    : in std_logic
    );
  end component servo_pwm_top;
  for all : servo_pwm_top use entity work.servo_pwm_top;
  
begin

  ----------------------------------------------------------------------------------
    --Process de generation de l'horloge de la console REDS
    process
    begin
        clock_s <= '0',  '1' after PERIODE/2;
        wait for PERIODE;
    end process;

  -- Instanciation du composant a simuler
  UUT: servo_pwm_top
  port map (
      down_i      => S0_sti,
      up_i        => S1_sti,
      mode_i      => S2_sti,
      center_i    => S3_sti,
      pwm_o       => open,
      top_2ms     => open,
      clock_i     => clock_s,
      nReset_i    => S15_sti
  );   

  
end struct;