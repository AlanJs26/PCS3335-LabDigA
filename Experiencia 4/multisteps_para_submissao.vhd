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


library ieee;
use ieee.numeric_bit.all;
use work.pkg.all;


entity multisteps_UC is
    port (
        sigma1_input, sigma0_input : out bit_vector(31 downto 0);
        sequential_in_W : out bit_vector(31 downto 0);
        q_W : in W_array(63 downto 0);
        KPW_in : out bit_vector(31 downto 0);
        stepfun_input : out stepfun_array_type(7 downto 0);
        done : out bit;
        enable_counter : out bit;
        enable_W, enable_parallel_W : out bit;
        enable_KPW : out bit;
        enable_stepfun_output : out bit;
        sigma0_output, sigma1_output : in bit_vector(31 downto 0);
        stepfun_output_out : in stepfun_array_type(7 downto 0);
        rst, clk : in bit;
        counter : in integer;
        haso : out bit_vector(255 downto 0)
    );
end multisteps_UC;

architecture arch of multisteps_UC is

    type K_array is array (NATURAL range <>) of bit_vector(31 downto 0);
    constant K : K_array :=
    (
    x"428a2f98", x"71374491", x"b5c0fbcf", x"e9b5dba5",
    x"3956c25b", x"59f111f1", x"923f82a4", x"ab1c5ed5",
    x"d807aa98", x"12835b01", x"243185be", x"550c7dc3",
    x"72be5d74", x"80deb1fe", x"9bdc06a7", x"c19bf174",
    x"e49b69c1", x"efbe4786", x"0fc19dc6", x"240ca1cc",
    x"2de92c6f", x"4a7484aa", x"5cb0a9dc", x"76f988da",
    x"983e5152", x"a831c66d", x"b00327c8", x"bf597fc7",
    x"c6e00bf3", x"d5a79147", x"06ca6351", x"14292967",
    x"27b70a85", x"2e1b2138", x"4d2c6dfc", x"53380d13",
    x"650a7354", x"766a0abb", x"81c2c92e", x"92722c85",
    x"a2bfe8a1", x"a81a664b", x"c24b8b70", x"c76c51a3",
    x"d192e819", x"d6990624", x"f40e3585", x"106aa070",
    x"19a4c116", x"1e376c08", x"2748774c", x"34b0bcb5",
    x"391c0cb3", x"4ed8aa4a", x"5b9cca4f", x"682e6ff3",
    x"748f82ee", x"78a5636f", x"84c87814", x"8cc70208",
    x"90befffa", x"a4506ceb", x"bef9a3f7", x"c67178f2"
    );

    type H_array is array (NATURAL range <>) of bit_vector(31 downto 0);
    constant H : H_array :=
    (
    x"6a09e667", x"bb67ae85", x"3c6ef372", x"a54ff53a", x"510e527f", x"9b05688c", x"1f83d9ab", x"5be0cd19"
    );
    
    constant t : integer := 16;

    signal q_W_atual, q_W_0 : bit_vector(31 downto 0);

    type state_t is (inicio, calcula_W, calcula_KPW, calcula_stepfun, fim);
    signal next_state, current_state: state_t;  
begin        

    MULTISTEPS_UC_PROCESS: process(clk, rst)
    begin
      if rst='1' then
        current_state <= inicio;
      elsif (rising_edge(clk)) then
        current_state <= next_state;
      end if;
    end process;
    
    
  
    -- Logica de proximo estado
    next_state <=
      calcula_W when current_state=inicio or current_state=calcula_stepfun else
      calcula_KPW when current_state=calcula_W else
      calcula_stepfun   when current_state=calcula_KPW and counter<=62 else
      fim;
  

    enable_W <= '1' when (current_state=inicio or current_state=calcula_W) and (counter<=0 or counter>=16) else '0';
    enable_parallel_W <= '1' when (current_state=inicio or current_state=calcula_W) and counter <= 0 else '0';
    GENERATE_STEPFUN_INPUT : for i in 0 to 7 generate
        stepfun_input(i) <= stepfun_output_out(i);
    end generate GENERATE_STEPFUN_INPUT;

    sigma1_input <= q_W(counter-2)  when counter>=16 else (others=>'0');
    sigma0_input <= q_W(counter-15) when counter>=16 else (others=>'0');
    sequential_in_W <= bit_vector(unsigned(sigma1_output) + unsigned(q_W(counter-7)) + unsigned(sigma0_output) + unsigned(q_W(counter-16))) when counter>=16 else 
                       (others=>'0');

    enable_KPW <= '1' when current_state=calcula_W else '0';
    KPW_in <= bit_vector(unsigned(q_W(counter)) + unsigned(K(counter))) when counter>=0 and counter<=63 else 
              (others=>'0');
    
    q_W_atual <= q_W(counter) when counter>=0 and counter <= 15 else
    			 q_W(15)      when counter>=0 else
              	 (others=>'0');
    q_W_0 <= q_W(t-2) when counter>=16 else (others=>'0');

    enable_stepfun_output <= '1' when current_state=calcula_stepfun or (current_state=fim and counter<=63) else '0';
    enable_counter <= '1' when current_state=calcula_stepfun or current_state=fim else '0';

    done <= '1' when current_state=fim else '0';
    
    GENERATE_HASO : for i in 0 to 7 generate
      haso((i+1)*31+i downto i*31+i) <= bit_vector(unsigned(stepfun_output_out(i)) + unsigned(H(i)));
    end generate GENERATE_HASO;

    
end architecture;



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
            q_W : out W_array(63 downto 0);
            KPW_in : in bit_vector(31 downto 0);
            stepfun_input : in stepfun_array_type(7 downto 0);
            done, rst, clk : in bit;
            enable_W, enable_parallel_W : in bit;
            enable_KPW : in bit;
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
            sequential_in_W : out bit_vector(31 downto 0);
            q_W : in W_array(63 downto 0);
            KPW_in : out bit_vector(31 downto 0);
            stepfun_input : out stepfun_array_type(7 downto 0);
            done : out bit;
            enable_W, enable_parallel_W : out bit;
            enable_KPW : out bit;
            enable_counter : out bit;
            enable_stepfun_output : out bit;
            sigma0_output, sigma1_output : in bit_vector(31 downto 0);
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
    signal q_W : W_array(63 downto 0);
    
    signal KPW_in : bit_vector(31 downto 0);
    signal enable_counter : bit;


    signal enable_W, enable_parallel_W, enable_KPW, enable_stepfun_output : bit;
    signal done_internal : bit;
    signal not_clk : bit;
    
    begin

MULTISTEPS_FD_INST: multisteps_FD port map(
    msgi => msgi,
    sigma1_input => sigma1_input,
    sigma0_input => sigma0_input,
    sequential_in_W => sequential_in_W,
    q_W => q_W,
    KPW_in => KPW_in,
    stepfun_input => stepfun_input,
    rst => rst,
    done => done_internal,
    clk => not_clk,
    enable_W => enable_W,
    enable_parallel_W => enable_parallel_W,
    enable_KPW => enable_KPW,
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
    sequential_in_W => sequential_in_W,
    q_W => q_W,
    KPW_in => KPW_in,
    stepfun_input => stepfun_input,
    done => done_internal,
    enable_W => enable_W,
    enable_parallel_W => enable_parallel_W,
    enable_KPW => enable_KPW,
    enable_stepfun_output => enable_stepfun_output,
    sigma0_output => sigma0_output,
    sigma1_output => sigma1_output,
    stepfun_output_out => stepfun_output_out,
    enable_counter => enable_counter,
    rst => rst,
    clk => clk,
    counter => counter,
    haso => haso
);

    DONE_PROCESS : process (done_internal, clk)
    begin
      if rising_edge(clk) then
          if done_internal='1' and counter>=64 then
              done<='1';	
          else 
              done<='0';
          end if;
      end if;
    end process;
    
-- done <= done_internal;
not_clk <= not clk;

end arch ; -- arch