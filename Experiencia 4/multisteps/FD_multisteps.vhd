-------------------------------------------------------------------------------
-- Author: Alan Jose dos Santos (alanjose@usp.br)
-- Author: Lucas Franco
-- Module Name: exp4_multisteps
-------------------------------------------------------------------------------
----- MULTISTEPS

package pkg is
    type W_array is array (NATURAL range <>) of bit_vector(31 downto 0);
    type stepfun_array_type is array (NATURAL range <>) of bit_vector(31 downto 0);
end package;
  
package body pkg is
end package body;

library ieee;
use ieee.numeric_bit.all;
use work.pkg.all;


entity multisteps_FD is
    port (
        msgi : in bit_vector(511 downto 0);
        sigma1_input, sigma0_input : in bit_vector(31 downto 0);
        sequential_in_W : in bit_vector(31 downto 0);
        KPW_in : in bit_vector(31 downto 0);
        stepfun_input : in stepfun_array_type(7 downto 0);
        done, rst, clk : in bit;
        enable_W, enable_parallel_W : in bit;
        enable_KPW : in bit;
        enable_stepfun_output : in bit;
        enable_counter : in bit;
        q_W : out W_array(63 downto 0);
        sigma0_output, sigma1_output : out bit_vector(31 downto 0);
        stepfun_output_out : out stepfun_array_type(7 downto 0);
        counter : out integer
    );
end multisteps_FD;

architecture arch of multisteps_FD is

    component somador is
        port (
            a, b : in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end component;

    component sigma0 is
        port (
            x : in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end component;

    component sigma1 is
        port (
            x : in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end component;

    component stepfun is
        port (
            ai, bi, ci, di, ei, fi, gi, hi : in bit_vector(31 downto 0);
            kpw : in bit_vector(31 downto 0);
            ao, bo, co, do, eo, fo, go, ho : out bit_vector(31 downto 0)
        );
    end component;

    component W_register is
        port (
            clk : in BIT;
            rst : in BIT;
            counter : in INTEGER;
            enable : in BIT;
            enable_parallel : in BIT;
            parallel_in : in bit_vector(511 downto 0);
            sequential_in : in bit_vector(31 downto 0);
            q : out W_array(63 downto 0)
        );
    end component;

    component reg32 is
        port (
            clk, rst, enable : in BIT;
            D : in bit_vector(31 downto 0);
            Q : out bit_vector(31 downto 0)
        );
    end component;

    component stepfun_register is
        port (
            clk   : in bit;
            rst : in bit;
            enable : in bit;
            D : in stepfun_array_type(7 downto 0);
            Q : out stepfun_array_type(7 downto 0)
        );
    end component;


    signal parallel_in_W : bit_vector(511 downto 0);
    signal KPW_output : bit_vector(31 downto 0);
    signal stepfun_output_in : stepfun_array_type(7 downto 0);
    signal counter_internal : integer := 0;

begin
    parallel_in_W <= msgi;

    SIGMA0_INSTANCE : sigma0 port map(sigma0_input, sigma0_output);
    SIGMA1_INSTANCE : sigma1 port map(sigma1_input, sigma1_output);

    STEPFUN_INSTANCE : stepfun port map(
        stepfun_input(0), stepfun_input(1), stepfun_input(2), stepfun_input(3), stepfun_input(4), stepfun_input(5), stepfun_input(6), stepfun_input(7),
        KPW_output,
        stepfun_output_in(0), stepfun_output_in(1), stepfun_output_in(2), stepfun_output_in(3), stepfun_output_in(4), stepfun_output_in(5), stepfun_output_in(6), stepfun_output_in(7)
    );

    W_REGISTER_INSTANCE : W_register port map(
        clk => clk,
        rst => rst,
        counter => counter_internal,
        enable => enable_W,
        enable_parallel => enable_parallel_W,
        parallel_in => parallel_in_W,
        sequential_in => sequential_in_W,
        q => q_W
    );

    KPW_INSTANCE : reg32 port map(
        clk => clk,
        rst => rst,
        enable => enable_KPW,
        D => KPW_in,
        Q => KPW_output
    );

    
    STEPFUN_OUTPUT_REGISTER_INSTANCE : stepfun_register port map(
        clk => clk,
        rst => rst,
        enable => enable_stepfun_output,
        D => stepfun_output_in,
        Q => stepfun_output_out
    );

    

    COUNTER_PROCESS : process (rst, clk) is
    begin
        if rst = '1' then
            counter_internal <= 0;
        elsif rising_edge(clk) and enable_counter='1' and counter_internal <= 63 then
            counter_internal <= counter_internal + 1;
        end if;
    end process;

    counter <= counter_internal;

end arch;

-- 32 REGISTER

library ieee;
use ieee.numeric_bit.all;

entity reg32 is
    port (
        clk, rst, enable : in BIT;
        D : in bit_vector(31 downto 0);
        Q : out bit_vector(31 downto 0)
    );
end entity;

architecture arch of reg32 is
    signal dado : bit_vector(31 downto 0);
begin
    process (clk, rst)
    begin
        if rst = '1' then
            dado <= (others => '0');
        elsif falling_edge(clk) and enable = '1' then
            dado <= D;
        end if;
    end process;

    Q <= dado;
end arch;

-- STEPFUN REGISTER
use work.pkg.all;
library ieee;
use ieee.numeric_bit.all;

entity stepfun_register is
    port (
        clk   : in bit;
        rst : in bit;
        enable : in bit;
        D : in stepfun_array_type(7 downto 0);
        Q : out stepfun_array_type(7 downto 0)
    );
end entity;
architecture arch of stepfun_register is
    signal dado : stepfun_array_type(7 downto 0) := (
        x"5be0cd19", x"1f83d9ab", x"9b05688c", x"510e527f", x"a54ff53a", x"3c6ef372", x"bb67ae85", x"6a09e667"
    );
begin
    process (clk, rst)
    begin
    	if (rst = '1') then        	
            dado <= (x"5be0cd19", x"1f83d9ab", x"9b05688c", x"510e527f", x"a54ff53a", x"3c6ef372", x"bb67ae85", x"6a09e667");
        elsif (rising_edge(clk)) and enable = '1' then
            dado <= D;
        end if;
    end process;
    
    Q <= dado;
end arch ; -- arch

-- W REGISTER
use work.pkg.all;
library ieee;
use ieee.numeric_bit.all;

entity W_register is
    port (
        clk : in BIT;
        rst : in BIT;
        counter : in INTEGER;
        enable : in BIT;
        enable_parallel : in BIT;
        parallel_in : in bit_vector(511 downto 0);
        sequential_in : in bit_vector(31 downto 0);
        q : out W_array(63 downto 0)
    );
end entity;
architecture arch of W_register is
    signal W : W_array(63 downto 0);
begin

    process (clk, rst)
    begin
        if rst = '1' then
            for i in 0 to 63 loop
                W(i) <= (others => '0');
            end loop;

        elsif (rising_edge(clk)) and enable = '1' then
            if enable_parallel = '1' then
                for i in 0 to 15 loop
                    W(i + counter) <= parallel_in((i + 1) * 31 + i downto i * 31 + i);
                end loop;
            else
                W(counter) <= sequential_in;
            end if;
        end if;
    end process;

    q <= W(63 downto 0);

end architecture;