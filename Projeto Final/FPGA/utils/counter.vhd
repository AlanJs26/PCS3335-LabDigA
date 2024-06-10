library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity counter is
    generic(
        MAX: integer
    );
    port (
        clock, reset : in std_logic;
        enable : in std_logic;
        q : out integer
    );
end entity;
architecture arch of counter is

    signal q_sig : integer;

begin
    MAIN_PROCESS : process (clock, reset)
    begin
        if reset = '1' or q_sig >= MAX then
            q_sig <= 0;
        elsif rising_edge(clock) then
            if enable = '1' then
                q_sig <= q_sig + 1;
            end if;
        end if;
    end process;

    q <= q_sig;
end architecture arch;