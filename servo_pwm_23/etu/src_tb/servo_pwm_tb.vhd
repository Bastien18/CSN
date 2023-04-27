-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- Institut REDS
--
-- Fichier :  servo_pwm_tb.vhd
-- Auteur  :  A.I. Jaccard
-- Date    :  08.04.2022
--
-- Utilise dans :  Laboratoire systeme sequentiel, cours CSN/Syslog2
-----------------------------------------------------------------------
-- Description : 
--   Test-bench du Generateur de signal PWM 3 canaux RGB, version 2022
--  
-----------------------------------------------------------------------
-- Ver      Date        Qui     Commentaires
-- 1.0      08.04.2022  PPC     Version initiale
-----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.float_pkg.all;

entity servo_pwm_tb is

end servo_pwm_tb;

------------------------------------------------------------------------
-- Architecture du testbench VHDL 
------------------------------------------------------------------------

architecture test_bench of servo_pwm_tb is

    component servo_pwm_top is
    generic (
        TEST_SPEED_FAC : integer range 1 to 30 := 1
    );
    port( 
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
    end component;
    for all : servo_pwm_top use entity work.servo_pwm_top(struct);
            
    -- Constantes
    constant TOP_SPEED_FAC      : integer := 30;
    constant PERIODE    	    : time := 33 ns;  --30 MHz
    constant PERIODE_PWM        : time := 20 ms / TOP_SPEED_FAC;  --50 Hz
    constant PWM_CYCLE_REF_MIN  : time := 18 ms / TOP_SPEED_FAC;
    constant PWM_CYCLE_REF_MAX  : time := 22 ms / TOP_SPEED_FAC;
    constant PERIOD_TOP_MIN     : time := 1.96 ms / TOP_SPEED_FAC;
    constant PERIOD_TOP_MAX     : time := 2.04 ms / TOP_SPEED_FAC;
    constant TIME_OUT_FREQ_PWM  : time := 20*3 ms;
    constant NB_VERIF_CYCLES    : natural := 10;
    constant PWM_FULLY_ON_VAL   : natural := 20000;
    
    -- Signaux
    signal   clock_s    	: std_logic := '0';
    signal   nReset_s       : std_logic;
    signal   reset_s        : std_logic;
    signal   valid_s        : boolean;

    -- signal zero
    signal zero_s   : integer range 0 to 3 := 0;
  
    -- signal pour la gestion de la fin de simulation
    signal sim_end_s  : boolean := false;

    -- compteur d'erreurs
    shared variable nbr_err_v : Natural;

    --signaux de stimulis
    type stimulus_t is record
        down_i      : std_logic;
        up_i        : std_logic;
        mode_i      : std_logic;
        center_i    : std_logic;
    end record;

    --signaux d'observation 
    type observed_t is record
        pwm_o       : std_logic;
        top_2ms     : std_logic;
    end record;

    --signaux de reference
    type reference_t is record
        curr_duty   : integer range 0 to PWM_FULLY_ON_VAL;
    end record;

    signal stimulus_sti  : stimulus_t;
    signal observed_obs  : observed_t;
    signal reference_ref   : reference_t;

    -- flags servant a� la desactivation de la verification
    signal skip_verif_top_s : std_logic;
    signal skip_verif_pwm_s : std_logic;

    -- Procedures
    ----------------------------------------------------------------------------------
    -- Procedure permettant de calculer le temps passe a� l'etat haut du signal PWM  --
    -- en fonction de l'intensite lumineuse demandee (sur 4 bits)                   --
    ----------------------------------------------------------------------------------
    procedure duty_val_to_time( signal duty_val         : in integer range 0 to PWM_FULLY_ON_VAL;
                                constant pwm_period       : in time;
                                variable time_high_min  : out time;
                                variable time_high_max  : out time) is
        variable time_step      : time;
    begin
        time_step := pwm_period / PWM_FULLY_ON_VAL;
        time_high_min := (2 * duty_val - 1) * time_step / 2;
        time_high_max := (2 * duty_val + 1) * time_step / 2;
    end duty_val_to_time;

    ----------------------------------------------------------------------------------
    -- Procedure de verification de la frequence d'un signal                      --
    ----------------------------------------------------------------------------------
    procedure check_frequency(signal usr_signal     : in std_logic;
                              constant period_min   : in time;
                              constant period_max   : in time;
                              signal end_loop       : in boolean;
                              constant signal_name  : in string;
                              signal valid          : in boolean;
                              signal skip_verif     : in std_logic
                              ) is
        variable prev_time_v : time;
        variable cycle_v : time;
    begin
        -- Acquisition du temps du premier flanc montant
        wait for 2 ns;
        wait until rising_edge(usr_signal) for TIME_OUT_FREQ_PWM;
        prev_time_v := now;

        while not end_loop loop
            wait until rising_edge(usr_signal) for TIME_OUT_FREQ_PWM;

            if rising_edge(usr_signal) then
                if(skip_verif = '0' and end_loop = false) then
                    cycle_v := now - prev_time_v;
                        if (cycle_v <= period_min) or (cycle_v >= period_max)  then
                            report ">>>ERROR incorrect freq on " & signal_name &": expected between " 
                            & time'image(period_min) & " and " 
                            & time'image(period_max) & " but got " 
                            & time'image(cycle_v)
                            severity ERROR;
                        nbr_err_v := nbr_err_v + 1;
                    end if;
                end if;
                prev_time_v := now;

            else  -- time_out !!
                if (end_loop = false) and (valid = true) then
                    report ">>>ERROR FATAL: No response detected on " & signal_name & " , period longer than PWM_CYCLE_REF_MAX"
                        severity FAILURE;
                end if;
            end if;
        end loop;
    end check_frequency;

    ----------------------------------------------------------------------------------
    -- Procedure de verification du temps passe a� l'etat haut d'un signal PWM      --
    ----------------------------------------------------------------------------------
    procedure check_duty(signal usr_signal      : in std_logic;
                         signal end_loop        : in boolean;
                         constant signal_name   : in string;
                         signal curr_duty       : in integer range 0 to PWM_FULLY_ON_VAL;
                         signal skip_verif      : in std_logic
                        ) is
        variable pwm_rise_time_v : time;
        variable pwm_high_time_v : time;
        variable ref_high_time_max_v : time;
        variable ref_high_time_min_v : time;
    begin
        wait for 2 ns;
 
        while not end_loop loop
           
            wait until rising_edge(usr_signal) for TIME_OUT_FREQ_PWM;
            
            if rising_edge(usr_signal) then
                if(skip_verif = '0' and end_loop = false) then
                    pwm_rise_time_v := now; -- mesure du temps de montee

                    wait until falling_edge(usr_signal) for TIME_OUT_FREQ_PWM;
                    if(skip_verif = '0' and falling_edge(usr_signal)) then
            
                        pwm_high_time_v := now - pwm_rise_time_v; -- mesure du temps passe a� l'etat actif
                        duty_val_to_time(curr_duty, PERIODE_PWM, ref_high_time_min_v, ref_high_time_max_v);

                        -- comparaison du temps actif avec les valeurs de reference
                        if ((pwm_high_time_v <= ref_high_time_min_v) or (pwm_high_time_v >= ref_high_time_max_v)) then
                            report ">>>ERROR in " & signal_name &" PWM duty cycle: expected between " 
                                & time'image(ref_high_time_min_v) & " and " 
                                & time'image(ref_high_time_max_v) & " but got " 
                                & time'image(pwm_high_time_v) --& integer'image(cycle_v)
                                severity ERROR;
                            nbr_err_v := nbr_err_v + 1;
                        end if;
                    end if;
                end if;
            end if;

        end loop;--while
    end check_duty;



    ----------------------------------------------------------------------------------
    -- Procedure permettant plusieurs cycles d'horloge. Le premier appel de la      --
    -- procedure termine le cycle precedent si celui-ci n'etait pas complet (par    --
    -- exemple : si on a fait quelques pas de simulation non synchronises avant,    --
    -- reset asynchrone, combinatoire, ...).                                        --
    ----------------------------------------------------------------------------------
    procedure cycle (nombre_de_cycles : Integer := 1) is
        begin
        for i in 1 to nombre_de_cycles loop
            wait until falling_edge(clock_s);
            wait for 2 ns; --assigne stimuli 2ns apres flanc montant 
        end loop;
    end cycle;



    ----------------------------------------------------------------------------------
    --------------------------- DEFINITION DES TESTCASES -----------------------------
    ----------------------------------------------------------------------------------

    ----------------------------------------------------------------------------------
    -- Testcase upanddown : Le signal PWM passe par tous les �tats de contr�le du   --
    -- servo � partir du centre vers le maximum avant de redescendre jusqu'au
    -- minimum puis de remonter jusqu'au centre
    ----------------------------------------------------------------------------------
    procedure testcase_upanddown(signal synchro : in std_logic;
                              signal stimulus : out stimulus_t;
                              signal reference : inout reference_t) is

        variable stimulus_v  : stimulus_t;
        variable reference_v : reference_t;

    begin

        stimulus_v.up_i := '0';
        stimulus_v.down_i := '0';
        stimulus_v.center_i := '0';
        stimulus_v.mode_i := '0';

        -- Attendre que le servo soit centre
        stimulus_v.center_i := '1';
        stimulus <= stimulus_v;
        wait until falling_edge(synchro);
        reference_v.curr_duty := 1500;
        reference<= reference_v;
        for i in 1 to 9 loop
            wait until falling_edge(synchro);
        end loop;

        -- Monter jusqu'au maximum 
        stimulus_v.center_i := '0';
        for i in 1 to 500 loop
            stimulus_v.up_i := '1';
            stimulus <= stimulus_v;
            wait until falling_edge(synchro);
            stimulus_v.up_i := '0';
            stimulus <= stimulus_v;
            reference_v.curr_duty := reference_v.curr_duty + 1;
            reference <= reference_v; 
            for i in 1 to 9 loop
                wait until falling_edge(synchro);
            end loop;
        end loop;

        -- Descendre jusqu'au minimum
        stimulus_v.center_i := '0';
        for i in 1 to 1000 loop
            stimulus_v.down_i := '1';
            stimulus <= stimulus_v;
            wait until falling_edge(synchro);
            stimulus_v.down_i := '0';
            stimulus <= stimulus_v;
            reference_v.curr_duty := reference_v.curr_duty - 1;
            reference <= reference_v; 
            for i in 1 to 9 loop
                wait until falling_edge(synchro);
            end loop;
        end loop;

        -- Revenir a la position centree
        stimulus_v.center_i := '0';
        for i in 1 to 500 loop
            stimulus_v.up_i := '1';
            stimulus <= stimulus_v;
            wait until falling_edge(synchro);
            stimulus_v.up_i := '0';
            stimulus <= stimulus_v;
            reference_v.curr_duty := reference_v.curr_duty + 1;
            reference <= reference_v; 
            for i in 1 to 9 loop
                wait until falling_edge(synchro);
            end loop;
        end loop;
        
    end testcase_upanddown;


    ----------------------------------------------------------------------------------
    -- Testcase tocenter : G�n�re un signal pour remettre le servo � sa position    --
    -- centrale. Il diverge ensuite de plus en plus vers le minimum/maximum avant
    -- d'�tre ramen� au centre
    ----------------------------------------------------------------------------------
    procedure testcase_tocenter(signal synchro : in std_logic;
                              signal stimulus : out stimulus_t;
                              signal reference : inout reference_t;
                              signal skip_verif : out std_logic) is

        variable stimulus_v  : stimulus_t;
        variable reference_v : reference_t;

    begin  

        stimulus_v.up_i := '0';
        stimulus_v.down_i := '0';
        stimulus_v.center_i := '0';
        stimulus_v.mode_i := '0';

        for steps in 1 to 50 loop
            for up_nDown in 0 to 1 loop
                -- Send to center and check
                stimulus_v.center_i := '1';
                stimulus <= stimulus_v;
                wait until falling_edge(synchro);
                reference_v.curr_duty := 1500;
                reference <= reference_v;
                for i in 1 to 9 loop
                    wait until falling_edge(synchro);
                end loop;

                -- Disable check and increase/decrease duty cycle
                skip_verif <= '1';
                stimulus_v.center_i := '0';
                if up_nDown = 0 then
                    stimulus_v.up_i := '0';
                    stimulus_v.down_i := '1';
                else
                    stimulus_v.up_i := '1';
                    stimulus_v.down_i := '0';
                end if;
                stimulus <= stimulus_v;
                for i in 1 to 10 * steps loop
                    wait until falling_edge(synchro);
                    if up_nDown = 0 then
                        reference_v.curr_duty := reference_v.curr_duty - 1;
                    else
                        reference_v.curr_duty := reference_v.curr_duty + 1;
                    end if;
                end loop;
                reference <= reference_v;
                stimulus_v.up_i := '0';
                stimulus_v.down_i := '0';
                stimulus <= stimulus_v;
                
                -- Enable check and wait for PWM period
                skip_verif <= '0';
                for i in 0 to 10 loop
                    wait until falling_edge(synchro);
                end loop;

            end loop;
        end loop;
        
    end testcase_tocenter;

    ----------------------------------------------------------------------------------
    -- Testcase automode : V�rification du mode auto de la gestion de position.     --
    -- Dans ce mode, le servo devrait partir de sa position minimale, monter 
    -- progressivement vers sa position maximale puis retourner directement � sa 
    -- position minimale
    ----------------------------------------------------------------------------------
    procedure testcase_automode(signal synchro : in std_logic;
                              signal stimulus : out stimulus_t;
                              signal reference : out reference_t) is

        variable stimulus_v  : stimulus_t;
        variable reference_v : reference_t;

    begin 

        stimulus_v.up_i := '0';
        stimulus_v.down_i := '0';
        stimulus_v.center_i := '0';
        stimulus_v.mode_i := '0';

        -- Send to center and check
        stimulus_v.center_i := '1';
        stimulus <= stimulus_v;
        wait until falling_edge(synchro);
        reference_v.curr_duty := 1500;
        reference <= reference_v;
        for i in 1 to 9 loop
            wait until falling_edge(synchro);
        end loop;

        -- Start auto-mode
        stimulus_v.mode_i := '1';
        stimulus <= stimulus_v;

        -- Center enabled: should stay centered
        for i in 1 to 10 loop
            wait until falling_edge(synchro);
        end loop;

        -- Disable center hold
        stimulus_v.center_i := '0';
        stimulus <= stimulus_v;

        for i in 1 to 500 loop
            wait until falling_edge(synchro);
            reference_v.curr_duty := reference_v.curr_duty + 1; 
            reference <= reference_v;
        end loop;

        -- Top reached, going back to bottom
        wait until falling_edge(synchro);
        reference_v.curr_duty := 1000;
        reference <= reference_v;
        for i in 1 to 1000 loop
            wait until falling_edge(synchro);
            reference_v.curr_duty := reference_v.curr_duty + 1; 
            reference <= reference_v;
        end loop;

        -- Top reached, going back to center
        stimulus_v.center_i := '1';
        stimulus <= stimulus_v;
        wait until falling_edge(synchro);
        reference_v.curr_duty := 1500;
        reference <= reference_v;
        for i in 1 to 9 loop
            wait until falling_edge(synchro);
        end loop;

        -- Disable auto mode
        stimulus_v.mode_i := '0';
        stimulus_v.center_i := '0';
        stimulus <= stimulus_v;

    end testcase_automode;
    
    ----------------------------------------------------------------------------------
    -- Testcase errors : Test des valeurs limites pour v�rifier que le syst�me de   --
    -- G�n�re pas de pulse plus petites que 1ms et plus grande que 2ms lorsqu'on 
    -- continue � modifier la valeur aux extr�mes
    ----------------------------------------------------------------------------------
    procedure testcase_errors(signal synchro : in std_logic;
                             signal stimulus : out stimulus_t;
                             signal reference : inout reference_t;
                             signal skip_verif : out std_logic) is

        variable stimulus_v  : stimulus_t;
        variable reference_v : reference_t;

    begin  
        
        stimulus_v.up_i := '0';
        stimulus_v.down_i := '0';
        stimulus_v.center_i := '0';
        stimulus_v.mode_i := '0';

        -- Attendre que le servo soit centre
        stimulus_v.center_i := '1';
        stimulus <= stimulus_v;
        wait until falling_edge(synchro);
        reference_v.curr_duty := 1500;
        reference<= reference_v;
        stimulus_v.center_i := '0';
        stimulus <= stimulus_v;
        for i in 1 to 9 loop
            wait until falling_edge(synchro);
        end loop;

        -- Monter jusqu'au maximum
        skip_verif <= '1';
        stimulus_v.up_i := '1';
        stimulus <= stimulus_v;
        for i in 1 to 500 loop
            wait until falling_edge(synchro);
            reference_v.curr_duty := reference_v.curr_duty + 1;
        end loop;
        reference <= reference_v;
        skip_verif <= '0';

        -- Tester saturation du maximum
        for i in 1 to 20 loop
            wait until falling_edge(synchro);
        end loop;

        -- Descendre jusqu'au minimum
        skip_verif <= '1';
        stimulus_v.up_i := '0';
        stimulus_v.down_i := '1';
        stimulus <= stimulus_v;
        for i in 1 to 1000 loop
            wait until falling_edge(synchro);
            reference_v.curr_duty := reference_v.curr_duty - 1;
        end loop;
        reference <= reference_v;
        skip_verif <= '0';

        -- Tester saturation du minimum
        for i in 1 to 20 loop
            wait until falling_edge(synchro);
        end loop;

    end testcase_errors;

begin
    -- Adaptation polarite
    nReset_s <= not reset_s;

    --------------------------------------------------------------------------
    --Process de generation de l'horloge
    --------------------------------------------------------------------------
    --Clock_sti <= clock_s;
    clock_proc : process
    begin
        while not sim_end_s loop
        clock_s <= '0','1' after PERIODE/2;	
        wait for PERIODE;
        end loop;
        wait;
    end process;

    ---------------------------------------------------------------------------
    -- Interconnexion du module VHDL a simuler, DUV=Device Under Verification
    ---------------------------------------------------------------------------
    dut: servo_pwm_top
    generic map (
        TEST_SPEED_FAC => TOP_SPEED_FAC
    )
    port map (
        down_i      => stimulus_sti.down_i,
        up_i        => stimulus_sti.up_i,
        mode_i      => stimulus_sti.mode_i,
        center_i    => stimulus_sti.center_i,
        pwm_o       => observed_obs.pwm_o,
        top_2ms     => observed_obs.top_2ms,
        clock_i     => clock_s,
        nReset_i    => nReset_s
    ); 

    ------------------------------------------------------------------------
    -- V�rification de la fr�quence des signaux pwm et top_2ms
    ------------------------------------------------------------------------ 

    valid_s <= true when reference_ref.curr_duty > 0 and reference_ref.curr_duty < PWM_FULLY_ON_VAL else false; 
    check_frequency(observed_obs.pwm_o, 
                    PWM_CYCLE_REF_MIN, 
                    PWM_CYCLE_REF_MAX, 
                    sim_end_s, 
                    "pwm_o",
                    valid_s, 
                    skip_verif_pwm_s);
    check_frequency(observed_obs.top_2ms, 
                    PERIOD_TOP_MIN,
                    PERIOD_TOP_MAX,
                    sim_end_s, 
                    "top_2ms", 
                    valid_s,
                    skip_verif_top_s);

    ------------------------------------------------------------------------
    -- V�rification du rapport cyclique du signal pwm
    ------------------------------------------------------------------------  
    check_duty(observed_obs.pwm_o, 
                sim_end_s, 
                "pwm_o",
                reference_ref.curr_duty, 
                skip_verif_pwm_s);

    ----------------------------------------------------------------------------------
    -- Processus de stimulation du DUV selon les testcases definis                  --
    ----------------------------------------------------------------------------------
    stimulus_proc : process
    begin
        nbr_err_v := 0; --Initialise compteur d'erreur
        skip_verif_top_s <= '1';
        skip_verif_pwm_s <= '1';
        
        report "Debut de la simulation";

        -- Valeurs de stimulis initiales
        stimulus_sti.up_i <= '0';
        stimulus_sti.down_i <= '0';
        stimulus_sti.center_i <= '0';
        stimulus_sti.mode_i <= '0';

        -- Valeurs de reference PWM initiales
        reference_ref.curr_duty <= 1499;

        -- Mise a zero asynchrone
        reset_s <= '1';
        cycle(2);
        reset_s <= '0';

        -- Verification du top_2ms
        skip_verif_top_s <= '0';
        wait for 20 ms / TOP_SPEED_FAC;

        if nbr_err_v = 0 then
            report "top_2ms OK";
            wait until falling_edge(observed_obs.pwm_o);
            skip_verif_pwm_s <= '0';
            wait until rising_edge(observed_obs.pwm_o);
            -- Lancement des testcases
            testcase_upanddown(observed_obs.top_2ms, stimulus_sti, reference_ref);
            report "testcase_upanddown done";
            testcase_tocenter(observed_obs.top_2ms, stimulus_sti, reference_ref, skip_verif_pwm_s);
            report "testcase_tocenter done";
            testcase_automode(observed_obs.top_2ms, stimulus_sti, reference_ref);
            report "testcase_automode done";
            testcase_errors(observed_obs.top_2ms, stimulus_sti, reference_ref, skip_verif_pwm_s);
            report "testcase_errors done";
        end if;

        report "Fin de la simulation";
        
        report "NOMBRE D'ERREURS : " & integer'image(nbr_err_v);

        if nbr_err_v = 0 then
            report "VOUS ETES LES MEILLEURS!!!";
        else
            report "IL FAUT CONTINUER...";
        end if;

        sim_end_s <= true;
        wait; 

    end process; 

end test_bench;