-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : exo_dec_adr_process_tb.vhd
-- Auteur       : E. Messerli
-- Date         : 14.03.2016
-- Version      : 0.0
--
-- Description  : Test bench de exo_dec_adr_process.vhd
--
-- Utilise      : Exercice descritpion combinatoire avec process
--
--| Modifications |-----------------------------------------------------------
-- Ver   Auteur Date         Description
--
------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

library std;
  use std.textio.all; -- For function 'Image'

entity exo_dec_adr_process_tb is

end exo_dec_adr_process_tb ;

architecture test_bench of exo_dec_adr_process_tb is


  component Exo_Dec_adr_process is
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
  end component;
  for all : Exo_Dec_adr_process use entity work.Exo_Dec_adr_process;

  -- les entrees _Sti (valeurs de pour les STImulies)
  signal adr_sti    : std_logic_vector(15 downto 0);
  
  -- les sorties _Obs (valeurs OBServees)
  --             _Ref (valeurs de REFerences)
  signal cs_rom_obs, cs_rom_ref                  : std_logic;
  signal cs_ram_obs, cs_ram_ref                  : std_logic;
  signal cs_flash_obs, cs_flash_ref              : std_logic;
  signal cs_io_obs, cs_io_ref                    : std_logic;
  signal cs_leds_obs, cs_leds_ref                : std_logic;
  signal cs_switch_obs, cs_switch_ref            : std_logic;
  signal cs_matrice_led_obs, cs_matrice_led_ref  : std_logic;
  signal cs_capt_analog_obs, cs_capt_analog_ref  : std_logic;
  signal cs_cmd_moteur_obs, cs_cmd_moteur_ref    : std_logic;
  

  -- signal for the test bench -----------------------------------------
  signal erreur    : std_logic := '0';
  signal nbr_err_s : integer := 0;
  signal fin_sim   : boolean := false ;
  constant PAS_SIM : time := 100 ns ;

  
-------------------------------------------------------------------------- 
begin
   UUT : Exo_Dec_adr_process
      port map (
          adr_i            => adr_sti            ,
          cs_rom_o         => cs_rom_obs         ,
          cs_ram_o         => cs_ram_obs         ,
          cs_flash_o       => cs_flash_obs       ,
          cs_io_o          => cs_io_obs          ,
          cs_leds_o        => cs_leds_obs        ,
          cs_switch_o      => cs_switch_obs      ,
          cs_matrice_led_o => cs_matrice_led_obs ,
          cs_capt_analog_o => cs_capt_analog_obs ,
          cs_cmd_moteur_o  => cs_cmd_moteur_obs 
      );   


      
  -- Generate stimuli


  --Process de generation des stimuli (sti) et reference (ref)
  process 
  
  begin
     -- initialiser les signaux
     fin_sim   <= False;
  
     -- message de debut
     report "debut de simulation " ;
  
    --------------------------------------------------------------------------------
    --Simulation avec les stimuli nbr-non signes donnes par les etudiants TAB_STIMULI_NSGN
    loop_adr: for I in 0 to (2**adr_sti'length)-1 loop
        
        --assignation des adresses
        adr_sti <= std_logic_vector(to_unsigned(I,adr_sti'length));
        
        --Calcul des references
        cs_rom_ref         <= '0';       
        cs_ram_ref         <= '0';      
        cs_flash_ref       <= '0';      
        cs_io_ref          <= '0';        
        cs_leds_ref        <= '0';      
        cs_switch_ref      <= '0';    
        cs_matrice_led_ref <= '0';
        cs_capt_analog_ref <= '0';
        cs_cmd_moteur_ref  <= '0';
        if    (I >=     0) and (I <=  4095) then -- plage 0x0000 a 0x0FFF
           cs_rom_ref   <= '1';      
        elsif (I >=  4096) and (I <= 20479) then -- plage 0x1000 a 0x4FFF
           null;                                 -- zone libre     
        elsif (I >= 20480) and (I <= 32767) then -- plage 0x5000 a 0x7FFF
           cs_ram_ref  <= '1';      
        elsif (I >= 32768) and (I <= 40959) then -- plage 0x8000 a 0x9FFF
           cs_flash_ref  <= '1';      
        elsif (I >= 40960) and (I <= 61439) then -- plage 0xA000 a 0xEFFF
           null;                                 -- zone libre     
        elsif (I >= 61440) and (I <= 65535) then -- plage 0xF000 a 0xFFFF
           cs_io_ref    <= '1';      
           if I <= 61455 then           -- sous-plage 0xF000 a 0xF00F
              cs_leds_ref        <= '1';
           elsif I <= 61471 then        -- sous-plage 0xF010 a 0xF01F
              cs_switch_ref      <= '1';
           elsif I <= 61503 then        -- sous-plage 0xF020 a 0xF03F
              cs_matrice_led_ref <= '1';
           elsif I <= 61599 then        -- sous-plage 0xF040 a 0xF09F
              null;                     --   zone libre
           elsif I <= 61631 then        -- sous-plage 0xF0A0 a 0xF0BF
              cs_capt_analog_ref <= '1';
           elsif I <= 61663 then        -- sous-plage 0xF0C0 a 0xF0DF
              cs_cmd_moteur_ref  <= '1';         
           else                         -- sous-plage 0xF0E0 a 0xFFFF
              null;                     --   zone libre
           end if;
        else
           report " erreur : adresse non valide !! " 
             severity FAILURE;
           
        end if;
        wait for PAS_SIM;
            
    end loop;

 
    --fin de la simulation
    fin_sim <= true;
    
    -- messages de fin
    if (nbr_err_s = 0) then
        report " *** VOUS ETES LES MEILLEURS *** ";
        report " *** BRAVO, pas d'erreur *** ";
    else
        report " *** VOUS AVEZ ENCORE UN PEU DE TRAVAIL, COURAGE *** ";
        report " *** vous avez " & integer'image(nbr_err_s) & " erreur(s) *** ";
    end if ;
    wait ; --stop la simulation
  end process;


  -------------------------------------------------------------------------------
  -- processus de vérification, compare _obs avec _ref
  process
     variable aff_result_v : integer;
     variable nb_erreur_v : natural := 0;
  begin
     while not fin_sim loop
        wait for PAS_SIM/2;
        
        --verification 
        if cs_rom_obs /= cs_rom_ref then
          nb_erreur_v := nb_erreur_v + 1;
           erreur <= '1' , '0' after 10 ns;
           report " erreur pour cs_rom_o " 
             severity ERROR;
        end if ;
        if cs_ram_obs /= cs_ram_ref then
          nb_erreur_v := nb_erreur_v + 1;
           erreur <= '1' , '0' after 10 ns;
           report " erreur pour cs_ram1_o " 
             severity ERROR;
        end if ;
        if cs_flash_obs /= cs_flash_ref then
          nb_erreur_v := nb_erreur_v + 1;
           erreur <= '1' , '0' after 10 ns;
           report " erreur pour cs_ram2_o " 
             severity ERROR;
        end if ;
        if cs_io_obs /= cs_io_ref then
          nb_erreur_v := nb_erreur_v + 1;
           erreur <= '1' , '0' after 10 ns;
           report " erreur pour cs_io_o" 
             severity ERROR;
        end if ;
        if cs_leds_obs /= cs_leds_ref then
          nb_erreur_v := nb_erreur_v + 1;
           erreur <= '1' , '0' after 10 ns;
           report " erreur pour cs_leds_o" 
             severity ERROR;
        end if ;
        if cs_switch_obs /= cs_switch_ref then
          nb_erreur_v := nb_erreur_v + 1;
           erreur <= '1' , '0' after 10 ns;
           report " erreur pour cs_switch_o" 
             severity ERROR;
        end if ;
        if cs_matrice_led_obs /= cs_matrice_led_ref then
          nb_erreur_v := nb_erreur_v + 1;
           erreur <= '1' , '0' after 10 ns;
           report " erreur pour cs_matrice_led_o" 
             severity ERROR;
        end if ;
        if cs_capt_analog_obs /= cs_capt_analog_ref then
          nb_erreur_v := nb_erreur_v + 1;
           erreur <= '1' , '0' after 10 ns;
           report " erreur pour cs_capt_analog_o " 
             severity ERROR;
        end if ;
        if cs_cmd_moteur_obs /= cs_cmd_moteur_ref then
          nb_erreur_v := nb_erreur_v + 1;
           erreur <= '1' , '0' after 10 ns;
           report " erreur pour cs_cmd_moteur_o" 
             severity ERROR;
        end if ;
        
        nbr_err_s <= nb_erreur_v;
        wait for PAS_SIM/2;
     end loop;
     wait;
  end process ;

end test_bench;



