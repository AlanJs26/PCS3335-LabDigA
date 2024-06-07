library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity shift_register is
    generic (
        WIDTH_IN : natural;
        WIDTH : natural
    );
    port (
        clk, reset, enable : in std_logic;
        data_in : in std_logic_vector(WIDTH_IN - 1 downto 0);
        data_out : out std_logic_vector(WIDTH - 1 downto 0)
    );
end entity;
architecture arch of shift_register is
    signal data : std_logic_vector(WIDTH - 1 downto 0);
    signal previous_enable : std_logic;
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
        end if;
    end process;

    data_out <= data;

end arch ; -- arch