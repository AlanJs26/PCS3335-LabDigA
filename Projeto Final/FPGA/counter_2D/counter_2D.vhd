library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.NUMERIC_STD.all;
use ieee.NUMERIC_STD_UNSIGNED.all;

entity counter_2D is
    generic (
        WIDTH : integer;
        HEIGHT : integer
    );
    port (
        clock, reset : in std_logic;
        enable : in std_logic;
        x : out integer;
        y : out integer
    );
end entity;

architecture arch of counter_2D is

    signal x_reg, y_reg : integer range 0 to WIDTH - 1;

begin
    MAIN_PROCESS : process (clock, reset)
    begin
        if reset = '1' then
            x_reg <= 0;
            y_reg <= 0;
        elsif rising_edge(clock) then

            if enable = '1' and y_reg <= HEIGHT - 1 then
                if x_reg = WIDTH - 1 then
                    x_reg <= 0;
                    y_reg <= y_reg + 1;
                else
                    x_reg <= x_reg + 1;
                end if;
            end if;

        end if;
    end process;

    x <= x_reg;
    y <= y_reg;
end architecture arch;