----- MULTISTEPS

library ieee;
use ieee.numeric_bit.all;
use work.pkg.all;

entity multisteps is
    port (
        clk, rst : in bit;
        msgi : in bit_vector(511 downto 0);
        haso : out bit_vector(255 downto 0);
        done : out bit
    );
end multisteps;
architecture arch of multisteps is

    component multisteps_FD is
        port (
            msgi : in bit_vector(511 downto 0);
            sigma1_input, sigma0_input : in bit_vector(31 downto 0);
            -- sequential_in_W : in bit_vector(31 downto 0);
            KPW : in bit_vector(31 downto 0);
            stepfun_input : in stepfun_array_type(7 downto 0);
            done, rst, clk : in bit;
            -- enable_W, enable_parallel_W : in bit;
            enable_counter : in bit;
            enable_stepfun_output : in bit;
            sigma0_output, sigma1_output : out bit_vector(31 downto 0);
            stepfun_output_out : out stepfun_array_type(7 downto 0);
            counter : out integer
        );
    end component;

    component multisteps_UC is
        port (
            sigma1_input, sigma0_input : out bit_vector(31 downto 0);
            -- sequential_in_W : out bit_vector(31 downto 0);
            KPW : out bit_vector(31 downto 0);
            stepfun_input : out stepfun_array_type(7 downto 0);
            done : out bit;
            -- enable_W, enable_parallel_W : out bit;
            enable_counter : out bit;
            enable_stepfun_output : out bit;
            sigma0_output, sigma1_output : in bit_vector(31 downto 0);
            stepfun_output_out : in stepfun_array_type(7 downto 0);
            msgi : in bit_vector(511 downto 0);
            rst, clk : in bit;
            counter : in integer;
            haso : out bit_vector(255 downto 0)
        );
    end component;
    
    signal counter : INTEGER;

    signal stepfun_input : stepfun_array_type(7 downto 0);
    signal stepfun_output_out : stepfun_array_type(7 downto 0);

    signal sigma0_input, sigma0_output : bit_vector(31 downto 0);
    signal sigma1_input, sigma1_output : bit_vector(31 downto 0);

    -- signal sequential_in_W : bit_vector(31 downto 0);
    
    signal KPW : bit_vector(31 downto 0);
    signal enable_counter : bit;


    -- signal enable_W, enable_parallel_W, enable_stepfun_output : bit;
    signal enable_stepfun_output : bit;
    signal done_internal : bit;
    signal not_clk : bit;
    
    begin

MULTISTEPS_FD_INST: multisteps_FD port map(
    msgi => msgi,
    sigma1_input => sigma1_input,
    sigma0_input => sigma0_input,
    -- sequential_in_W => sequential_in_W,
    KPW => KPW,
    stepfun_input => stepfun_input,
    rst => rst,
    done => done_internal,
    clk => not_clk,
    -- enable_W => enable_W,
    -- enable_parallel_W => enable_parallel_W,
    enable_stepfun_output => enable_stepfun_output,
    sigma0_output => sigma0_output,
    sigma1_output => sigma1_output,
    stepfun_output_out => stepfun_output_out,
    counter => counter,
    enable_counter => enable_counter
);

MULTISTEPS_UC_INST: multisteps_UC port map(
    sigma1_input => sigma1_input,
    sigma0_input => sigma0_input,
    -- sequential_in_W => sequential_in_W,
    KPW => KPW,
    stepfun_input => stepfun_input,
    done => done_internal,
    -- enable_W => enable_W,
    -- enable_parallel_W => enable_parallel_W,
    enable_stepfun_output => enable_stepfun_output,
    sigma0_output => sigma0_output,
    sigma1_output => sigma1_output,
    stepfun_output_out => stepfun_output_out,
    enable_counter => enable_counter,
    msgi => msgi,
    rst => rst,
    clk => clk,
    counter => counter,
    haso => haso
);

    done <= '1' when done_internal='1' and counter>=64 else '0';
    
-- done <= done_internal;
not_clk <= not clk;

end arch ; -- arch
