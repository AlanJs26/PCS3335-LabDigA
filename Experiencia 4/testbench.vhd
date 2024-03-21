library ieee;
use ieee.numeric_bit.all;

entity testbench is
end testbench;

architecture tb of testbench is

    component multisteps is
        port (
            clk, rst : in BIT;
            msgi : in bit_vector(511 downto 0);
            haso : out bit_vector(255 downto 0);
            done : out BIT
        );
    end component;

    signal clk, rst : BIT;

    signal msgi : bit_vector(511 downto 0);
    signal haso : bit_vector(255 downto 0);
    signal done : bit;

    constant clockPeriod : TIME := 2 ns;
    signal keep_simulating : BIT := '0';

begin

    clk <= (not clk) and keep_simulating after clockPeriod/2;

    STA : multisteps port map(
        clk, rst,
        msgi,
        haso,
        done
    );

    process is

        type test_record is record
            rst : BIT;
            SW : bit_vector(7 downto 0);
            haso : bit_vector(255 downto 0);
            done : bit;
            str : string(1 to 3);
        end record;

        type tests_array is array (NATURAL range <>) of test_record;

        constant tests : tests_array :=
        (
            ('1', "10101010", x"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", '0', "I01"),
            ('0', "10101010", x"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", '0', "I02"),
    
            ('0', "00000000", x"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", '0', "S01"),
    
            ('0', "00000000", x"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", '0', "R01"),

            ('0', "11001000", x"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", '0', "F01")
        );
    begin

        assert false report "Test start." severity note;
        keep_simulating <= '1';

        for k in tests' range loop
            rst <= tests(k).rst;
            
            for i in 0 to 63 loop
                msgi((i+1)*7+i downto i*7+i) <= tests(k).SW;
            end loop;

            wait until falling_edge(clk);
            wait for clockPeriod/4;

            -- assert (tests(k).shield = shield) report "Fail (shield): " & tests(k).str severity error;
            -- assert (tests(k).health = health) report "Fail (health): " & tests(k).str severity error;
            -- assert (tests(k).turn = turn) report "Fail (turn): " & tests(k).str severity error;
            -- assert (tests(k).WL = WL) report "Fail (WL): " & tests(k).str severity error;
        end loop;

        wait until done = '1';

        assert false report "Test done." severity note;
        keep_simulating <= '0';
        wait;

    end process;

end tb;