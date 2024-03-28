library ieee;
use ieee.numeric_bit.all;
use work.pkg.all;


entity multisteps_UC is
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

    type state_t is (inicio, calcula_W, calcula_KPW, fim);
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
      calcula_W when current_state=inicio or current_state=fim else
      calcula_KPW when current_state=calcula_W else
      fim   when current_state=calcula_KPW or done='1' else
      fim;
  
    -- Decodifica o estado para gerar sinais de controle
    -- load_W_inicial  <= '1' when current_state=somando else '0';
    enable_W <= '1' when current_state=inicio and current_state=calcula_W else '0';
    enable_parallel_W <= '1' when current_state=inicio and not (current_state=calcula_W) else '0';
    GENERATE_STEPFUN_INPUT : for i in 0 to 7 generate
        stepfun_input(i) <= H(i) when current_state=inicio else stepfun_output_out(i);
    end generate GENERATE_STEPFUN_INPUT;

    sigma1_input <= q_W(counter-2)  when counter>=16 else (others=>'0');
    sigma0_input <= q_W(counter-15) when counter>=16 else (others=>'0');
    sequential_in_W <= bit_vector(unsigned(sigma1_output) + unsigned(q_W(counter-7)) + unsigned(sigma0_output) + unsigned(q_W(counter-16)));

    enable_KPW <= '1' when current_state=calcula_W else '0';
    KPW_in <= bit_vector(unsigned(q_W(counter)) + unsigned(K(counter)));

    enable_stepfun_output <= '1' when current_state=fim else '0';

    done <= '1' when counter >= 64 else '0';
    
    GENERATE_HASO : for i in 0 to 7 generate
      haso((i+1)*31+i downto i*31+i) <= bit_vector(unsigned(stepfun_output_out(i)) + unsigned(H(i)));
    end generate GENERATE_HASO;

    
end architecture;
