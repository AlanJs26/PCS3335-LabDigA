library ieee;
use ieee.numeric_bit.all;

entity sha256_1b is
    port (
        clock, reset : in bit;
        serial_in : in bit;
        serial_out : out bit;
        haso_sha256 : out bit_vector(255 downto 0)
    );
end sha256_1b;

architecture sha256_1b_arch of sha256_1b is
    ---------------------------------------- MARK: Serial In --------------------------------------------------  
    constant POLARITY : boolean := TRUE;
    constant WIDTH : natural := 8;
    constant PARITY : natural := 0;
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
        haso(WIDTH-1+8 downto 0+8),
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
        wait_start when (current_state = enviando and done_serial_out = '1') or (current_state = calculando and serial_in = '0') else
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

    haso_sha256 <= haso;

end architecture;
