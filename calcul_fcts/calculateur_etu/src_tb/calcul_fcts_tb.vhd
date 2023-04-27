--------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- File         : calc_fcts_tb.vhd
--
-- Description  : This file will allow to simulate students design and verify
--                if their design seems to work or not. This will not validate
--                the design but at least will control some limit of the
--                computing system.
--
-- Author       : L. Fournier
-- Date         : 06.02.2023
-- Version      : 1.1
--
--| Modifications |-------------------------------------------------------------
-- Version   Auteur      Date               Description
-- 1.0       MIM         17.10.2018         First version (SysLog1).
-- 1.1       LFR         06.02.2023         Update for SysLog2/CSN.
--------------------------------------------------------------------------------

--| Library |-------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
--------------------------------------------------------------------------------

--| Entity |--------------------------------------------------------------------
entity calcul_fcts_tb is
end calcul_fcts_tb;
--------------------------------------------------------------------------------

--| Architecture |--------------------------------------------------------------
architecture test_bench of calcul_fcts_tb is

    --| Types |-----------------------------------------------------------------
    type array_integer_t is array(natural range <>) of integer;
    ----------------------------------------------------------------------------

    --| Constants |-------------------------------------------------------------
    constant CLK_PERIOD  : time := 1 us;
    -- list of integer values (arbitrary except limit of 8 bits range of signed)
    constant array_values_c : array_integer_t := (
        -128,
        -53,
        -25,
        -2,
        -1,
        0,
        5,
        12,
        93,
        127
    );
    ----------------------------------------------------------------------------

    --| Constants |-------------------------------------------------------------
    -- f0 = a + 2*b - 84
    function compute_function0(a, b : integer)
        return integer is
    begin
        return (a + 2*b - 84);
    end compute_function0;
    -- f1 = 3*a - b + 42
    function compute_function1(a, b : integer)
        return integer is
    begin
        return (3*a - b + 42);
    end compute_function1;
    ----------------------------------------------------------------------------

    --| Signals |---------------------------------------------------------------
    -- stimulus and observed signals
    signal na_sti  : std_logic_vector(7 downto 0);
    signal nb_sti  : std_logic_vector(7 downto 0);
    signal sel_sti : std_logic;
    signal f_obs   : std_logic_vector(10 downto 0);
    -- transform inputs into integer
    signal na_i_s : integer := 0;
    signal nb_i_s : integer := 0;
    -- signal that handle current result computed
    signal result_tb_s : integer;
    -- signal to convert result from design to integer
    signal result_dut_s : integer;
    -- Flag for the end of simulation
    signal end_of_sim_s      : boolean := false;
    signal end_of_stimulus_s : boolean := false;
    signal err_s             : std_logic;
    signal clk_s             : std_logic;
    ----------------------------------------------------------------------------

    --| Components |-----------------------------------------------------------
    -- DUT
    component calcul_fcts_top
        port (
            na_i  : in  std_logic_vector(7 downto 0);
            nb_i  : in  std_logic_vector(7 downto 0);
            sel_i : in  std_logic;
            f_o   : out std_logic_vector(10 downto 0)
        );
    end component calcul_fcts_top;
    for all : calcul_fcts_top use entity work.calcul_fcts_top(struct);
    ---------------------------------------------------------------------------

begin  -- test_bench

    --| Clock generation process |---------------------------------------------
    clk_gen : process is
    begin
        while not(end_of_sim_s) loop
            clk_s <= '0', '1' after CLK_PERIOD/2;
            wait for CLK_PERIOD;
        end loop;
        wait;
    end process clk_gen;
    ---------------------------------------------------------------------------

    --| Stimulus process |-----------------------------------------------------
    stim_proc : process is
    begin

        -- Notify user for the beginning of simulation
        report "Debut de la simulation pour le calculateur du cours " & 
               "SYSLOG2/CSN-2023";

        -- Default value for outputs
        na_i_s  <= 0;
        nb_i_s  <= 0;
        sel_sti <= '0';

        -- synchronize with rising edge of clock to generate values
        wait until rising_edge(clk_s);

        -- We will browse the constant tab
        for i in array_values_c'range loop
            -- Put integer value to A
            na_i_s <= array_values_c(i);

            -- we will browse the constant tab to test all possibilities
            for j in array_values_c'range loop

                -- Put integer value to B
                nb_i_s <= array_values_c(j);

                -- We test first operation
                sel_sti <= '0';

                -- synchronize with rising edge of clock to generate values
                wait until rising_edge(clk_s);

                -- Then we test second operation
                sel_sti <= '1';

                -- synchronize with rising edge of clock to generate values
                wait until rising_edge(clk_s);
            end loop;  -- internal loop
        end loop;  -- external loop
        
        end_of_stimulus_s <= true;

        -- Notify user
        report "Fin de la simulation ! Observez le log pour voir si vous avez " &
            "des erreurs";

        -- We stop process
        wait;
    end process stim_proc;
    ---------------------------------------------------------------------------

    --| reference |------------------------------------------------------------
    -- Compute values with current state of stimulation
    result_tb_s <= compute_function0(na_i_s, nb_i_s) when(sel_sti = '0') else
                   compute_function1(na_i_s, nb_i_s);
    ---------------------------------------------------------------------------

    --| Stimulus process |-----------------------------------------------------
    verif_proc : process is
        -- errors counter
        variable nb_error_v : integer := 0;
    begin
        while(not(end_of_stimulus_s)) loop
            -- we will verify on the falling edge of clock
            wait until falling_edge(clk_s);

            -- default value of flag
            err_s <= '0';

            -- we compare if reference is the same as the design result
            if (result_dut_s /= result_tb_s) then
                -- Notify user
                report "Error while computing !";
                report "A = " & integer'image(na_i_s) & 
                    " B = " & integer'image(nb_i_s);
                report "Expected : " & integer'image(result_tb_s) & 
                    " but got : " & integer'image(result_dut_s);

                -- Put a flag for chronogram
                err_s <= '1';

                -- increment counter
                nb_error_v := nb_error_v + 1;
            end if;
        end loop;
        -- notify user about end of verification
        report "end of verification process";
        -- Final report
        report "Error detected : " & integer'image(nb_error_v);
        end_of_sim_s <= true;
        -- stop process
        wait;
    end process;
    ---------------------------------------------------------------------------

    --| Signals affectation |--------------------------------------------------
    -- Inputs
    result_dut_s <= to_integer(signed(f_obs));
    -- Outputs
    na_sti <= std_logic_vector(to_signed(na_i_s, na_sti'length));
    nb_sti <= std_logic_vector(to_signed(nb_i_s, nb_sti'length));
    ---------------------------------------------------------------------------

    --| Components instanciation |---------------------------------------------
    UUT : calcul_fcts_top
    port map(
        na_i  => na_sti,
        nb_i  => nb_sti,
        sel_i => sel_sti,
        f_o   => f_obs
    );
    ---------------------------------------------------------------------------

end test_bench;