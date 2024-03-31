------------- SOMADOR -------------

library ieee;
use ieee.numeric_bit.all;

entity somador is
    port (
        a, b : in bit_vector(31 downto 0);
        q : out bit_vector(31 downto 0)
    );
end somador;
architecture ARCH_SOMADOR of somador is
    signal soma : unsigned(31 downto 0);
begin
    soma <= unsigned(a) + unsigned(b);

    q <= bit_vector(soma);
end ARCH_SOMADOR; -- ARCH_SOMADOR