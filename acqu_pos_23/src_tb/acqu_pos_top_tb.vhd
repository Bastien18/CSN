-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : acqu_pos_top_tb.vhd
--
-- Description  : Banc de test automatique (test bench) pour 
--                acquisition de position acqu_pos_top_tb
-- 
-- Auteur       : Bertrand Rey
-- Date         : 23.12.2016
-- Version      : 0.1
-- 
-- Utilise      : Manipulation de laboratoire du cours CSN
--                Banc de test automatique (test bench) 
-- 
--| Modifications |------------------------------------------------------------
-- Version   Auteur Date               Description
-- 0.1       BRE    23.12.2016         Acceptation si latences diff�rentes pour flancs montants ou descendants
-- 1.0       EMI    30.05.2017         Adaptation pour cours SysLog2 mai 2017
--                                     - ajout 3 periode apres sequence Reset
--                                     - version sans la simulation des oscillations
--                                       lignes 387 423 en commentaires
--
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;
library std;
  use std.textio.all;

entity acqu_pos_top_tb is
end acqu_pos_top_tb ;

architecture testbench of acqu_pos_top_tb is
  --constantes du testbench
  constant CLK_PERIOD : time := 100 ns;  --10 MHz
  constant DELTA_T    : time :=   4 ns;
  constant NB_POS     : integer := 2**16; -- Nb Positions du compteur de position
  constant NB_POS_PAR_INDEX  : integer := 2000; -- Nb de positions entre 2 changements d'index
  constant NUM_POS_INDEX     : integer := 36; -- Position de l'index 
  constant MAX_CYCLE_LATENCE : integer := 20;

  --signaux stimuli
  signal clk_sti       : std_logic;
  signal reset_sti     : std_logic;
  signal init_pos_sti  : std_logic;
  signal capt_a_sti    : std_logic;
  signal capt_b_sti    : std_logic;
  signal capt_idx_sti  : std_logic;
  signal P0_sti        : std_logic;
  
  --signaux mesures
  signal dir_cw_obs    : std_logic;
  signal nbr_idx_obs   : std_logic_vector(9 downto 0);
  signal position_obs  : std_logic_vector(15 downto 0);
  signal det_err_obs   : std_logic;
  signal err_obs       : std_logic;
  signal nbr_err_obs   : std_logic_vector(4 downto 0);
  
  --signaux de reference
 -- signal nbr_idx_ref      : integer := 0;
  signal nbr_idx_sync_ref : integer; --synchronise avec temps de traitement de UUT
  signal position_ref     : integer := 0;
  signal position_sync_ref: integer; --synchronise avec temps de traitement de UUT
  signal dir_cw_ref       : std_logic;
  signal dir_cw_sync_ref  : std_logic; --synchronise avec temps de traitement de UUT
  signal det_err_ref      : std_logic;
  signal err_ref          : std_logic;
  --signal nbr_err_ref      : integer := 0;
  
  --signaux de resultat du test
  signal erreur_s          : std_logic_vector(2 downto 0) := "000"; -- Erreur
  signal nbr_err_s         : integer := 0;
  signal nbr_err_dir_cw_s  : integer := 0;
  signal sim_end_s         : boolean := false;
  signal check_dir_cw_o_ON : boolean := false;
  
  --variables
  shared variable NbCycleLat_INC_position_v   : integer:=0;
  shared variable NbCycleLat_DEC_position_v   : integer:=0;
  shared variable NbCycleLat_nbr_idx_v        : integer:=0;
  shared variable NbCycleLat_Rising_dir_cw_v  : integer:=0;
  shared variable NbCycleLat_Falling_dir_cw_v : integer:=0;
  
  component acqu_pos_top is
    port (
          init_pos_i    : in  std_logic;  --Initialisation a zero, sychrone, des compteurs (pos, idx, err)
          capt_a_i      : in  std_logic;  --Encodeur phase A
          capt_b_i      : in  std_logic;  --Encodeur phase B
          clock_i       : in  std_logic;  --Horloge du systeme
          reset_i       : in  std_logic;  --Remise a Zero asychrone
          dir_cw_o      : out std_logic;  --Direction: '1' CW (horaire), '0' CCW (anti-horaire)
          position_o    : out std_logic_vector(15 downto 0); --position de la table
          det_err_o     : out std_logic  --Detection d'une erreur (double changement A et B)
    );
  end component;
  
  function MAX(LEFT, RIGHT: INTEGER) return INTEGER is
  begin
    if LEFT > RIGHT then return LEFT;
    else return RIGHT;
      end if;
    end;

begin


  ---------------------------------------------------------------------------
  -- Interconnexion du module VHDL a simuler, uut=Unit Under Test
  ---------------------------------------------------------------------------
  uut: acqu_pos_top port map(
    init_pos_i    => init_pos_sti,
    capt_a_i      => capt_a_sti,
    capt_b_i      => capt_b_sti,
    clock_i       => clk_sti,
    reset_i       => reset_sti,
    dir_cw_o      => dir_cw_obs,
    position_o    => position_obs,
    det_err_o     => det_err_obs
    );
    
  ----------------------------------------------------------------------------------
  --Process de generation de l'horloge
  ----------------------------------------------------------------------------------
  clk_gen:process
  begin
    while not sim_end_s loop
      clk_sti <= '0','1' after CLK_PERIOD/2; 
      wait for CLK_PERIOD;
    end loop;
    wait;
  end process;
  
  ----------------------------------------------------------------------------------
  -- Processus principal de generation des stimulis et des signaux de references                                             --
  ----------------------------------------------------------------------------------
  main_proc:process
    variable l_v    :line;
    variable NumPos : integer:=0;
    variable DureeParPosition_v : time;

    
   procedure GenSensorSignalFromPosition(
      position_num: in integer;
      signal channel_A,channel_B,channel_I:out std_logic) is

      variable dist_from_index_v : integer;
      variable ok: boolean;
    begin
    dist_from_index_v := (position_num-NUM_POS_INDEX) mod NB_POS_PAR_INDEX;
    
    position_ref <= transport (position_num mod NB_POS);
    
    if (dist_from_index_v  < 4) or (dist_from_index_v >=NB_POS_PAR_INDEX-4) then -- Changement index
      if dist_from_index_v mod 8 = 4 then
        channel_A<='0';
        channel_B<='0';
      elsif dist_from_index_v mod 8 = 5 then
        channel_A<='1';
        channel_B<='0';
      elsif dist_from_index_v mod 8 = 6 then
        channel_A<='1';
        channel_B<='1';
      elsif dist_from_index_v mod 8 = 7 then
        channel_A<='0';
        channel_B<='1';
      elsif dist_from_index_v mod 8 = 0 then
        channel_A<='0';
        channel_B<='0';
      elsif dist_from_index_v mod 8 = 1 then
        channel_A<='1';
        channel_B<='0';
      elsif dist_from_index_v mod 8 = 2 then
        channel_A<='1';
        channel_B<='1';
      elsif dist_from_index_v mod 8 = 3 then
        channel_A<='0';
        channel_B<='1';
      end if;
    else -- pas de changement d'index
     -- channel_I<='1';
      if    (dist_from_index_v mod 8 = 0) or (dist_from_index_v mod 8 = 4) then
        channel_A<='0';
        channel_B<='0';
      elsif (dist_from_index_v mod 8 = 1) or (dist_from_index_v mod 8 = 5) then
        channel_A<='1';
        channel_B<='0';
      elsif (dist_from_index_v mod 8 = 2) or (dist_from_index_v mod 8 = 6) then
        channel_A<='1';
        channel_B<='1';
      elsif (dist_from_index_v mod 8 = 3) or (dist_from_index_v mod 8 = 7) then
        channel_A<='0';
        channel_B<='1';
      end if;
    end if;
    end procedure GenSensorSignalFromPosition;

    
    procedure turn(N : in integer; DureeParPosition: in time ) is
    variable J : integer := N;
    begin
      while J /= 0 loop
      if J < 0 then
        J := J+1;
        NumPos := NumPos - 1;
        dir_cw_ref <= '0';
      else
        J := J-1;
        NumPos := NumPos + 1;
        dir_cw_ref <= '1';
      end if;
      GenSensorSignalFromPosition(NumPos,capt_a_sti,capt_b_sti,capt_idx_sti);
      wait for DureeParPosition;
      end loop;
    end procedure turn;
    
    
    procedure check_cpt(Val_ref: in integer; Val_obs: in integer; NameSig_v: in string) is
    begin
      if (Val_ref /= Val_obs) then
        erreur_s(0)  <= '1', '0' after DELTA_T;
        nbr_err_s <= nbr_err_s + 1;
        write(l_v,now);write(l_v,string'(": ERREUR lors de la verification de " & NameSig_v & ": val. observee :" & integer'image(Val_obs) & ", val. attendue:" & integer'image(Val_ref) ));writeline(output,l_v);
      end if;
    end procedure check_cpt;
  
  begin
    
    write(l_v,string'("************************************************************"));writeline(output,l_v);
    write(l_v,now);write(l_v,string'(": START: SIMULATION"));writeline(output,l_v);
    write(l_v,string'("************************************************************"));writeline(output,l_v);
    
    -- INITIALISATION
    NumPos := 0; --position initiale du capteur
    GenSensorSignalFromPosition(NumPos,capt_a_sti,capt_b_sti,capt_idx_sti);
    init_pos_sti <='0';
    reset_sti <= '1';
    dir_cw_ref <= '-';
    check_dir_cw_o_ON <= false;
    err_ref     <= '0';
    wait for 3*CLK_PERIOD;
    reset_sti <= '0';
     
    --Modif: attendre 3 p�riodes pour que la MSS puisse s'initialiser

    wait until rising_edge(clk_sti);

    wait until rising_edge(clk_sti);

    wait until rising_edge(clk_sti);

    -- fin modif EMI mai 2017

    
    wait until falling_edge(clk_sti);
    
    write(l_v,string'("************************************************************"));writeline(output,l_v);
    write(l_v,now);write(l_v,string'(": Determine le nombre de cycles de latence"));writeline(output,l_v);
    write(l_v,string'("************************************************************"));writeline(output,l_v);
    
    -- Deplacement dans le sens horaire pour activer dir_cw_obs
    turn(3,1 us);
    wait for 10*CLK_PERIOD;
    
    -- Determine le nombre de cycles de latence pour dir_cw_obs (transition 1 ->0)
    wait until falling_edge(clk_sti);
    wait for DELTA_T;
    write(l_v,now);write(l_v,string'(": Determine le nombre de cycles de latence dir_cw_obs  1 -> 0"));writeline(output,l_v);
    turn(-1, 0 us);
    NbCycleLat_Falling_dir_cw_v := 0;
    while (NbCycleLat_Falling_dir_cw_v <= MAX_CYCLE_LATENCE) and (dir_cw_obs /= '0') loop
      wait until rising_edge(clk_sti);
      wait for (CLK_PERIOD/2)- DELTA_T;
      NbCycleLat_Falling_dir_cw_v := NbCycleLat_Falling_dir_cw_v+1;
    end loop;
    write(l_v,now);write(l_v,string'(": Nb de cycle de latence du systeme sur dir_cw_obs: " & integer'image(NbCycleLat_Falling_dir_cw_v)));writeline(output,l_v);
    
    -- Determine le nombre de cycles de latence pour dir_cw_obs (transition 0 ->1)
    wait until falling_edge(clk_sti);
    wait for DELTA_T;
    write(l_v,now);write(l_v,string'(": Determine le nombre de cycles de latence dir_cw_obs  0 -> 1"));writeline(output,l_v);
    turn(1, 0 us);
    NbCycleLat_Rising_dir_cw_v := 0;
    while (NbCycleLat_Rising_dir_cw_v <= MAX_CYCLE_LATENCE) and (dir_cw_obs /= '1') loop
      wait until rising_edge(clk_sti);
      wait for (CLK_PERIOD/2)- DELTA_T;
      NbCycleLat_Rising_dir_cw_v := NbCycleLat_Rising_dir_cw_v+1;
    end loop;
    if (NbCycleLat_Rising_dir_cw_v>MAX_CYCLE_LATENCE) then
      write(l_v,now);write(l_v,string'(": Nb de cycle de latence du systeme sur dir_cw_obs > MAX_CYCLE_LATENCE=" & integer'image(MAX_CYCLE_LATENCE) & " ERREUR"));writeline(output,l_v);
    else
      write(l_v,now);write(l_v,string'(": Nb de cycle de latence du systeme sur dir_cw_obs: " & integer'image(NbCycleLat_Rising_dir_cw_v)));writeline(output,l_v);
    end if;
    
    -- Latence de dir_cw_obs connue --> Activation des verifications de dir_cw_obs
    check_dir_cw_o_ON <= true;
    
    -- Determine le nombre de cycles de latence pour position_obs (changement de 1 position)
    wait until falling_edge(clk_sti);
    wait for DELTA_T;
    turn(1, 0 us);
    NbCycleLat_INC_position_v := 0;
    while (NbCycleLat_INC_position_v <= MAX_CYCLE_LATENCE) and (to_integer(unsigned(position_obs)) /= NumPos) loop
      wait until falling_edge(clk_sti);
      NbCycleLat_INC_position_v := NbCycleLat_INC_position_v+1;
    end loop;
    if (NbCycleLat_INC_position_v>MAX_CYCLE_LATENCE) then
      write(l_v,now);write(l_v,string'(": Nb de cycle de latence de position_obs lors de l'incrementation  > MAX_CYCLE_LATENCE=" & integer'image(MAX_CYCLE_LATENCE) & " ERREUR"));writeline(output,l_v);
    else
      write(l_v,now);write(l_v,string'(": Nb de cycle de latence de position_obs lors de l'incrementation : " & integer'image(NbCycleLat_INC_position_v)));writeline(output,l_v);
    end if;
    
    
    -- Determine le nombre de cycles de latence pour position_obs (changement de 1 position)
    wait until falling_edge(clk_sti);
    wait for DELTA_T;
    turn(-1, 0 us);
    NbCycleLat_DEC_position_v := 0;
    while (NbCycleLat_DEC_position_v <= MAX_CYCLE_LATENCE) and (to_integer(unsigned(position_obs)) /= NumPos) loop
      wait until falling_edge(clk_sti);
      NbCycleLat_DEC_position_v := NbCycleLat_DEC_position_v+1;
    end loop;
    if (NbCycleLat_DEC_position_v>MAX_CYCLE_LATENCE) then
      write(l_v,now);write(l_v,string'(": Nb de cycle de latence de position_obs lors de la decrementation > MAX_CYCLE_LATENCE=" & integer'image(MAX_CYCLE_LATENCE) & " ERREUR"));writeline(output,l_v);
    else
      write(l_v,now);write(l_v,string'(": Nb de cycle de latence de position_obs lors de la decrementation : " & integer'image(NbCycleLat_DEC_position_v)));writeline(output,l_v);
    end if;
    
    write(l_v,string'("************************************************************"));writeline(output,l_v);
    write(l_v,now);write(l_v,string'(": START: Verification des compteurs de position lors d'un d�placement horaire "));writeline(output,l_v);
    write(l_v,string'("************************************************************"));writeline(output,l_v);
    DureeParPosition_v := 1 us;
    for i in 1 to 3 loop
      for i in 1 to NB_POS_PAR_INDEX loop
        turn(1,DureeParPosition_v);
        check_cpt(position_sync_ref, to_integer(unsigned(position_obs)),"position_obs");
      end loop;
    end loop;
    wait for 0 ns;
    write(l_v,now);write(l_v,string'(": RESULTAT: Verification des compteurs de position lors d'un d�placement horaire >> Nombre total d'erreurs detectees = " & integer'image(nbr_err_s+nbr_err_dir_cw_s) & " <<"));writeline(output,l_v);
    
    write(l_v,string'("************************************************************"));writeline(output,l_v);
    write(l_v,now);write(l_v,string'(": START: Verification des compteurs de position lors d'un d�placement antihoraire"));writeline(output,l_v);
    write(l_v,string'("************************************************************"));writeline(output,l_v);
    
    for i in 1 to 3 loop
      for i in 1 to NB_POS_PAR_INDEX loop
        turn(-1,DureeParPosition_v);
        check_cpt(position_sync_ref, to_integer(unsigned(position_obs)),"position_obs");
      end loop;
    end loop;
    wait for 0 ns;
    write(l_v,now);write(l_v,string'(": RESULTAT: Verification des compteurs de position lors d'un d�placement antihoraire >> Nombre total d'erreurs detectees = " & integer'image(nbr_err_s+nbr_err_dir_cw_s) & " <<"));writeline(output,l_v);
    
    write(l_v,string'("************************************************************"));writeline(output,l_v);
    write(l_v,now);write(l_v,string'(": START: Verification Detection des Erreurs"));writeline(output,l_v);
    write(l_v,string'("************************************************************"));writeline(output,l_v);
    
    check_dir_cw_o_ON <= false;

    for i in 1 to 4 loop
      GenSensorSignalFromPosition(NumPos+2,capt_a_sti,capt_b_sti,capt_idx_sti);
      det_err_ref <='1';
      wait until det_err_obs='1' for MAX_CYCLE_LATENCE*CLK_PERIOD;
      if det_err_obs/=det_err_ref then
        erreur_s(0)  <= '1', '0' after DELTA_T;
        nbr_err_s <= nbr_err_s + 1;
        write(l_v,now);write(l_v,string'(": ERREUR lors de la verification de det_err_ref : val. observee :" & std_logic'image(det_err_obs) & ", val. attendue:" & std_logic'image(det_err_ref) ));writeline(output,l_v);
      else
        wait until det_err_obs='0' for CLK_PERIOD;
        det_err_ref <='0';
        if det_err_obs/=det_err_ref then
          erreur_s(0)  <= '1', '0' after DELTA_T;
          nbr_err_s <= nbr_err_s + 1;
          write(l_v,now);write(l_v,string'(": ERREUR lors de la verification de det_err_ref : val. observee :" & std_logic'image(det_err_obs) & ", val. attendue:" & std_logic'image(det_err_ref) ));writeline(output,l_v);
        end if;
      end if;
      
      wait until falling_edge(clk_sti);
      err_ref     <= '1';
      turn(7,DureeParPosition_v);
      wait until falling_edge(clk_sti);
 
    end loop;

    -- LFR
    det_err_ref <= '1';
    
    
    wait until falling_edge(clk_sti);

    if det_err_obs/=det_err_ref then
      erreur_s(0)  <= '1', '0' after DELTA_T;
      nbr_err_s <= nbr_err_s + 1;
      write(l_v,now);write(l_v,string'(": ERREUR lors de la verification de det_err_ref : val. observee :" & std_logic'image(det_err_obs) & ", val. attendue:" & std_logic'image(det_err_ref) ));writeline(output,l_v);
    end if;

    init_pos_sti <= '1';

    wait until falling_edge(clk_sti);
    wait until falling_edge(clk_sti);

    err_ref <= '0';
    wait until falling_edge(clk_sti);
    wait until falling_edge(clk_sti);

    det_err_ref <= '0';
    
    wait until falling_edge(clk_sti);

    if det_err_obs/=det_err_ref then
      erreur_s(0)  <= '1', '0' after DELTA_T;
      nbr_err_s <= nbr_err_s + 1;
      write(l_v,now);write(l_v,string'(": ERREUR lors de la verification de det_err_ref : val. observee :" & std_logic'image(det_err_obs) & ", val. attendue:" & std_logic'image(det_err_ref) ));writeline(output,l_v);
    end if;

    wait for 0 ns;
    write(l_v,now);write(l_v,string'(": RESULTAT: Verification Detection des Erreurs >> Nombre total d'erreurs detectees = " & integer'image(nbr_err_s+nbr_err_dir_cw_s) & " <<"));writeline(output,l_v);

--     write(l_v,string'("************************************************************"));writeline(output,l_v);
--     write(l_v,now);write(l_v,string'(": START: Verification des compteurs de position lors d'oscillations"));writeline(output,l_v);
--     write(l_v,string'("************************************************************"));writeline(output,l_v);
--     DureeParPosition_v := 1 us;
--     NumPos := 0;
--     GenSensorSignalFromPosition(NumPos,capt_a_sti,capt_b_sti,capt_idx_sti);
--     init_pos_sti <='1';
--     wait for 5*CLK_PERIOD;
--     init_pos_sti <= '0';
--     wait for 5*CLK_PERIOD;
--     check_dir_cw_o_ON <= true;
--     turn(NUM_POS_INDEX-4+NB_POS_PAR_INDEX,DureeParPosition_v);
--     wait for 10*CLK_PERIOD;
--     report"Valeur position_obs =" & integer'image(to_integer(unsigned(position_obs))) & ", attendu:" & integer'image(position_sync_ref);
-- 
--     
--     for var_vitesse in 1 to 10 loop --Boucle testant differentes vitesses de deplacement (i.e differentes durees par position)
--     DureeParPosition_v := var_vitesse * 100 ns;
--     write(l_v,now);write(l_v,string'(": TEST avec Temps par position = " & time'image(DureeParPosition_v) & " <<"));writeline(output,l_v);
--       for nb_pos_trajet in 1 to 10 loop --Boucle pour faire differents rebroussements autour de la position de l'index
--         for i in 1 to nb_pos_trajet loop
--           turn(1,DureeParPosition_v);
--           wait until falling_edge(clk_sti);
--           check_cpt(position_sync_ref, to_integer(unsigned(position_obs)),"position_obs");
--         end loop;
--         
--         for i in 1 to nb_pos_trajet loop
--           turn(-1,DureeParPosition_v);
--           wait until falling_edge(clk_sti);
--           check_cpt(position_sync_ref, to_integer(unsigned(position_obs)),"position_obs");
--         end loop;
--         wait for 10*CLK_PERIOD;
--         
--       end loop;
--     end loop;
--     wait for 0 ns;
--     write(l_v,now);write(l_v,string'(": RESULTAT: Verification des compteurs de position lors d'oscillations >> Nombre total d'erreurs detectees = " & integer'image(nbr_err_s+nbr_err_dir_cw_s) & " <<"));writeline(output,l_v);

    write(l_v,string'("************************************************************"));writeline(output,l_v);
    write(l_v,now);write(l_v,string'(": DONE: SIMULATION"));writeline(output,l_v);
    write(l_v,string'("************************************************************"));writeline(output,l_v);
    report ">> Nombre total d'erreurs detectees = " & integer'image(nbr_err_s+nbr_err_dir_cw_s) & " <<";
    sim_end_s <= true;
    wait;
  end process;
  
  P0_sti <= not capt_a_sti and not capt_b_sti;
  
  
  sync_ref:process(clk_sti)
  begin
    -- assignation des references synchrones sur le rising_edge de clk_sti (apres X cycles)
    if rising_edge(clk_sti) then
      if check_dir_cw_o_ON=TRUE then
        if dir_cw_ref='1' then
          dir_cw_sync_ref <= transport dir_cw_ref after MAX(NbCycleLat_Rising_dir_cw_v-1,0)*CLK_PERIOD;
        else
          dir_cw_sync_ref <= transport dir_cw_ref after MAX(NbCycleLat_Falling_dir_cw_v-1,0)*CLK_PERIOD;
        end if;
      else 
        dir_cw_sync_ref <= '-';
      end if;
      if dir_cw_ref='1' then
        position_sync_ref <= transport position_ref after MAX(NbCycleLat_INC_position_v-1,0)*CLK_PERIOD;
      else
        position_sync_ref <= transport position_ref after MAX(NbCycleLat_DEC_position_v-1,0)*CLK_PERIOD;
      end if;
    end if;
  end process;
 
--------------------------------------------------  
-- Process de verification 
--------------------------------------------------
  check_dir_cw_o:process
  variable l_v :line;
  begin
    while not sim_end_s loop
      --Verification asynchrone
      wait until falling_edge(clk_sti);
      wait for (CLK_PERIOD/2)- DELTA_T;
      if dir_cw_sync_ref = '-' then
        --report"Clockwise_rotate_o non verifie";
      elsif dir_cw_sync_ref /= dir_cw_obs then
        erreur_s(1)  <= '1', '0' after DELTA_T;
        nbr_err_dir_cw_s <= nbr_err_dir_cw_s + 1;
        write(l_v,now);write(l_v,string'(": ERREUR lors de la verification asynchrone de dir_cw_obs : val. observee :" & std_logic'image(dir_cw_obs) & ", val. attendue:" & std_logic'image(dir_cw_sync_ref) ));writeline(output,l_v);
      end if;

      --Verification synchrone
      wait until rising_edge(clk_sti);
      wait for (CLK_PERIOD/2)- DELTA_T;
      if dir_cw_sync_ref = '-' then
--         report"Clockwise_rotate_o non verifie";
      elsif dir_cw_sync_ref /= dir_cw_obs then
        erreur_s(1)  <= '1', '0' after DELTA_T;
        nbr_err_dir_cw_s <= nbr_err_dir_cw_s + 1;
        write(l_v,now);write(l_v,string'(": ERREUR lors de la verification synchrone de dir_cw_obs : val. observee :" & std_logic'image(dir_cw_obs) & ", val. attendue:" & std_logic'image(dir_cw_sync_ref) ));writeline(output,l_v);
      end if;
    end loop;
    wait;
  end process;

end testbench;
