-------------------------------------------------------------------------------
-- Author: Alan Jose dos Santos (alanjose@usp.br)
-- Author: Lucas Franco
-- Module Name: operators
-- Description:
-- VHDL module that contains a bunch of math operators (32b)
-------------------------------------------------------------------------------

entity ch is
	port(
		x,y,z: in  bit_vector(31 downto 0);
		q:     out bit_vector(31 downto 0)
	);
end ch;
architecture COMPORTAMENTAL of ch is
begin
q <= (x and y) xor ((not x) and z);
end COMPORTAMENTAL; -- COMPORTAMENTAL
		

entity maj is
	port (
		x,y,z: in  bit_vector(31 downto 0);
		q:     out bit_vector(31 downto 0)
	);
end maj;
architecture COMPORTAMENTAL of maj is
begin
q <= (z and y) xor (x and z) xor (y and x);
end COMPORTAMENTAL; -- COMPORTAMENTAL

entity sum0 is
	port (
		x: in  bit_vector(31 downto 0);
		q: out bit_vector(31 downto 0)
	);
end sum0;
architecture COMPORTAMENTAL of sum0 is
begin 
q <= (x ror 2) xor (x ror 13) xor (x ror 22);
end COMPORTAMENTAL; -- COMPORTAMENTAL

entity sum1 is
	port (
		x: in  bit_vector(31 downto 0);
		q: out bit_vector(31 downto 0)
	);
end sum1;
architecture COMPORTAMENTAL of sum1 is
begin
q <= (x ror 6) xor (x ror 11) xor (x ror 25);
end COMPORTAMENTAL; -- COMPORTAMENTAL

entity sigma0 is
	port (
		x: in  bit_vector(31 downto 0);
		q: out bit_vector(31 downto 0)
	);
end sigma0;
architecture COMPORTAMENTAL of sigma0 is
begin
q <= (x ror 7) xor (x ror 18) xor (x srl 3);
end COMPORTAMENTAL; -- COMPORTAMENTAL

entity sigma1 is
	port (
		x: in  bit_vector(31 downto 0);
		q: out bit_vector(31 downto 0)
	);
end sigma1;
architecture COMPORTAMENTAL of sigma1 is
begin
q <= (x ror 17) xor (x ror 19) xor (x srl 10);
end COMPORTAMENTAL; -- COMPORTAMENTAL
