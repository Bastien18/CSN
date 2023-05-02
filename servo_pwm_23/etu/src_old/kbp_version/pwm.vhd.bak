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
        seuil_i     : in std_logic_vector(14 downto 0); -- range: [0, 2000]
        -- Outputs
        pwm_o       : out std_logic
    );
end entity pwm;

architecture comp of pwm is
    -- TO COMPLETE: Signals declaration
    --| Signals |---------------------------------------------------------------
    -- Period counter with range [0, 20000] <=> 15bits needed
    signal cpt_period_reg_pres_s : std_logic_vector(14 downto 0);
    signal cpt_period_reg_fut_s  : std_logic_vector(14 downto 0);
    signal cpt_period_add_out_s  : std_logic_vector(14 downto 0);

    signal pwm_s                 : std_logic;    

  --| Components |------------------------------------------------------------
  component addn is
    generic (N : positive range 1 to 31 := 15);
    port (nbr_a_i   : in  std_logic_vector(N-1 downto 0);
          nbr_b_i   : in  std_logic_vector(N-1 downto 0);
          cin_i     : in  std_logic;
          somme_o   : out std_logic_vector(N-1 downto 0);
          cout_o    : out std_logic
    );
  end component;
  for all : addn use entity work.addn(flot_don);

begin
    -- TO COMPLETE: Sawtooth counter generation
    --| Components instanciation |----------------------------------------------
    -- Adder that manage the PWM period: [0 and 20000]
    period_adder : addn
      generic map(N => 15)
      port map(nbr_a_i => cpt_period_reg_pres_s,
               nbr_b_i => (0 => '1', others => '0'),
               cin_i   => '0',
               somme_o => cpt_period_add_out_s,
               cout_o  => open
      );

     -- Hold current value when top 1MHz ("enable" like) is down
     -- Add1 or Loop period's counter otherwise
    cpt_period_reg_fut_s <= cpt_period_reg_pres_s when top_1MHz_i = '0' else
                            cpt_period_add_out_s  when unsigned(cpt_period_reg_pres_s) < 20000 else
                            (others => '0');

    -- D Flip-Flop / Register
    process(reset_i, clock_i)
      --
    begin
      if reset_i = '1' then
        cpt_period_reg_pres_s <= (others => '0');
      elsif rising_edge(clock_i) then
        cpt_period_reg_pres_s <= cpt_period_reg_fut_s;
      end if;
    end process;

    -- TO COMPLETE: PWM signal generation and output
    -- Comparator 
    -- Variant1: Compare directly period counter with threshold
    pwm_s <= '1' when unsigned(cpt_period_reg_pres_s) <= unsigned(seuil_i) else
             '0';
    -- Variant2: First comparison with cpt_period > 20'000
    --           and then compare specific range with threshold
    --pwm_s <= '0' when unsigned(cpt_period_reg_pres_s)              >= 2000                           else
    --         '0' when unsigned(cpt_period_reg_pres_s(10 downto 0)) >  unsigned(seuil_i(10 downto 0)) else
    --         '1';
    
    pwm_o <= pwm_s;

end architecture;
