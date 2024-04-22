library ieee;
use ieee.numeric_bit.all;

entity tb is end;

architecture arch of tb is

    component sha256_1b is
        port (
            clock, reset : in bit; -- Clock da placa, GPIO_0_D2  
            serial_in : in bit; -- GPIO_0_D0
            serial_out : out bit -- GPIO_0_D1
        );
    end component;

    constant PERIOD50M : time := 20 ns;
    constant PERIOD12_5M : time := 80 ns;

    signal reset, serial_in, serial_out : bit;
    signal clock50M, clock12_5M : bit;
    signal finished : bit := '0';
begin

    clock50M <= not clock50M and not finished after PERIOD50M/2;
    clock12_5M <= not clock12_5M and not finished after PERIOD12_5M/2;

    sha256 : sha256_1b
    port map(clock50M, reset, serial_in, serial_out);
    Estimulo : process
    begin
        reset <= '1';
        serial_in <= '1';
        wait until rising_edge(clock12_5M);
        wait until rising_edge(clock12_5M);
        wait until rising_edge(clock12_5M);
        wait until rising_edge(clock12_5M);
        reset <= '0';
        wait until rising_edge(clock12_5M);
        serial_in <= '0'; --SB
        wait until rising_edge(clock12_5M);
        serial_in <= '1'; --D0
        wait until rising_edge(clock12_5M);
        serial_in <= '1'; --D1
        wait until rising_edge(clock12_5M); --D2
        serial_in <= '0'; --D2
        wait until rising_edge(clock12_5M); --D3
        serial_in <= '0'; --D3
        wait until rising_edge(clock12_5M); --D4
        serial_in <= '0'; --D4
        wait until rising_edge(clock12_5M); --D5
        serial_in <= '1'; --D5
        wait until rising_edge(clock12_5M); --D6
        serial_in <= '1'; --D6
        wait until rising_edge(clock12_5M); --D7
        serial_in <= '1'; --D7
        wait until rising_edge(clock12_5M); --Paridade
        serial_in <= '0'; --Paridade
        wait until rising_edge(clock12_5M);
        serial_in <= '1'; --Stop bit 1
        wait until rising_edge(clock12_5M); --Stopbit

        wait until falling_edge(serial_out);
        wait for PERIOD12_5M/2;
        assert serial_out = '0' --Sb
        report "Sb";
        wait for PERIOD12_5M;
        assert serial_out = '1' --D1
        report "D1";
        wait for PERIOD12_5M;
        assert serial_out = '1' --D2
        report "D2";
        wait for PERIOD12_5M;
        assert serial_out = '1' --D3
        report "D3";
        wait for PERIOD12_5M;
        assert serial_out = '0' --D4
        report "D4";
        wait for PERIOD12_5M;
        assert serial_out = '1' --D5
        report "D5";
        wait for PERIOD12_5M;
        assert serial_out = '0' --D6
        report "D6";
        wait for PERIOD12_5M;
        assert serial_out = '0' --D7
        report "D7";
        wait for PERIOD12_5M;
        assert serial_out = '1' --D8
        report "D8";
        wait for PERIOD12_5M;
        assert serial_out = '0'; --Paridade
        wait for PERIOD12_5M;
        assert serial_out = '1'; --End 
        wait for PERIOD12_5M;
        finished <= '1';
        wait;
    end process;
end arch; -- arch