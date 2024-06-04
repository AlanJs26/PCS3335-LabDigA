library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

----------------------------------------PARIDADE----------------------------------------

entity parity_def is
    generic (
        POLARITY : BOOLEAN := TRUE;
        WIDTH : NATURAL := 7;
        PARITY : NATURAL := 1
    );
    port (
        data : in std_logic_vector(WIDTH - 1 downto 0);
        q : out std_logic
    );
end entity;

architecture parity_def_arch of parity_def is
    signal paridade : std_logic_vector(WIDTH-2 downto 0);
    signal saida : std_logic;
begin
    
    paridade(0) <= data(0) xor data(1);
    PARIDADE_GENERATE : for i in 1 to WIDTH-2 generate
        paridade(i) <= paridade(i-1) xor data(i+1);
    end generate;

    saida <= paridade(WIDTH-2) when PARITY=1 else not paridade(WIDTH-2);

    q <= saida when POLARITY=TRUE else not saida;
end parity_def_arch ; -- parity_def_arch