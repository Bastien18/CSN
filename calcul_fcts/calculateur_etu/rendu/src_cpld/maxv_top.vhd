--------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- File           : maxv_top.vhd
--
-- Description    : Top of the CPLD
--
-- Author         : Gilles Curchod
-- Date           : 28.05.2013
-- Version        : 1.2
-- Target Devices : Altera MAXV 5M570ZF256C5
--
-- Used for       : Integration of calcul_fcts_top
--
--| Modifications |-------------------------------------------------------------
-- Version   Auteur      Date               Description
-- 0.0       GCD         28.05.2013         Initial version
-- 1.0       EMI         25.09.2014         Adaptation to use for CSN lab
-- 1.1       KGS         23.03.2015         Connection with console reds
-- 1.2       LFR         06.02.2023         Adaptation pour labo calc fcts 2023
--------------------------------------------------------------------------------

--| Library |-------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    --use work.maxv_pkg.all;
--------------------------------------------------------------------------------

--| Entity |--------------------------------------------------------------------
entity maxv_top is
    port(
        --| Clocks, Reset |-----------------------------------------------------
        Clk_Gen_i    : in    std_logic;                      -- CLK_GEN
        Clk_Main_i   : in    std_logic;                      -- CLK_MAIN
        --| Inout devices |-----------------------------------------------------
        Con_25p_io   : inout std_logic_vector(25 downto 1);  -- CON_25P_*
        Con_80p_io   : inout std_logic_vector(79 downto 2);  -- CON_80P_*
        Mezzanine_io : inout std_logic_vector(20 downto 5);  -- MEZZANINE_*
        --| Input devices |-----------------------------------------------------
        Encoder_A_i  : in    std_logic;                      -- ENCODER_A
        Encoder_B_i  : in    std_logic;                      -- ENCODER_B
        nButton_i    : in    std_logic_vector( 8 downto 1);  -- NBUTTON_*
        nReset_i     : in    std_logic;                      -- NRESET
        Switch_i     : in    std_logic_vector( 7 downto 0);  -- SWITCH_*
        --| Output devices |----------------------------------------------------
        nLed_o       : out   std_logic_vector( 7 downto 0);  -- NLED_*
        Led_RGB_o    : out   std_logic_vector( 2 downto 0);  -- LED_RGB_*
        nSeven_Seg_o : out   std_logic_vector( 7 downto 0)   -- (dp, g downto a)
    );
end maxv_top;
--------------------------------------------------------------------------------

--| Architecture |--------------------------------------------------------------
architecture struct of maxv_top is

    --| Intermediate signals |--------------------------------------------------
    signal Con_25p_DI_s   : std_logic_vector(Con_25p_io'range);
    signal Con_25p_DO_s   : std_logic_vector(Con_25p_io'range);
    signal Con_25p_OE_s   : std_logic_vector(Con_25p_io'range);
    signal Con_80p_DI_s   : std_logic_vector(Con_80p_io'range);
    signal Con_80p_DO_s   : std_logic_vector(Con_80p_io'range);
    signal Con_80p_OE_s   : std_logic_vector(Con_80p_io'range);
    signal Mezzanine_DI_s : std_logic_vector(Mezzanine_io'range);
    signal Mezzanine_DO_s : std_logic_vector(Mezzanine_io'range);
    signal Mezzanine_OE_s : std_logic;
    signal Button_s       : std_logic_vector(nButton_i'range);
    signal Led_s          : std_logic_vector(nLed_o'range);
    -- order 7 seg : dp, g f e d c b a
    signal Seven_Seg_s    : std_logic_vector(nSeven_Seg_o'range);
    ----------------------------------------------------------------------------

    --| Internal signals |------------------------------------------------------
    signal cpt_s       : unsigned(19 downto 0);
    signal blink_1hz_s : std_logic;
    -- 
    signal na_s  : std_logic_vector(7 downto 0);
    signal nb_s  : std_logic_vector(7 downto 0);
    signal f_s   : std_logic_vector(10 downto 0);
    ----------------------------------------------------------------------------

    --| Components declaration |------------------------------------------------
    component calcul_fcts_top
        port (
            na_i  : in  std_logic_vector(7 downto 0);
            nb_i  : in  std_logic_vector(7 downto 0);
            sel_i : in  std_logic;
            f_o   : out std_logic_vector(10 downto 0)
        );
    end component calcul_fcts_top;
    for all : calcul_fcts_top use entity work.calcul_fcts_top(struct);
    ----------------------------------------------------------------------------

begin

    --| INPUTS PROCESSING |-----------------------------------------------------
    Button_s <= not nButton_i;
    ----------------------------------------------------------------------------

    --| OUTPUT PROCESSING |-----------------------------------------------------
    nLed_o       <= not Led_s;
    nSeven_Seg_o <= not Seven_Seg_s;
    ----------------------------------------------------------------------------

    --| Tri-state declaration for the 80p connector |--------------------------- 
    --    '0' = out,   '1' = in 
    --                                                maxv      : console reds
    Con_80p_OE_s(8 downto 2)   <= (others => '0'); -- unused    = Leds(7:1)
    Con_80p_OE_s(16 downto 9)  <= (others => '0'); -- f_o(7:0)  = Result_A(7:0)
    Con_80p_OE_s(19 downto 17) <= (others => '0'); -- f_o(10:8) = Result_A(10:8)
    Con_80p_OE_s(24 downto 20) <= (others => '0'); -- unused    = Result_A(15:11)
    Con_80p_OE_s(40 downto 25) <= (others => '0'); -- unused    = Result_B(15:0)
    Con_80p_OE_s(48 downto 41) <= (others => '1'); -- na_i(7:0) = Val_A(7:0)
    Con_80p_OE_s(56 downto 49) <= (others => '1'); -- unused    = Val_A(15:8)
    Con_80p_OE_s(64 downto 57) <= (others => '1'); -- nb_i(7:0) = Val_B(7:0)
    Con_80p_OE_s(72 downto 65) <= (others => '1'); -- unused    = Val_B(15:8)
    Con_80p_OE_s(79 downto 73) <= (others => '1'); -- unused    = unused

    --  -- In/out pin map for REDS_console
    --   # - Pin(s) 08 downto 02 as inputs # Leds           | 80pConnPort1
    --   # - Pin(s) 16 downto 09 as inputs # Result_A( 7:0) | 80pConnPort2
    --   # - Pin(s) 24 downto 17 as inputs # Result_A(15:8) | 80pConnPort3
    --   # - Pin(s) 32 downto 25 as inputs # Result_B( 7:0) | 80pConnPort4
    --   # - Pin(s) 40 downto 33 as inputs # Result_B(15:8) | 80pConnPort5
    --   # - Pin(s) 48 downto 41 as outputs # Val_A(7:0)    | 80pConnPort6
    --   # - Pin(s) 56 downto 49 as outputs # Val_A(15:8)   | 80pConnPort7
    --   # - Pin(s) 64 downto 57 as outputs # Val_B(7:0)    | 80pConnPort8
    --   # - Pin(s) 72 downto 65 as outputs # Val_B(15:8)   | 80pConnPort9

    tri_state_80p_loop: for I in Con_80p_io'right to Con_80p_io'left generate
        Con_80p_io(I) <= Con_80p_DO_s(I) when Con_80p_OE_s(I) = '0' else 'Z';
    end generate;

    Con_80p_DI_s <= to_X01(Con_80p_io);
    ----------------------------------------------------------------------------

    --| Unused output allocation |----------------------------------------------
    Led_RGB_o <= (others => '0');
    Seven_Seg_s(Seven_Seg_s'high-1 downto 1)  <= (others => '0');
    Seven_Seg_s(Seven_Seg_s'high) <= blink_1hz_s; -- decimal point blink at 1Hz
    ----------------------------------------------------------------------------

    --| Components intanciation |-----------------------------------------------
    calcul_fcts_inst : calcul_fcts_top 
    port map (     
        sel_i => switch_i(0),
        na_i  => na_s,
        nb_i  => nb_s,
        f_o   => f_s          
    );
    ----------------------------------------------------------------------------

    --| Component to port affectation |-----------------------------------------
    --Output
    Con_80p_DO_s(8 downto 2)   <= (others => '0');        -- Leds(7:1)
    Con_80p_DO_s(16 downto 9)  <= f_s(7 downto 0);  -- Result_A(7:0)
    Con_80p_DO_s(19 downto 17) <= f_s(10 downto 8); -- Result_A(10:8)             
    Con_80p_DO_s(24 downto 20) <= (others => f_s(f_s'high));  -- Result_A(15:8)
    Con_80p_DO_s(40 downto 25) <= (others => '0');  -- Result_B(15:0)
    -- Input
    na_s  <= Con_80p_DI_s(48 downto 41);           -- Val_A(7:0)
    nb_s  <= Con_80p_DI_s(64 downto 57);           -- Val_B(7:0)
    ----------------------------------------------------------------------------

    --| Signal blink at 1Hz |---------------------------------------------------
    process (nReset_i, Clk_Main_i)
    begin
        if nReset_i = '0' then
            Cpt_s <= (others => '0');
        elsif rising_edge(Clk_Main_i) then
            Cpt_s <= Cpt_s +1;
        end if;
    end process;
    ----------------------------------------------------------------------------

    -- signal for test 
    blink_1hz_s <= cpt_s(cpt_s'high);
    led_s       <= (others => '0');

end struct;
--------------------------------------------------------------------------------