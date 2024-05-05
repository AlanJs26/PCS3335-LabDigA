library IEEE;
use IEEE.numeric_bit.all;

entity multisteps is
    port (
        clk, rst: in bit;
        msgi: in bit_vector(511 downto 0);
        haso: out bit_vector(255 downto 0);
        done: out bit
    );
end multisteps;

architecture arch_multisteps of multisteps is

    component adder32 is 
        port ( 
            a, b: in bit_vector(31 downto 0);
            r: out  bit_vector(31 downto 0) 
        );
    end component;

	component stepfun is
    	port (
        	ai, bi, ci, di, ei, fi, gi, hi: in bit_vector(31 downto 0);
        	kpw: in bit_vector(31 downto 0);
        	ao, bo, co, do, eo, fo, go, ho:  out bit_vector(31 downto 0)
    	);
	end component;
    
    component sigma0 is
    port (
        x: in bit_vector(31 downto 0);
        q: out bit_vector(31 downto 0)
    );
	end component;
    
    component sigma1 is
    port (
        x: in bit_vector(31 downto 0);
        q: out bit_vector(31 downto 0)
    );
	end component;


    type state_type is (IDLE, RUN, ENDED);
    signal present_state, next_state : state_type;

	signal s_done: bit;
    signal counter: integer range 0 to 63;
    signal s_msgi: bit_vector(511 downto 0);
    
    signal s_ai, s_bi, s_ci, s_di, s_ei, s_fi, s_gi, s_hi, s_kpw: bit_vector(31 downto 0);
    signal s_ao, s_bo, s_co, s_do, s_eo, s_fo, s_go, s_ho: bit_vector(31 downto 0);

    signal sigma0_out, sigma1_out, s_sum0, s_sum1, s_W: bit_vector(31 downto 0);

    type H_vector is array (NATURAL range <>) of bit_vector(31 downto 0);
    constant H: H_vector := (x"6a09e667", x"bb67ae85", x"3c6ef372", x"a54ff53a", x"510e527f", x"9b05688c", x"1f83d9ab", x"5be0cd19");
    signal s_H: H_vector(7 downto 0);

    type K_vector is array (NATURAL range <>) of bit_vector(31 downto 0);
    constant K: K_vector := 
        (
        x"428a2f98", x"71374491", x"b5c0fbcf", x"e9b5dba5", x"3956c25b", x"59f111f1", x"923f82a4", x"ab1c5ed5",
        x"d807aa98", x"12835b01", x"243185be", x"550c7dc3", x"72be5d74", x"80deb1fe", x"9bdc06a7", x"c19bf174",
        x"e49b69c1", x"efbe4786", x"0fc19dc6", x"240ca1cc", x"2de92c6f", x"4a7484aa", x"5cb0a9dc", x"76f988da",
        x"983e5152", x"a831c66d", x"b00327c8", x"bf597fc7", x"c6e00bf3", x"d5a79147", x"06ca6351", x"14292967",
        x"27b70a85", x"2e1b2138", x"4d2c6dfc", x"53380d13", x"650a7354", x"766a0abb", x"81c2c92e", x"92722c85",
        x"a2bfe8a1", x"a81a664b", x"c24b8b70", x"c76c51a3", x"d192e819", x"d6990624", x"f40e3585", x"106aa070",
        x"19a4c116", x"1e376c08", x"2748774c", x"34b0bcb5", x"391c0cb3", x"4ed8aa4a", x"5b9cca4f", x"682e6ff3",
        x"748f82ee", x"78a5636f", x"84c87814", x"8cc70208", x"90befffa", x"a4506ceb", x"bef9a3f7", x"c67178f2"
        );
 
    type W_vector is array (NATURAL range <>) of bit_vector(31 downto 0);
    signal W: W_vector(63 downto 0);
    
    signal K_0, W_0, W_2, W_7, W_15, W_16: bit_vector(31 downto 0);

begin
    
    next_state <= IDLE when (rst = '1') else
                  RUN when (present_state = IDLE and rst = '0') else
                  RUN when (present_state = RUN and s_done = '0') else
                  ENDED when (present_state = RUN and s_done = '1') else
                  ENDED when (present_state = ENDED and rst = '0') else 
                  IDLE;  
    
    UC: process(clk, rst) is
    begin  

        if (rising_edge(clk)) then
            if (rst = '1') then
                present_state <= IDLE;
            elsif (rst = '0') then
                present_state <= next_state;
            end if;
        end if;

        if (falling_edge(clk)) then

            if (present_state = IDLE) then
                s_done <= '0';
                counter <= 0;
                
                s_ai <= H(0);
                s_bi <= H(1);
                s_ci <= H(2);
                s_di <= H(3);
                s_ei <= H(4);
                s_fi <= H(5);
                s_gi <= H(6);
                s_hi <= H(7);
                
                s_msgi <= msgi;
                W(0) <= msgi(31 downto 0);
                

            elsif (present_state = RUN) then

                if (counter < 15) then
                    W(counter + 1) <= s_msgi(63 downto 32);
                    s_msgi <= s_msgi srl 32;
                elsif (counter >= 15 and counter < 63) then
                    W(counter + 1) <= s_W;
                end if;
        

                if (counter < 63) then
                    counter <= counter + 1;

                    s_ai <= s_ao;
                    s_bi <= s_bo;
                    s_ci <= s_co;
                    s_di <= s_do;
                    s_ei <= s_eo;
                    s_fi <= s_fo;
                    s_gi <= s_go;
                    s_hi <= s_ho;
                elsif (counter = 63) then
                    s_done <= '1';
                    
                end if;
        	end if;
        end if;
    end process;

	K_0 <= K(counter);

	W_0 <= W(counter);
	W_2 <= W(counter - 1) when counter >= 15 else
    	   W(counter);
    W_7 <= W(counter - 6) when counter >= 15 else
    	   W(counter);
	W_15 <= W(counter - 14) when counter >= 15 else
    		W(counter);
    W_16 <= W(counter - 15) when counter >= 15 else
    		W(counter);


    SIGMA0CALC: sigma0 port map (W_15, sigma0_out);
    SIGMA1CALC: sigma1 port map (W_2, sigma1_out);
    SUM0: adder32 port map (sigma0_out, sigma1_out, s_sum0);
    SUM1: adder32 port map (W_7, s_sum0, s_sum1);
    SUM2: adder32 port map (W_16, s_sum1, s_W);

    CALCKPW1: adder32 port map (W_0, K_0, s_kpw);

    CALCH0: adder32 port map (H(0), s_ao, s_H(0));
    CALCH1: adder32 port map (H(1), s_bo, s_H(1));
    CALCH2: adder32 port map (H(2), s_co, s_H(2));
    CALCH3: adder32 port map (H(3), s_do, s_H(3));
    CALCH4: adder32 port map (H(4), s_eo, s_H(4));
    CALCH5: adder32 port map (H(5), s_fo, s_H(5));
    CALCH6: adder32 port map (H(6), s_go, s_H(6));
    CALCH7: adder32 port map (H(7), s_ho, s_H(7));

    STEPFUN_CONNECT: stepfun port map (s_ai, s_bi, s_ci, s_di, s_ei, s_fi, s_gi, s_hi, s_kpw, s_ao, s_bo, s_co, 	s_do, s_eo, s_fo, s_go, s_ho); 
    done <= s_done;
    haso <= s_H(7) & s_H(6) & s_H(5) & s_H(4) & s_H(3) & s_H(2) & s_H(1) & s_H(0); 

end architecture;


library IEEE;
use IEEE.numeric_bit.all;

entity adder32 is
    port (
        a, b: in bit_vector(31 downto 0);
        r: out  bit_vector(31 downto 0) 
    );
end entity adder32;

architecture Behavioral of adder32 is
begin
    r <= bit_vector(unsigned(a) + unsigned(b));
end architecture Behavioral;