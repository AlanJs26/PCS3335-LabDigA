
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

library IEEE;
use IEEE.numeric_bit.all;

entity serial_in_entity is
    generic (
        POLARITY : boolean := true;
        WIDTH : natural := 8;
        PARITY : natural := 1;
        CLOCK_MUL : positive := 4
    );
    port (
        clock, reset, start, serial_data : in bit;
        done, parity_bit, parity_calculado : out bit;
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

    component parity_def is
        generic (
            POLARITY : BOOLEAN;
            WIDTH : NATURAL;
            PARITY : NATURAL
        );
        port (
            data : in bit_vector(WIDTH - 1 downto 0);
            q : out bit
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

    PARITY_DEF_INSTANCE : parity_def 
        generic map(POLARITY => POLARITY, WIDTH => WIDTH, PARITY => PARITY)
        port map(paralaux(width downto 1), parity_calculado);

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

    parallel_data <= not paralaux(width downto 1);
    parity_bit <= paralaux(0);

end architecture;

library ieee;
use ieee.numeric_bit.all;

entity serial_out_entity is
    generic (
        POLARITY : BOOLEAN;
        WIDTH : NATURAL;
        PARITY : NATURAL;
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

entity sha256 is
    port (
        clock, reset : in bit;
        serial_in : in bit;
        serial_out : out bit
    );
end sha256;

architecture sha256_arch of sha256 is
    ---------------------------------------- MARK: Serial In --------------------------------------------------  
    constant POLARITY : boolean := TRUE;
    constant SERIAL_IN_WIDTH : natural := 8;
    constant SERIAL_OUT_WIDTH : natural := 8;
    constant PARITY : natural := 1;
    constant CLOCK_MUL : positive := 4;
    constant STOP_BITS : natural := 2;
    constant INPUT_WORDS : natural := 64;
    constant OUTPUT_WORDS : natural := 32;

    
    component serial_in_entity is
        generic (
            POLARITY : boolean;
            WIDTH : natural;
            PARITY : natural;
            CLOCK_MUL : positive
        );
        port (
            clock, reset, start, serial_data : in bit;
            done, parity_bit, parity_calculado : out bit;
            parallel_data : out bit_vector(SERIAL_IN_WIDTH - 1 downto 0)
        );
    end component;

    signal reset_serial_in, start, serial_data_in, done_serial_in, parity_bit, parity_calculado : bit;
    signal parallel_data : bit_vector(SERIAL_IN_WIDTH - 1 downto 0);
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
            data : in bit_vector(SERIAL_OUT_WIDTH - 1 downto 0);
            serial_o : out bit
        );
    end component;

    signal reset_serial_out, tx_go, done_serial_out, serial_data_out : bit;
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
    ---------------------------------------- MARK: Clock Diviser ----------------------------------------------  
    component clock_diviser_2 is
        port (
            reset : in bit;
            clk_in : in bit;
            clk_out : out bit
        );
    end component;

    signal clock_div_2, clock_div_4 : bit;

    ---------------------------------------- MARK: Shift Register ----------------------------------
    component shift_register is
        generic (
            WIDTH_IN : natural;
            WIDTH : natural
        );
        port (
            clk, reset, enable : in bit;
            data_in : in bit_vector(WIDTH_IN - 1 downto 0);
            data_out : out bit_vector(WIDTH - 1 downto 0)
        );
    end component;

    signal data_in_register : bit_vector(SERIAL_IN_WIDTH - 1 downto 0);
    signal enable_register, reset_register : bit;
    signal data_out_register : bit_vector((INPUT_WORDS*SERIAL_IN_WIDTH) - 1 downto 0);

    ---------------------------------------- MARK: Bit Reverser ----------------------------------
    component bit_reverser is
        generic (
            WIDTH : positive
        );
        port (
            i_data : in bit_vector(WIDTH-1 downto 0);
            o_data : out bit_vector(WIDTH-1 downto 0)
        );
        end component;

    signal reversed_parallel_data : bit_vector(SERIAL_IN_WIDTH-1 downto 0);

    ---------------------------------------- MARK: Estados -------------------------------------  
    type state_t is (wait_start, recebendo, guardando, calculando, enviando);
    signal next_state, current_state : state_t;

    ---------------------------------------- MARK: Sinais -------------------------------------  
    
    signal send_counter : integer := 0;


begin
    ---------------------------------------- MARK: Port Maps e Signals ---------------------------------------- 
    SERIAL_IN_INSTANCE : serial_in_entity
    generic map(
        POLARITY => FALSE,
        WIDTH => SERIAL_IN_WIDTH,
        PARITY => PARITY,
        CLOCK_MUL => CLOCK_MUL
    )
    port map(
        clock, reset_serial_in, start, serial_data_in,
        done_serial_in, parity_bit, parity_calculado,
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
        WIDTH => SERIAL_OUT_WIDTH,
        PARITY => 0,
        STOP_BITS => STOP_BITS
    )
    port map (
        clock_div_4, reset_serial_out, tx_go,
        done_serial_out,
        haso(SERIAL_OUT_WIDTH*(((OUTPUT_WORDS-1)-send_counter)+1)-1 downto ((OUTPUT_WORDS-1)-send_counter)*SERIAL_OUT_WIDTH),
        serial_data_out
    );

    BIT_REVERSER_INSTANCE : bit_reverser 
    generic map(
        WIDTH => SERIAL_IN_WIDTH
    )
    port map(
        parallel_data, reversed_parallel_data
    );
    SHIFT_REGISTER_INSTANCE : shift_register
    generic map(
        WIDTH_IN => SERIAL_IN_WIDTH,
        WIDTH => INPUT_WORDS*SERIAL_IN_WIDTH
    )
    port map(
        clock, reset_register, enable_register,
        data_in_register,
        data_out_register
    );

    ---------------------------------------- MARK: MAQUINA DE ESTADOS ----------------------------------------- 
    STATES_PROCESS : process (clock, reset)
    begin
        if reset = '1' then
            current_state <= wait_start;
        elsif rising_edge(clock) then
            current_state <= next_state;
        end if;
    end process;

    SEND_COUNTER_PROCESS : process (done_serial_out, reset)
    begin
        if reset = '1' then
            send_counter <= 0;
        elsif rising_edge(done_serial_out) and next_state = enviando and send_counter+1 < OUTPUT_WORDS then
            send_counter <= send_counter + 1;
        end if;        
    end process;

    -- Logica de proximo estado
    next_state <=
        wait_start when (current_state = enviando and done_serial_out = '1' and send_counter >= OUTPUT_WORDS) or (current_state = calculando and serial_in = '0') else
        recebendo when current_state = wait_start and serial_in = '0' else
        calculando when current_state = recebendo and done_serial_in='1' else
        enviando when current_state = calculando and done_multisteps='1' else
        current_state;
        
    ---------------------------------------- MARK: SINAIS DE CONTROLE -----------------------------------------
    start <= '0' when reset='1' else '1';
    tx_go <= '0' when reset='1' else '1';

    serial_out <= serial_data_out;
    serial_data_in <= serial_in;

    data_in_register <= not reversed_parallel_data;
    enable_register <= '1' when done_serial_in = '1' and parity_calculado = parity_bit else '0';
    reset_register <= reset;
    
    reset_serial_in <= reset;
    reset_serial_out <= '0' when current_state = enviando else '1';
    reset_multisteps <= '1' when current_state = recebendo else '0';
        
    msgi <= data_out_register;
    -- msgi <= parallel_data;

end architecture;




entity shift_register is
    generic (
        WIDTH_IN : natural;
        WIDTH : natural
    );
    port (
        clk, reset, enable : in bit;
        data_in : in bit_vector(WIDTH_IN - 1 downto 0);
        data_out : out bit_vector(WIDTH - 1 downto 0)
    );
end entity;
architecture arch of shift_register is
    signal data : bit_vector(WIDTH - 1 downto 0);
    signal previous_enable : bit;
begin


    process (clk,reset)
    begin
        if reset = '1' then
            data <= (others=>'0');
            previous_enable <= '0';
        elsif rising_edge(clk) then
            if enable = '1'  then
                if previous_enable='0' then
                    previous_enable <= '1';
                    data <= data(WIDTH - 1 - WIDTH_IN downto 0) & data_in;
                end if;
            else
                previous_enable <= '0';
            end if;
        else
        end if;
    end process;

    data_out <= data;

end arch ; -- arch

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
