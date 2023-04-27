-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- Institut REDS
--
-- Fichier :  exo_dec_adr_process.vhd
-- Auteur  :  E. Messerli
-- Date    :  31.03.2019, nouvelle version exercice
--
-- Utilise dans :  Exercice description système combinatoire avec process
-----------------------------------------------------------------------
-- Ver  Date        Qui                  Commentaires
-- 1.0  30.03.2023  Bastien Pillonel     Solution
--
-----------------------------------------------------------------------

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.numeric_std.all;

entity exo_dec_adr_process is
port(adr_i            : in  std_logic_vector(15 downto 0);
     cs_rom_o         : out  std_logic;
     cs_ram_o         : out  std_logic;
     cs_flash_o       : out  std_logic;
     cs_io_o          : out  std_logic;
     cs_leds_o        : out  std_logic;
     cs_switch_o      : out  std_logic;
     cs_matrice_led_o : out  std_logic;
     cs_capt_analog_o : out  std_logic;
     cs_cmd_moteur_o  : out  std_logic
     );
end Exo_Dec_adr_process ;

architecture flot_don of exo_dec_adr_process is

-- internal signals
    signal adr_msNibble_s : std_logic_vector(3 downto 0);
    signal adr_secondNibble_s : std_logic_vector(3 downto 0);
    signal adr_thirdNibble_s : std_logic_vector(3 downto 0);
  
begin

  -- internal signal affectation
  adr_msNibble_s <= adr_i(15 downto 12);
  adr_secondNibble_s <= adr_i(7 downto 4);
  adr_thirdNibble_s <= adr_i(11 downto 8);
  
  process(adr_i, adr_msNibble_s, adr_secondNibble_s, adr_thirdNibble_s)
    
  begin
 
     --valeur par defaut
     --   desactive tous les chips select
     cs_rom_o           <= '0';
     cs_ram_o           <= '0';
     cs_flash_o         <= '0';
     cs_io_o            <= '0';
     cs_leds_o          <= '0';
     cs_switch_o        <= '0';
     cs_matrice_led_o   <= '0';
     cs_capt_analog_o   <= '0';
     cs_cmd_moteur_o    <= '0';
     
    -- ======================================= memory case ======================================
    case adr_msNibble_s is
      when x"0"                         => cs_rom_o     <= '1';     -- ROM
      when x"1"|x"2"|x"3"|x"4"          => null;                    -- libre
      when x"5"|x"6"|x"7"               => cs_ram_o     <= '1';     -- ram
      when x"8"|x"9"                    => cs_flash_o   <= '1';     -- flash
      when x"A"|x"B"|x"C"|x"D"|x"E"     => null;                    -- libre
      
      -- ======================================= ios case =======================================
      when x"f"  => cs_io_o  <= '1'; 
        case to_integer(unsigned(adr_thirdNibble_s)) is 
            -- First ios zone
            when 0   => 
                case adr_secondNibble_s is
                    when x"0"                           => cs_leds_o        <= '1';     -- leds
                    when x"1"                           => cs_switch_o      <= '1';     -- switch
                    when x"2"|x"3"                      => cs_matrice_led_o <= '1';     -- matrice led
                    when x"4"|x"5"|x"6"|x"7"|x"8"|x"9"  => null;                        -- libre
                    when x"A"|x"B"                      => cs_capt_analog_o <= '1';     -- capteur analogique
                    when x"C"|x"D"                      => cs_cmd_moteur_o  <= '1';     -- motor command
                    when x"E"|x"F"                      => null;                        -- libre
                    when others                         => --cas pour simulation
                                                            cs_rom_o    <= 'X';
                                                            cs_ram_o   <= 'X';
                                                            cs_flash_o   <= 'X';
                                                            cs_io_o     <= 'X';
                                                            cs_leds_o        <= 'X';
                                                            cs_switch_o      <= 'X'; 
                                                            cs_matrice_led_o <= 'X';
                                                            cs_capt_analog_o <= 'X';
                                                            cs_cmd_moteur_o  <= 'X';                       
                end case;
            -- last free zone in ios
            when 1 to 15    => null; 
            when others     => --cas pour simulation
                                cs_rom_o    <= 'X';
                                cs_ram_o   <= 'X';
                                cs_flash_o   <= 'X';
                                cs_io_o     <= 'X';
                                cs_leds_o        <= 'X';
                                cs_switch_o      <= 'X'; 
                                cs_matrice_led_o <= 'X';
                                cs_capt_analog_o <= 'X';
                                cs_cmd_moteur_o  <= 'X';  
                
        end case;
      
      when others => --cas pour simulation
                      cs_rom_o    <= 'X';
                      cs_ram_o   <= 'X';
                      cs_flash_o   <= 'X';
                      cs_io_o     <= 'X';
                      cs_leds_o        <= 'X';
                      cs_switch_o      <= 'X'; 
                      cs_matrice_led_o <= 'X';
                      cs_capt_analog_o <= 'X';
                      cs_cmd_moteur_o  <= 'X';
      end case;
  
  end process;
  
end flot_don;

