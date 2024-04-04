library ieee;
use ieee.numeric_bit.all;

entity testbench is
end testbench;

architecture tb of testbench is

    component serial_out is
        generic (
            POLARITY : BOOLEAN := TRUE;
            WIDTH : NATURAL := 7;
            PARITY : NATURAL := 1;
            STOP_BITS : NATURAL := 1
        );
        port (
            clock, reset, tx_go : in BIT;
            tx_done : out BIT;
            data : in bit_vector(WIDTH - 1 downto 0);
            serial_o : out BIT
        );
    end component;

    signal clock, reset : BIT;

    constant POLARITY : BOOLEAN := TRUE;
    constant WIDTH : NATURAL := 8;
    constant PARITY : NATURAL := 1;
    constant STOP_BITS : NATURAL := 2;


    constant clockPeriod : TIME := 2 ns;
    signal keep_simulating : BIT := '0';

    signal tx_go, tx_done, serial_o : bit;
    signal data : bit_vector(7 downto 0);

    signal polaridade : bit;

    signal current_test : integer := 0;

begin

    polaridade <= '1' when POLARITY=true else '0';

    clock <= (not clock) and keep_simulating after clockPeriod/2;

    STA : serial_out 
    generic map(
        POLARITY => POLARITY,
        WIDTH => WIDTH,
        PARITY => PARITY,
        STOP_BITS => STOP_BITS
    )
    port map(
        clock, reset, tx_go,
        tx_done,
        data,
        serial_o
    );

    process is

        type test_record is record
            reset : bit;
            tx_go : bit;
            data : bit_vector(7 downto 0);
            output : bit_vector(9 downto 0);
            tx_done : bit;
            str : string(1 to 3);
        end record;

        type tests_array is array (NATURAL range <>) of test_record;

        constant tests : tests_array :=
        (
            ('1', '0', "00000000","1111111111", '0', "I01"),
            ('1', '0', "00000000","1111111111", '0', "I02"),
            ('0', '0', "00000000","1111111111", '0', "I03"),
            ('1', '1', "00000000","1111111111", '0', "I04"),
            ('0', '1', "00000000","0000000001", '1', "I05")
            
        );
        
    begin

        assert false report "Test start." severity note;
        keep_simulating <= '1';

        for k in tests' range loop
            current_test <= k;

            data <= tests(k).data;
            tx_go <= tests(k).tx_go;
            
            wait until falling_edge(clock);
            wait for clockPeriod/4;
            
            reset <= tests(k).reset;

            wait until falling_edge(clock);
            wait for clockPeriod/4;

            -- tx_go <= '0';

            assert (serial_o = tests(k).output(0)) report "Fail (start): " & tests(k).str severity error;

            for i in 1 to 8 loop
                wait until falling_edge(clock);
                wait for clockPeriod/4;

                    if POLARITY=TRUE then
                        assert (serial_o = tests(k).output(i)) report "Fail (dado[" & integer'image(i-1) & "]): " & tests(k).str severity error;
                    else
                        assert (serial_o = not tests(k).output(i)) report "Fail (dado[" & integer'image(i-1) & "]): " & tests(k).str severity error;
                    end if;
                
            end loop;

				wait until falling_edge(clock);
                wait for clockPeriod/4;
                
                if PARITY=1 then
                    if POLARITY=TRUE then
                        assert (serial_o = tests(k).output(9)) report "Fail (parity): " & tests(k).str severity error;
                    else
                        assert (serial_o = not tests(k).output(9)) report "Fail (parity): " & tests(k).str severity error;
                    end if;
                else
                    if POLARITY=TRUE then
                        assert (serial_o = not tests(k).output(9)) report "Fail (parity): " & tests(k).str severity error;
                    else
                        assert (serial_o = tests(k).output(9)) report "Fail (parity): " & tests(k).str severity error;
                    end if;
                end if;


            for i in 1 to STOP_BITS loop
                wait until falling_edge(clock);
                wait for clockPeriod/4;

                assert (serial_o = polaridade) report "Fail (stop): " & tests(k).str severity error;                
            end loop;

            -- assert (tests(k).shield = shield) report "Fail (shield): " & tests(k).str severity error;
            wait until falling_edge(clock);
            wait for clockPeriod/4;

            assert (tests(k).tx_done = tx_done) report "Fail (done): " & tests(k).str severity error;


        end loop;

        -- wait until done = '1';
        wait until falling_edge(clock);
        wait for clockPeriod/4;
        
        assert false report "Test done." severity note;
        keep_simulating <= '0';
        wait;

    end process;

end tb;