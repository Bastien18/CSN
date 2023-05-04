--------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- File         : acqu_pos_top.vhd
--
-- Description : 
-- Acquisition de la position de la table tournante
--   -mesure de la position de la table, comptage incréments capteurs
--      traitement des signaux A et B de l'encodeur
--   -Detection d'erreur sur l'encodeur
--   -MSS de gestion de l'encodeur de position (capt A-B)
--      sens_hr : actif si sens horaire
--      Inc_up, Inc_dn: impulsion pour comptage position
--      det_err: indique double changement simultane de A et B
--
-- Author       : Etienne Messerli
-- Date         : 07.12.2015
-- Version      : 1.0
--
-- Use          : Labo csn/syslog2, décembre 2015
--
--| Modifications |-------------------------------------------------------------
-- Version   Auteur      Date               Description
-- 0.1       EMI         14.01.2015         version initiale "mgn_position.vhd"
-- 1.0       EMI         07.12.2015         Adaptation pour le labo de décembre
--                                          2015
-- 1.1       LFR         27.04.2023         Adaptation pour le labo de avril
--                                          2023
--------------------------------------------------------------------------------

--| Library |-------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
--------------------------------------------------------------------------------

--| Entity |--------------------------------------------------------------------
entity acqu_pos_top is
  port(
        clock_i    : in  std_logic;--Horloge du systeme
        reset_i    : in  std_logic;--Remise a Zero asychrone
        init_pos_i : in  std_logic;--Init a zero, sychrone, des compteurs
        capt_a_i   : in  std_logic;--Encodeur phase A
        capt_b_i   : in  std_logic;--Encodeur phase B

        dir_cw_o   : out std_logic;--Direction: '1' CW (horaire), 
                                   --           '0' CCW (anti-horaire)

        position_o : out std_logic_vector(15 downto 0);--Position de la table

        det_err_o  : out std_logic --Detection erreur (double changement A et B)
  );
end acqu_pos_top;
--------------------------------------------------------------------------------

--| Architecture |--------------------------------------------------------------
architecture struct of acqu_pos_top is

    --| Signals |---------------------------------------------------------------
   
    ----------------------------------------------------------------------------

    --| Components |------------------------------------------------------------
    component mss_det_rot 
    port(
        clock_i   : in  std_logic;
        reset_i   : in  std_logic;
       -- A completer
    );
    end component;
    for all : mss_det_rot use entity work.mss_det_rot(fsm);

    component cpt_pos
    port(
        clock_i    : in  std_logic;
        reset_i    : in  std_logic;
        -- A completer
    );
    end component;
    for all : cpt_pos use entity work.cpt_pos(rtl);
    ----------------------------------------------------------------------------

begin

    --| Components instanciation |----------------------------------------------
    I_mss : mss_det_rot
    port map(
        clock_i   => clock_i,
        reset_i   => reset_i,
        -- A completer
    );

    I_pos : cpt_pos
    port map(
        clock_i    => clock_i,
        reset_i    => reset_i,
        -- A completer
    );
    ----------------------------------------------------------------------------


    --| Outputs affectation |---------------------------------------------------
    
    ----------------------------------------------------------------------------

end struct;
--------------------------------------------------------------------------------