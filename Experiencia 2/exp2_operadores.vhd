entity exp2_operadores_top is
  port (
    SW: in bit_vector(9 downto 0);	 
	 KEY: in bit_vector(3 downto 0);
	 LEDR: OUT bit_vector(9 downto 0);
    HEX0: out bit_vector(6 downto 0);
    HEX1: out bit_vector(6 downto 0);
    HEX2: out bit_vector(6 downto 0);
    HEX3: out bit_vector(6 downto 0);
    HEX4: out bit_vector(6 downto 0);
    HEX5: out bit_vector(6 downto 0)
  );
end exp2_operadores_top ;

architecture arch of exp2_operadores_top is
   component hex2seg is
       port ( hex : in  bit_vector(3 downto 0); -- Entrada binaria
              seg : out bit_vector(6 downto 0)  -- Saída hexadecimal
              -- A saída corresponde aos segmentos gfedcba nesta ordem. Cobre 
              -- todos valores possíveis de entrada.
           );
   end component;
	component sum0 is
		port (
			x: in bit_vector(31 downto 0);
			q: out bit_vector(31 downto 0)
		);
	end component;
	component sum1 is
	port (
		x: in bit_vector(31 downto 0);
		q: out bit_vector(31 downto 0)
	);
	end component;
	component sigma0 is
		port (
			x: in bit_vector(31 downto 0);
			q: out bit_vector(31 downto 0)
		);
	end component;
	component sigma1 is
		port (
			x: in bit_vector(31 downto 0);
			q: out bit_vector(31 downto 0)
		);
	end component;
	component ch is
		port(
			x,y,z: in  bit_vector(31 downto 0);
			q:     out bit_vector(31 downto 0)
		);
	end component;
	component maj is
		port (
			x,y,z: in bit_vector(31 downto 0);
			q: out bit_vector(31 downto 0)
		);
	end component;
	
	signal sum0_result,
			 sum1_result,
			 sigma0_result,
			 sigma1_result,
			 ch_result,
			 maj_result: bit_vector(31 downto 0);

	signal x,y,z, result: bit_vector(31 downto 0);
	signal SW_espelhado: bit_vector(7 downto 0);
	signal option1, option2, option3, option4: bit_vector(31 downto 0);
	signal op: bit_vector(1 downto 0);
begin
	op <= SW(9 downto 8);
	x <= SW(7 downto 0) & SW(7 downto 0) & SW(7 downto 0) & SW(7 downto 0); 
	y <= not x;
	
	GENERATE_INVERSE_Z: for i in 0 to 7 generate
		SW_espelhado(i) <= SW(7-i);
	end generate GENERATE_INVERSE_Z;
	z <= SW_espelhado(7 downto 0) & SW_espelhado(7 downto 0) & SW_espelhado(7 downto 0) & SW_espelhado(7 downto 0); 
	
	SUM0_INSTANCE:   sum0   port map(x, sum0_result);
	SUM1_INSTANCE:   sum1   port map(x, sum1_result);
	SIGMA0_INSTANCE: sigma0 port map(x, sigma0_result);
	SIGMA1_INSTANCE: sigma1 port map(x, sigma1_result);
	CH_INSTANCE:     ch     port map(x,y,z, ch_result);
	MAJ_INSTANCE:    maj    port map(x,y,z, maj_result);


	option1(31 downto 10) <= (others => '0');
	option1(9 downto 0) <= SW;
	option2 <= sum0_result   when KEY(3) = '0' else sum1_result;
	option3 <= sigma0_result when KEY(3) = '0' else sigma1_result;
	option4 <= ch_result     when KEY(3) = '0' else maj_result;

	
	result <= option1 when op = "00" else
  				 option2 when op = "01" else
  				 option3 when op = "10" else
  				 option4 when op = "11" else (others => '0');
	
	HEX0C: hex2seg port map(result(3 downto 0),   HEX0);
	HEX1C: hex2seg port map(result(7 downto 4),   HEX1);
	HEX2C: hex2seg port map(result(11 downto 8),  HEX2);
	HEX3C: hex2seg port map(result(15 downto 12), HEX3);
	HEX4C: hex2seg port map(result(19 downto 16), HEX4);
	HEX5C: hex2seg port map(result(23 downto 20), HEX5);

	LEDR <= "00" & result(31 downto 24);
--	LEDR <= y(31 downto 22);
	
--   HEX1C: hex2seg port map(hexs(7 downto 4),HEX1);
--   HEX2C: hex2seg port map(hexs(11 downto 8),HEX2);
--   HEX3C: hex2seg port map("0000",HEX3);
--   HEX4C: hex2seg port map("0000",HEX4);
--   HEX5C: hex2seg port map("0000",HEX5);
end architecture;
