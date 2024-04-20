LIBRARY ieee;
USE ieee.numeric_bit.ALL;

ENTITY serial_in IS
    GENERIC (
        POLARITY : BOOLEAN := TRUE;
        WIDTH : NATURAL := 8;
        PARITY : NATURAL := 1;
        CLOCK_MUL : POSITIVE := 4
    );
    PORT (
        clock, reset, start, serial_data : IN BIT;
        done, parity_bit : OUT BIT;
        parallel_data : OUT bit_vector(WIDTH - 1 DOWNTO 0)
    );
END serial_in;
ARCHITECTURE arch OF serial_in IS

    COMPONENT clock_diviser IS
        GENERIC (
            -- INPUT_CLOCK : INTEGER;
            -- TARGET_CLOCK : INTEGER
            CLOCK_MUL : INTEGER
        );
        PORT (
            i_clk : IN BIT;
            i_rst : IN BIT;
            o_clk_div : OUT BIT
        );
    END COMPONENT;

    COMPONENT bit_reverser IS
        GENERIC (
            WIDTH : POSITIVE
        );
        PORT (
            i_data : IN bit_vector(WIDTH - 1 DOWNTO 0);
            o_data : OUT bit_vector(WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    TYPE state_t IS (wait_start, middle_reset, reset_clock, receive_data, wait_done, rest);
    SIGNAL next_state, current_state : state_t;

    SIGNAL clock_div, clock_div_rst : BIT;
    SIGNAL data : bit_vector(WIDTH DOWNTO 0);
    SIGNAL data_counter : INTEGER := 0;

    SIGNAL reverse_data : bit_vector(WIDTH - 1 DOWNTO 0);

    SIGNAL serial_data_p : BIT;

    SIGNAL middle_counter : INTEGER := 0;

BEGIN

    serial_data_p <= serial_data WHEN POLARITY = true ELSE
        NOT serial_data;

    CLOCK_DIVISER_INSTANCE : clock_diviser
    GENERIC MAP(
        -- INPUT_CLOCK => 50000000,
        -- INPUT_CLOCK => 4800 * 4,
        -- TARGET_CLOCK => 4800
        CLOCK_MUL => 1
        -- TARGET_CLOCK => 50000000/4
        -- TARGET_CLOCK => 4800*CLOCK_MUL
    )
    PORT MAP(
        clock, clock_div_rst, clock_div
    );

    BIT_REVERSER_INSTANCE : bit_reverser
    GENERIC MAP(
        WIDTH => WIDTH
    )
    PORT MAP(
        data(WIDTH DOWNTO 1), reverse_data
    );

    STATES_PROCESS : PROCESS (clock, reset, start)
    BEGIN

        IF reset = '1' THEN
            current_state <= wait_start;
        ELSIF (rising_edge(clock)) THEN

            if next_state=reset_clock then
                middle_counter <= 0;
            else
                middle_counter <= middle_counter + 1;
            end if;

            current_state <= next_state;
        END IF;

    END PROCESS;

    -- Logica de proximo estado
    next_state <=
        wait_start WHEN current_state = rest AND start = '1' ELSE
        reset_clock WHEN current_state = wait_start AND serial_data_p = '0' AND start = '1' ELSE
        middle_reset WHEN current_state = reset_clock ELSE
        receive_data WHEN current_state = middle_reset  AND middle_counter >= 0 ELSE
        wait_done WHEN (current_state = receive_data AND data_counter >= WIDTH + 1) ELSE
        rest WHEN current_state = wait_done ELSE
        next_state;

    clock_div_rst <= '1' WHEN current_state = reset_clock or current_state = middle_reset ELSE
        '0';

    parity_bit <= data(0) WHEN PARITY = 1 ELSE
        NOT data(0);

    parallel_data <= reverse_data;
    done <= '1' WHEN current_state = rest OR data_counter >= WIDTH + 2 or current_state = wait_done ELSE
        '0';

    MAIN_PROCESS : PROCESS (clock_div, clock_div_rst, reset)
    BEGIN
        IF reset = '1' THEN
            data_counter <= 0;
        ELSIF clock_div_rst = '1' THEN
            data_counter <= 0;
            data <= (OTHERS => '0');
        ELSIF rising_edge(clock_div) THEN
            IF current_state = receive_data then
                data_counter <= data_counter + 1;

                FOR i IN WIDTH DOWNTO 1 LOOP
                    data(i) <= data(i - 1);
                END LOOP;
                data(0) <= serial_data_p;

            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;

ENTITY bit_reverser IS
    GENERIC (
        WIDTH : POSITIVE
    );
    PORT (
        i_data : IN bit_vector(WIDTH - 1 DOWNTO 0);
        o_data : OUT bit_vector(WIDTH - 1 DOWNTO 0)
    );
END ENTITY bit_reverser;

ARCHITECTURE arch OF bit_reverser IS
BEGIN
    PROCESS (i_data)
    BEGIN
        FOR i IN 0 TO WIDTH - 1 LOOP
            o_data(i) <= i_data(WIDTH - 1 - i);
        END LOOP;
    END PROCESS;
END ARCHITECTURE;