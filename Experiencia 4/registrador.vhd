library ieee;
--use ieee.numeric_bit.rising_edge;

entity reg256 is
    port (
        clock, reset, enable : in BIT;
        D : in bit_vector(255 downto 0);
        Q : out bit_vector(255 downto 0)
    );
end entity;

architecture arch_reg256 of reg256 is
    signal dado : bit_vector(255 downto 0);
begin
    process (clock, reset)
    begin
        if reset = '1' then
            dado <= (others => '0');
        elsif (rising_edge(clock)) then
            if enable = '1' then
                dado <= D;
            end if;
        end if;
    end process;
    Q <= dado;
end architecture;