library IEEE;
use IEEE.numeric_bit.all;


entity counter4bits is
    generic(
        width: natural := 4
    );
    port(
        clk: in bit;
        rst: in bit;
        count: out bit_vector(width-1 downto 0)
    );
end entity;

architecture libarch of counter4bits is
signal countsig: unsigned(width-1 downto 0);
signal fairClock: bit;
signal lastrst:bit;
begin


proc: process(clk,rst)
begin
    if(rst /= lastrst) then
        countsig <= (others => '0');
        lastrst <= rst;
    elsif (clk'event and clk = '1') then
        countsig <= countsig + 1;
    end if;
end process;

count <= bit_vector(countsig);
    
end architecture;


