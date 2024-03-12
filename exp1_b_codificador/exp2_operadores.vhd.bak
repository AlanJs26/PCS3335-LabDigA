entity exp1_b_codificador_top is
  port (
    SW: in bit_vector(9 downto 0);
    HEX0: out bit_vector(6 downto 0);
    HEX1: out bit_vector(6 downto 0);
    HEX2: out bit_vector(6 downto 0);
    HEX3: out bit_vector(6 downto 0);
    HEX4: out bit_vector(6 downto 0);
    HEX5: out bit_vector(6 downto 0)
  );
end exp1_b_codificador_top ;

architecture arch of exp1_b_codificador_top is
    component hex2seg is
        port ( hex : in  bit_vector(3 downto 0); -- Entrada binaria
               seg : out bit_vector(6 downto 0)  -- Saída hexadecimal
               -- A saída corresponde aos segmentos gfedcba nesta ordem. Cobre 
               -- todos valores possíveis de entrada.
            );
    end component;
    signal hexs: bit_vector(11 downto 0);
begin
    hexs <= "00" & SW;
    HEX0C: hex2seg port map(hexs(3 downto 0),HEX0);
    HEX1C: hex2seg port map(hexs(7 downto 4),HEX1);
    HEX2C: hex2seg port map(hexs(11 downto 8),HEX2);
    HEX3C: hex2seg port map("0000",HEX3);
    HEX4C: hex2seg port map("0000",HEX4);
    HEX5C: hex2seg port map("0000",HEX5);
end architecture;