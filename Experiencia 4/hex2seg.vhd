-------------------------------------------------------------------------------
-- Author: Bruno Albertini (balbertini@usp.br)
-- Module Name: hex2seg
-- Description:
-- VHDL module to convert from hex (4b) to 7-segment
-------------------------------------------------------------------------------
entity hex2seg is
    port ( hex : in  bit_vector(3 downto 0); -- Entrada binaria
           seg : out bit_vector(6 downto 0)  -- Saída hexadecimal
           -- A saída corresponde aos segmentos gfedcba nesta ordem. Cobre 
           -- todos valores possíveis de entrada.
        );
end hex2seg;

architecture comportamental of hex2seg is

signal segnot: bit_vector(6 downto 0);
begin
seg <= not segnot;
segnot <= "0111111" when hex = "0000" else
			 "0110000" when hex = "0001" else
			 "1011011" when hex = "0010" else
			 "1001111" when hex = "0011" else
			 "1100110" when hex = "0100" else
			 "1101101" when hex = "0101" else
			 "1111101" when hex = "0110" else
			 "0000111" when hex = "0111" else
			 "1111111" when hex = "1000" else
			 "1101111" when hex = "1001" else
			 "1110111" when hex = "1010" else
			 "1111100" when hex = "1011" else
			 "0111001" when hex = "1100" else
			 "1011110" when hex = "1101" else
			 "1111001" when hex = "1110" else
			 "1110001" when hex = "1111";
end comportamental;



		
