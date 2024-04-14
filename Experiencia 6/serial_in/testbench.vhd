library ieee;
use ieee.numeric_bit.all;

entity testbench is
end testbench;

architecture tb of testbench is

    component serial_in is
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

    component clock_diviser is
        generic (
          INPUT_CLOCK : integer; 
          TARGET_CLOCK : integer
        );
        port (
            i_clk : in bit;
            i_rst : in bit;
            o_clk_div : out bit
        );
    end component;

    component serial_out is
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

    signal reset_serial_in, reset_serial_out : bit;

    -- CONSTANTS
    constant POLARITY : boolean := TRUE;
    constant WIDTH : natural := 8;
    constant PARITY : natural := 1;
    constant CLOCK_MUL : positive := 4;

    constant STOP_BITS : natural := 2;
    

    -- serial_in signals
    signal start, serial_data, done, parity_bit : bit;
    signal parallel_data : bit_vector(7 downto 0);

    -- serial_out signals
    signal tx_go, tx_done : bit;
    signal data : bit_vector(7 downto 0);
    
    -- clock signals
    signal clock, clock_div : bit;

	constant INPUT_CLOCK : integer := 4800*4;
    constant TARGET_CLOCK : integer := INPUT_CLOCK/4;
    -- constant TARGET_CLOCK : integer := 4800*CLOCK_MUL;

    -- testbench signals
    constant clockPeriod : time := (1 sec)/(INPUT_CLOCK);
    constant clock_divPeriod : time := (1 sec)/(TARGET_CLOCK);
    signal keep_simulating : bit := '0';

    signal current_test : integer := 0;

    function eval_polarity(
        value : bit) return bit is
    begin
        if polarity = true then
            return value;
        else
            return not value;
        end if;
    end function;
begin

    clock <= (not clock) and keep_simulating after clockPeriod/2;

    STA : serial_in
    generic map(
        POLARITY => POLARITY,
        WIDTH => WIDTH,
        PARITY => PARITY,
        CLOCK_MUL => CLOCK_MUL
    )
    port map(
        clock, reset_serial_in, start, serial_data,
        done, parity_bit,
        parallel_data
    );

    CLOCK_DIVISER_INSTANCE : clock_diviser
    generic map(
        INPUT_CLOCK => INPUT_CLOCK,
        TARGET_CLOCK => TARGET_CLOCK
    )
    port map(
        clock, '0', clock_div
    );

    SERIAL_OUT_INSTANCE : serial_out
    generic map(
        POLARITY => POLARITY,
        WIDTH => WIDTH,
        PARITY => PARITY,
        STOP_BITS => STOP_BITS
    )
    port map(
        clock_div, reset_serial_out, tx_go,
        tx_done,
        data,
        serial_data
    );

    process is

        type test_record is record
            data : bit_vector(7 downto 0);
            parity_bit : bit;
        end record;

        type tests_array is array (natural range <>) of test_record;

        constant tests : tests_array :=
        (
        ("11101010", '1'), --00
        ("11101010", '1'), --01
        ("11100000", '1'), --02
        ("10111001", '1'), --03
        ("00101000", '0'), --04
        ("10110010", '0'), --05
        ("01110010", '0'), --06
        ("01000111", '0'), --07
        ("10100100", '1'), --08
        ("11010000", '1'), --09
        ("00101001", '1'), --10
        ("11001010", '0'), --11
        ("01011010", '0'), --12
        ("10011110", '1'), --13
        ("00001000", '1'), --14
        ("01110100", '0'), --15
        ("10010011", '0'), --16
        ("10100110", '0'), --17
        ("10101010", '0'), --18
        ("01110110", '1'), --19
        ("01100111", '1'), --20
        ("01010100", '1')  --21
        );

        
    begin
        assert false report "Test start." severity note;
        keep_simulating <= '1';

        -- wait for clock_divPeriod*4;
        -- assert false report "Test done." severity note;
        -- keep_simulating <= '0';
        -- wait;

        reset_serial_in <= '1';
        reset_serial_out <= '1';
        wait until falling_edge(clock);
        wait for clock_divPeriod/4;
        reset_serial_in <= '0';
        reset_serial_out <= '0';
        wait until falling_edge(clock);
        wait for clock_divPeriod/4;


        for i in 0 to 7 loop            
            data(i) <= tests(0).data(7-i);
        end loop ;

        start <= '1';
        tx_go <= '1';



        for k in tests' range loop
            current_test <= k;


            -- start <= '0';
            -- wait until falling_edge(clock);
            -- wait for clock_divPeriod/4;
            -- start <= '1';
            -- wait until falling_edge(clock);
            -- wait for clock_divPeriod/4;

            -- tx_go <= '0';
            -- reset_serial_out <= '1';
            -- wait until falling_edge(clock_div);
            -- wait for clock_divPeriod/4;
            -- reset_serial_out <= '0';
            -- wait until falling_edge(clock_div);
            -- wait for clock_divPeriod/4;

            for i in 0 to 7 loop            
                data(i) <= tests(k).data(i);
            end loop ;
            -- start <= '1';

            -- wait until falling_edge(clock_div);
            -- wait for clock_divPeriod/4;

            -- tx_go <= '1';

            -- wait until falling_edge(clock_div);
            -- wait for clock_divPeriod/4;
            -- start <= '0';            


            wait until tx_done = '1';
            -- tx_go <= '0';
            
            wait until falling_edge(clock_div);
            wait for (clock_divPeriod)/4;
            -- wait for clock_divPeriod*10;

            assert (tests(k).data = parallel_data) report "Fail (parallel_data) {" & integer'image(k) & "}" severity error;
            assert (tests(k).parity_bit = parity_bit) report "Fail (parity_bit) {" & integer'image(k) & "}" severity error;
            
            -- wait until falling_edge(clock_div);
            -- wait for clock_divPeriod/4;

            -- assert (tests(k).tx_done = tx_done) report "Fail (done): " & tests(k).str & "{" & integer'image(k) & "}" severity error;
        end loop;

        wait until falling_edge(clock);
        wait for clockPeriod/4;

        assert false report "Test done." severity note;
        keep_simulating <= '0';
        wait;

    end process;

end tb;