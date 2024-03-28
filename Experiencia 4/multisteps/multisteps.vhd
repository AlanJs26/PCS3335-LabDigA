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
            sequential_in_W : in bit_vector(31 downto 0);
            q_W : in W_array(15 downto 0);
            KPW_in : in bit_vector(31 downto 0);
            stepfun_input : in stepfun_array_type(7 downto 0);
            done, rst, clk : in bit;
            enable_W, enable_parallel_W : in bit;
            enable_KPW : in bit;
            enable_stepfun_output : in bit;
            sigma0_output, sigma1_output : out bit_vector(31 downto 0);
            KPW_output : out bit_vector(31 downto 0);
            stepfun_output_out : out stepfun_array_type(7 downto 0);
            counter : out integer
        );
    end component;

    component multisteps_UC is
        port (
            sigma1_input, sigma0_input : out bit_vector(31 downto 0);
            sequential_in_W : out bit_vector(31 downto 0);
            q_W : out W_array(15 downto 0);
            KPW_in : out bit_vector(31 downto 0);
            stepfun_input : out stepfun_array_type(7 downto 0);
            done : out bit;
            enable_W, enable_parallel_W : out bit;
            enable_KPW : out bit;
            enable_stepfun_output : out bit;
            sigma0_output, sigma1_output : in bit_vector(31 downto 0);
            KPW_output : in bit_vector(31 downto 0);
            stepfun_output_out : in stepfun_array_type(7 downto 0);
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

    signal sequential_in_W : bit_vector(31 downto 0);
    signal q_W : W_array(15 downto 0);
    
    signal KPW_in, KPW_output : bit_vector(31 downto 0);

    signal enable_W, enable_parallel_W, enable_KPW, enable_stepfun_output : bit;
    
    begin

MULTISTEPS_FD_INST: multisteps_FD port map(
    msgi => msgi,
    sigma1_input => sigma1_input,
    sigma0_input => sigma0_input,
    sequential_in_W => sequential_in_W,
    q_W => q_W,
    KPW_in => KPW_in,
    stepfun_input => stepfun_input,
    done => done,
    rst => rst,
    clk => clk,
    enable_W => enable_W,
    enable_parallel_W => enable_parallel_W,
    enable_KPW => enable_KPW,
    enable_stepfun_output => enable_stepfun_output,
    sigma0_output => sigma0_output,
    sigma1_output => sigma1_output,
    KPW_output => KPW_output,
    stepfun_output_out => stepfun_output_out,
    counter => counter
);

MULTISTEPS_UC_INST: multisteps_UC port map(
    sigma1_input => sigma1_input,
    sigma0_input => sigma0_input,
    sequential_in_W => sequential_in_W,
    q_W => q_W,
    KPW_in => KPW_in,
    stepfun_input => stepfun_input,
    done => done,
    enable_W => enable_W,
    enable_parallel_W => enable_parallel_W,
    enable_KPW => enable_KPW,
    enable_stepfun_output => enable_stepfun_output,
    sigma0_output => sigma0_output,
    sigma1_output => sigma1_output,
    KPW_output => KPW_output,
    stepfun_output_out => stepfun_output_out,
    rst => rst,
    clk => clk,
    counter => counter,
    haso => haso
);


end arch ; -- arch