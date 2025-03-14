library ieee;
use ieee.numeric_bit.all;

entity sha256 is
    port (
        clock, reset : in bit;
        serial_in : in bit;
        LEDR : out bit_vector(9 downto 0);
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
    signal data_serial_out : bit_vector(SERIAL_OUT_WIDTH - 1 downto 0);
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
    signal estou_no_wait_start : bit;

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
        data_serial_out,
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

    SEND_COUNTER_PROCESS : process (done_serial_out, reset, clock)
    begin
        if reset = '1' or estou_no_wait_start = '1' then
            send_counter <= 0;
        elsif rising_edge(done_serial_out) and next_state = enviando then
            send_counter <= send_counter + 1;
        end if;        
    end process;

    -- Logica de proximo estado
    next_state <=
        wait_start when (send_counter >= OUTPUT_WORDS) or (current_state = calculando and serial_in = '0') else
        recebendo when current_state = wait_start and done_serial_in = '1' and parity_calculado = parity_bit else
        calculando when current_state = recebendo and done_serial_in='1' else
        enviando when current_state = calculando and done_multisteps='1' else
        current_state;

    estou_no_wait_start <= '1' when current_state = wait_start else '0';

    LEDR <= 
    "11111" & "11110" when current_state = wait_start else
    "11111" & "11101" when current_state = recebendo else
    "11111" & "11011" when current_state = guardando else
    "11111" & "10111" when current_state = calculando else
    "11111" & "01111" when current_state = enviando else
    "1111111111";
        
    -- type state_t is (wait_start, recebendo, guardando, calculando, enviando);


    ---------------------------------------- MARK: SINAIS DE CONTROLE -----------------------------------------
    start <= '0' when reset='1' else '1';
    tx_go <= '0' when reset='1' else '1';

    serial_out <= serial_data_out;
    serial_data_in <= serial_in;

    data_in_register <= not reversed_parallel_data;
    enable_register <= '1' when done_serial_in = '1' and parity_calculado = parity_bit else '0';
    -- reset_register <= '1' when current_state = wait_start else '0';
    reset_register <= reset;

    -- data_serial_out <= haso(SERIAL_OUT_WIDTH*(((OUTPUT_WORDS-1)-send_counter)+1)-1 downto ((OUTPUT_WORDS-1)-send_counter)*SERIAL_OUT_WIDTH) 
    --     when send_counter < OUTPUT_WORDS else haso(SERIAL_OUT_WIDTH-1 downto 0);
    
    data_serial_out <= haso(SERIAL_OUT_WIDTH*(((OUTPUT_WORDS-1)-send_counter)+1)-1 downto ((OUTPUT_WORDS-1)-send_counter)*SERIAL_OUT_WIDTH)
        when send_counter < OUTPUT_WORDS else haso(SERIAL_OUT_WIDTH-1 downto 0);
    
    reset_serial_in <= '1' when send_counter >= OUTPUT_WORDS else reset;
    reset_serial_out <= '0' when current_state = enviando and send_counter < OUTPUT_WORDS else '1';
    reset_multisteps <= '1' when current_state = recebendo else '0';


        
    msgi <= data_out_register;
    -- msgi <= x"000000f8000000000000000000000000000000000000000000000000000000006c204180676974616f204469746f7269626f72612d204c613333352050435333";

end architecture;



