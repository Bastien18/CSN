-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : Top_Sim.vhd
-- Description  : Top_Sim pour utilisation en mode texte (sans HDL Designer)
--
-- Auteur       : E. Messerli
-- Date         : 09.02.2007
-- Version      : 0.0
--
-- Utilise      : Simulation de Test_Gated_Clock.vhd
--
--| Modifications |-----------------------------------------------------------
--  Version   Auteur  Date            Description
--  1.1       YNG     22.10.2007      Mise a jour entete
--  2.0       EMI     21.09.2014      Adaptation pour Console REDS 16 bits
--                                    
------------------------------------------------------------------------------

library IEEE;                   -- Librairie IEEE
  use IEEE.Std_Logic_1164.all;  -- Definition du type standard logic
  --use IEEE.Numeric_Std.all;     -- Definition des opérations arithmétiques

entity console_sim is
   port( 
      --8 switchs (interrupteurs)
      S0_sti       : in     Std_Logic; 
      S1_sti       : in     Std_Logic; 
      S2_sti       : in     Std_Logic; 
      S3_sti       : in     Std_Logic; 
      S4_sti       : in     Std_Logic; 
      S5_sti       : in     std_logic; 
      S6_sti       : in     std_logic; 
      S7_sti       : in     std_logic; 
      S8_sti       : in     std_logic; 
      S9_sti       : in     std_logic; 
      S10_sti       : in     std_logic; 
      S11_sti       : in     std_logic; 
      S12_sti       : in     std_logic; 
      S13_sti       : in     std_logic; 
      S14_sti       : in     std_logic; 
      S15_sti       : in     std_logic; 
     --Valeurs 8 bits Val_A et Val_B
      Val_A_sti    : in     std_logic_vector ( 15 downto 0 );
      Val_B_sti    : in     std_logic_vector ( 15 downto 0 );
      --8 Leds 
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
      L10_obs       : out    std_logic;
      L11_obs       : out    std_logic;
      L12_obs       : out    std_logic;
      L13_obs       : out    std_logic;
      L14_obs       : out    std_logic;
      L15_obs       : out    std_logic;
      --2 Resultats sur 8 bits
      Result_A_obs : out    std_logic_vector ( 15 downto 0 );
      Result_B_obs : out    std_logic_vector ( 15 downto 0 );
      --2 Affichage 7 segments avec valeurs en hexadecimal (4 bits) 
      Hex0_obs     : out    Std_Logic_Vector (3 downto 0);
      Hex1_obs     : out    Std_Logic_Vector (3 downto 0);
      --1 Affichage 7 segments avec un vecteur!
      seg7_obs     : out std_logic_vector (6 downto 0)
   );

end console_sim ;

architecture Struct of console_sim is

  component flipflop_rs is
     port(clk_i    : in     std_logic;
          reset_i  : in     std_logic;
          R_i      : in     std_logic;
          S_i      : in     std_logic;
          Q_o      : out    std_logic
     );
  end component;
  for all : flipflop_rs use entity work.flipflop_rs;

  constant PERIODE    : time := 100 ns;  --periode pour console REDS !
  signal   clock_s    : std_logic := '0';
  
  
begin

----------------------------------------------------------------------------------
--Process de generation de l'horloge
  process
  begin
    clock_s <= '0',  '1' after PERIODE/2;
      wait for PERIODE;
  end process;


-- Affectation signaux (si necessaire)

----------------------------------------------------------------------------------
-- Instanciation du composant a simuler
   UUT : flipflop_rs
      port map (clk_i    => clock_s,
                reset_i  => S15_sti,
                R_i      => S0_sti,
                S_i      => S1_sti,
                Q_o      => L0_obs
      );   

end Struct;




