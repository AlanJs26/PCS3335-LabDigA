
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

-------------------------------------------------------------------------------
-- Author: Alan Jose dos Santos (alanjose@usp.br)
-- Module Name: operators
-- Description:
-- VHDL module that contains a bunch of math operators (32b)
-------------------------------------------------------------------------------

entity ch is
	port(
		x,y,z: in  bit_vector(31 downto 0);
		q:     out bit_vector(31 downto 0)
	);
end ch;
architecture comportamental of ch is
begin
q <= (x and y) xor ((not x) and z);
end comportamental;
		

entity maj is
	port (
		x,y,z: in bit_vector(31 downto 0);
		q: out bit_vector(31 downto 0)
	);
end maj;
architecture comportamental of maj is
begin
q <= (z and y) xor (x and z) xor (y and x);
end comportamental;

entity sum0 is
	port (
		x: in bit_vector(31 downto 0);
		q: out bit_vector(31 downto 0)
	);
end sum0;
architecture comportamental of sum0 is
begin 
q <= (x ror 2) xor (x ror 13) xor (x ror 22);
end comportamental;

entity sum1 is
	port (
		x: in bit_vector(31 downto 0);
		q: out bit_vector(31 downto 0)
	);
end sum1;
architecture comportamental of sum1 is
begin
q <= (x ror 6) xor (x ror 11) xor (x ror 25);
end comportamental;

entity sigma0 is
	port (
		x: in bit_vector(31 downto 0);
		q: out bit_vector(31 downto 0)
	);
end sigma0;
architecture comportamental of sigma0 is
begin
q <= (x ror 7) xor (x ror 18) xor (x srl 3);
end comportamental;

entity sigma1 is
	port (
		x: in bit_vector(31 downto 0);
		q: out bit_vector(31 downto 0)
	);
end sigma1;
architecture comportamental of sigma1 is
begin
q <= (x ror 17) xor (x ror 19) xor (x srl 10);
end comportamental;

------------- SOMADOR -------------

library ieee;
use ieee.numeric_bit.all;

entity somador is
    port (
        a, b : in bit_vector(31 downto 0);
        q : out bit_vector(31 downto 0)
    );
end somador;
architecture ARCH_SOMADOR of somador is
    signal soma : unsigned(31 downto 0);
begin
    soma <= unsigned(a) + unsigned(b);

    q <= bit_vector(soma);
end ARCH_SOMADOR; -- ARCH_SOMADOR

entity stepfun is
    port (
        ai, bi, ci, di, ei, fi, gi, hi : in bit_vector(31 downto 0);
        kpw : in bit_vector(31 downto 0);
        ao, bo, co, do, eo, fo, go, ho : out bit_vector(31 downto 0)
    );
end stepfun;
architecture ARCH_STEPFUN of stepfun is

    ------------- COMPONENTS -------------

    component sum0 is
        port (
            x : in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end component;
    component sum1 is
        port (
            x : in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end component;
    component ch is
        port (
            x, y, z : in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end component;
    component maj is
        port (
            x, y, z : in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end component;
    component somador is
        port (
            a, b : in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end component;

    ------------- SIGNALS -------------

    signal sum0_result,
    sum1_result,
    ch_result,
    maj_result : bit_vector(31 downto 0);

    signal somador1_result,
    somador2_result,
    somador3_result,
    somador4_result,
    somador5_result,
    somador6_result : bit_vector(31 downto 0);
begin

    CH_MAP : ch port map(ei, fi, gi, ch_result);
    SUM1_MAP : sum1 port map(ei, sum1_result);
    MAJ_MAP : maj port map(ai, bi, ci, maj_result);
    SUM0_MAP : sum0 port map(ai, sum0_result);

    SOMADOR1_MAP : somador port map(hi, kpw, somador1_result);
    SOMADOR2_MAP : somador port map(ch_result, somador1_result, somador2_result);
    SOMADOR3_MAP : somador port map(sum1_result, somador2_result, somador3_result);
    SOMADOR4_MAP : somador port map(maj_result, somador3_result, somador4_result);
    SOMADOR5_MAP : somador port map(sum0_result, somador4_result, somador5_result);
    SOMADOR6_MAP : somador port map(di, somador3_result, somador6_result);
    ao <= somador5_result;
    bo <= ai;
    co <= bi;
    do <= ci;
    eo <= somador6_result;
    fo <= ei;
    go <= fi;
    ho <= gi;

end ARCH_STEPFUN; -- ARCH_STEPFUN

library IEEE;
use IEEE.numeric_bit.all;


entity counter4bits is
    generic(
        width: natural := 4
    );
    port(
        clk: in bit;
        rst: in bit;
        count: out bit_vector(width-1 downto 0)
    );
end entity;

architecture libarch of counter4bits is
signal countsig: unsigned(width-1 downto 0);
signal fairClock: bit;
signal lastrst:bit;
begin


proc: process(clk,rst)
begin
    if(rst /= lastrst) then
        countsig <= (others => '0');
        lastrst <= rst;
    elsif (clk'event and clk = '1') then
        countsig <= countsig + 1;
    end if;
end process;

count <= bit_vector(countsig);
    
end architecture;



library IEEE;
use IEEE.numeric_bit.all;

entity serial_in_entity is
    generic (
        polarity : boolean := true;
        width : natural := 8;
        parity : natural := 1;
        clock_mul : positive := 4
    );
    port (
        clock, reset, start, serial_data : in bit;
        done, parity_bit : out bit;
        parallel_data : out bit_vector(width - 1 downto 0)
    );
end entity;

architecture libarch of serial_in_entity is
    signal transitionflag : bit_vector(5 downto 0);
    -- 00001 rst, 00010 rest->strt, 00100 strt->poll, 01000 poll->poll, 10000 poll->rest
    signal state : bit_vector(1 downto 0);
    -- 00 rest, 01 start, 10 poll

    --signal started:bit := '0'; --set to 1 when strt is run, set to 0 when process ends
    signal last4count : bit := '0';

    signal count1 : bit_vector(15 downto 0);
    signal clk19200, triggerc1, rstcount1 : bit;

    signal datareg : bit_vector(width downto 0);
    --debug
    signal polling : bit;
    --end debug
    signal paralaux : bit_vector(width downto 0);
    signal doneaux : bit;
    signal count2 : bit_vector(1 downto 0);
    component counter4bits is
        generic (
            width : natural := 4
        );
        port (
            clk : in bit;
            rst : in bit;
            count : out bit_vector(width - 1 downto 0)
        );
    end component;
begin
    counter1 : counter4bits
        generic map(width => 16)
        port map(
            clk => clk19200,
            rst => rstcount1,
            count => count1
        );
    counter2 : counter4bits
        generic map(width => 2)
        port map(
            clk => clk19200,
            rst => rstcount1,
            count => count2
        );

    clk19200 <= clock;
    transitionflag <= "000001" when reset = '1' else
        "000010" when (state = "00" and start = '1' and serial_data = '0') else
        "000100" when (state = "00" and ((start = '1' and serial_data = '1') or (start = '0'))) else --resting state
        serial_data & "01000" when (state = "10" and count2 = "01") else --when counter is a ((multiple of four) + 1)
        "010000" when (state = "10" and unsigned(count1) >= 4 * (width + 2)) else
        (others => '0');
    stateproc : process (transitionflag, clk19200)
    begin
        if (clk19200'event and clk19200 = '1') then
            case transitionflag(4 downto 0) is
                when "00001" => --reset transition 
                    state <= "00";
                    rstcount1 <= not rstcount1;
                    doneaux <= '0';
                when "00010" => --start transmission 
                    doneaux <= '0';
                    state <= "10";
                when "00100" => --idling 
                    rstcount1 <= not rstcount1;
                when "01000" => --poll data 
                    state <= "10";
                    polling <= transitionflag(5);
                    datareg <= datareg(width - 1 downto 0) & transitionflag(5);
                when "10000" => --stop data polling when counter hits limit 
                    state <= "00";
                    doneaux <= '1';
                when others =>
            end case;
        end if;

    end process;

    done <= doneaux;

    paralaux <= datareg(width downto 0) when (doneaux = '1') else
        paralaux;

    parallel_data <= paralaux(width downto 1);
    parity_bit <= paralaux(0);

end architecture;

library ieee;
use ieee.numeric_bit.all;

entity serial_out_entity is
    generic (
        POLARITY : BOOLEAN := TRUE;
        WIDTH : NATURAL := 7;
        PARITY : NATURAL := 1;
        STOP_BITS : NATURAL
    );
    port (
        clock, reset, tx_go : in BIT;
        data : in bit_vector(WIDTH - 1 downto 0);
        tx_done : out BIT;
        serial_o : out BIT
    );
end serial_out_entity;

architecture serial_out_entity_arch of serial_out_entity is

    signal counter : INTEGER := -1;

    component parity_def is
        generic (
            POLARITY : BOOLEAN := TRUE;
            WIDTH : NATURAL := 7;
            PARITY : NATURAL := 1
        );
        port (
            data : in bit_vector(WIDTH - 1 downto 0);
            q : out bit
        );
    end component;

    signal data_reg : bit_vector(WIDTH - 1 downto 0);
 
    signal parity_q : bit;
    signal high_low : bit;
    signal tx_done_s : bit;
    signal ended : bit := '1';

begin
    PARITY_DEF_INSTANCE : parity_def 
        generic map(POLARITY => POLARITY, WIDTH => WIDTH, PARITY => PARITY)
        port map(data, parity_q);

    high_low <= '1' when POLARITY=true else '0';

    tx_done <= tx_done_s;
    
    identifier : process (clock, reset)
    begin

        if reset = '1' then
            serial_o <= high_low;
            tx_done_s <= '0';
            counter <= -1;
            data_reg <= data;
            ended <= '0';

        elsif rising_edge(clock) and tx_go='0' and counter<0 then        
            serial_o <= high_low; -- REPOUSO
            counter <= -1;
            data_reg <= data;
            tx_done_s <= ended;
        elsif rising_edge(clock) and (tx_go='1' or counter>=0) then
            tx_done_s <= '0';
            ended <= '0';

            counter <= counter + 1;

            if counter < 0 then -- START
                serial_o <= not high_low;
                tx_done_s <= '0';
                data_reg <= data;

            elsif counter >= 0 and counter <= WIDTH - 1 then -- DADOS
                if POLARITY=TRUE then
                    serial_o <= data_reg(counter);
                else
                    serial_o <= not data_reg(counter);            
                end if;
            elsif counter <= WIDTH then -- PARIDADE
                serial_o <= parity_q;
            elsif counter <= WIDTH + STOP_BITS then -- STOP

                serial_o <= high_low;
                data_reg <= data;
            else
                tx_done_s <= '1';
                counter <= -1;
                ended <= '1';
            end if;
        
        end if;

    end process;
end serial_out_entity_arch; -- serial_out_entity_arch




library ieee;
use ieee.numeric_bit.all;

entity sha256_1b is
    port (
        clock, reset : in bit;
        serial_in : in bit;
        serial_out : out bit
    );
end sha256_1b;

architecture sha256_1b_arch of sha256_1b is
    ---------------------------------------- MARK: Serial In --------------------------------------------------  
    constant POLARITY : boolean := TRUE;
    constant WIDTH : natural := 8;
    constant PARITY : natural := 1;
    constant CLOCK_MUL : positive := 4;
    constant STOP_BITS : natural := 2;
    
    component serial_in_entity is
        generic (
            POLARITY : boolean;
            WIDTH : natural;
            PARITY : natural;
            CLOCK_MUL : positive
        );
        port (
            clock, reset, start, serial_data : in bit;
            done, parity_bit : out bit;
            parallel_data : out bit_vector(WIDTH - 1 downto 0)
        );
    end component;

    signal reset_serial_in, start, serial_data_in, done_serial_in, parity_bit : bit;
    signal parallel_data : bit_vector(WIDTH - 1 downto 0);
    ---------------------------------------- Serial In -------------------------------------------------------- 
    ---------------------------------------- MARK: Serial Out ------------------------------------------------- 
    component serial_out_entity is
        generic (
            POLARITY : boolean;
            WIDTH : natural;
            PARITY : natural;
            STOP_BITS : natural
        );
        port (
            clock, reset, tx_go : in bit;
            tx_done : out bit;
            data : in bit_vector(WIDTH - 1 downto 0);
            serial_o : out bit
        );
    end component;

        signal reset_serial_out, tx_go, done_serial_out, serial_data_out : bit;
    ---------------------------------------- Serial Out ------------------------------------------------------- 
    ---------------------------------------- MARK: Multisteps ------------------------------------------------- 
    component multisteps is
        port (
            clk, rst : in bit;
            msgi : in bit_vector(511 downto 0);
            haso : out bit_vector(255 downto 0);
            done : out bit
        );
    end component;

    signal msgi : bit_vector(511 downto 0);  
    signal haso : bit_vector(255 downto 0);
    signal done_multisteps, reset_multisteps : bit;
    ---------------------------------------- Multisteps ------------------------------------------------------- 
    ---------------------------------------- MARK: Clock Diviser ----------------------------------------------  
    component clock_diviser_2 is
        port (
            reset : in bit;
            clk_in : in bit;
            clk_out : out bit
        );
    end component;

    signal clock_div_2, clock_div_4 : bit;
    ---------------------------------------- Clock Diviser ----------------------------------------------------
    ---------------------------------------- MARK: United States of Smash -------------------------------------  
    type state_t is (wait_start, recebendo, calculando, enviando);
    signal next_state, current_state : state_t;
    ---------------------------------------- United States of Smash -------------------------------------------  


    component bit_reverser is
        generic (
          WIDTH : positive
        );
        port (
          i_data : in bit_vector(WIDTH-1 downto 0);
          o_data : out bit_vector(WIDTH-1 downto 0)
        );
      end component;
    signal reversed_parallel_data : bit_vector(WIDTH - 1 downto 0);


begin
    ---------------------------------------- MARK: Port Maps e Signals ---------------------------------------- 
    SERIAL_IN_INSTANCE : serial_in_entity
    generic map(
        POLARITY => POLARITY,
        WIDTH => WIDTH,
        PARITY => PARITY,
        CLOCK_MUL => CLOCK_MUL
    )
    port map(
        clock, reset_serial_in, start, serial_data_in,
        done_serial_in, parity_bit,
        parallel_data
    );

    CLOCK_DIVISER_2_INSTANCE : clock_diviser_2
    port map(
        '0', clock, clock_div_2
    );
    CLOCK_DIVISER_4_INSTANCE : clock_diviser_2
    port map(
        '0', clock_div_2, clock_div_4
    );
    MULTISTEPS_INSTANCE : multisteps
    port map(
        clock, reset_multisteps,
        msgi,
        haso, done_multisteps
    );
    SERIAL_OUT_INSTANCE : serial_out_entity
    generic map (
        POLARITY => POLARITY,
        WIDTH => WIDTH,
        PARITY => PARITY,
        STOP_BITS => STOP_BITS
    )
    port map (
        clock_div_4, reset_serial_out, tx_go,
        done_serial_out,
        haso(WIDTH-1 downto 0),
        serial_data_out
    );

    BIT_REVERSER_INSTANCE : bit_reverser 
    generic map(
        WIDTH => WIDTH
    )
    port map(
        parallel_data, reversed_parallel_data
    );

    ---------------------------------------- Port Maps e Signals ---------------------------------------------- 
    ---------------------------------------- MARK: MAQUINA DE ESTADOS ----------------------------------------- 
    STATES_PROCESS : process (clock, reset)
    begin
        if reset = '1' then
            current_state <= wait_start;      
        elsif (rising_edge(clock)) then
            current_state <= next_state;
        end if;
    end process;

    -- Logica de proximo estado
    next_state <=
        wait_start when current_state = enviando and done_serial_out = '1' else
        recebendo when current_state = wait_start and serial_in = '0' else
        calculando when current_state = recebendo and done_serial_in='1' else
        enviando when current_state = calculando and done_multisteps='1' else --se der merda, pode ser aqui no done kkkk (precisa ser sempre 1, nao verificamos isso)
        next_state;
    ---------------------------------------- MAQUINA DE ESTADOS -----------------------------------------------
    ---------------------------------------- MARK: SINAIS DE CONTROLE -----------------------------------------
    start <= '0' when reset='1' else '1';
    tx_go <= '0' when reset='1' else '1';

    serial_out <= serial_data_out;
    serial_data_in <= serial_in;
    
    reset_serial_in <= reset;
    reset_serial_out <= '0' when current_state = enviando else '1';
    reset_multisteps <= '1' when current_state = recebendo else '0';
        
    MSGI_GENERATE : for i in 0 to 63 GENERATE
        msgi((i+1)*7+i downto i*7+i) <= reversed_parallel_data;
    end GENERATE;
    ---------------------------------------- SINAIS DE CONTROLE -----------------------------------------------

end architecture;

-- BIT REVERSER

entity bit_reverser is
    generic (
      WIDTH : positive
    );
    port (
      i_data : in bit_vector(WIDTH-1 downto 0);
      o_data : out bit_vector(WIDTH-1 downto 0)
    );
  end entity bit_reverser;
  
  architecture arch of bit_reverser is
  begin
    process(i_data)
    begin
      for i in 0 to WIDTH-1 loop
        o_data(i) <= i_data(WIDTH-1-i);
      end loop;
    end process;
  end architecture;

-- This module is for a basic divide by 2 in VHDL.
entity clock_diviser_2 is
  port (
    reset : in bit;
    clk_in : in bit;
    clk_out : out bit
  );
end clock_diviser_2;

architecture div2_arch of clock_diviser_2 is
  signal clk_state : bit;

begin
  process (clk_in, reset)
  begin
    if reset = '1' then
      clk_state <= '0';
    elsif clk_in'event and clk_in = '1' then
      clk_state <= not clk_state;
    end if;
  end process;

  clk_out <= clk_state;

end div2_arch;

----------------------------------------PARIDADE----------------------------------------

entity parity_def is
    generic (
        POLARITY : BOOLEAN := TRUE;
        WIDTH : NATURAL := 7;
        PARITY : NATURAL := 1
    );
    port (
        data : in bit_vector(WIDTH - 1 downto 0);
        q : out bit
    );
end entity;

architecture parity_def_arch of parity_def is
    signal paridade : bit_vector(WIDTH-2 downto 0);
    signal saida : bit;
begin
    
    paridade(0) <= data(0) xor data(1);
    PARIDADE_GENERATE : for i in 1 to WIDTH-2 generate
        paridade(i) <= paridade(i-1) xor data(i+1);
    end generate;

    saida <= paridade(WIDTH-2) when PARITY=1 else not paridade(WIDTH-2);

    q <= saida when POLARITY=TRUE else not saida;
end parity_def_arch ; -- parity_def_arch
