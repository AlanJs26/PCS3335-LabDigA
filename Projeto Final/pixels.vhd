
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.math_real.all;


entity PixelGen is
	generic(
		BLUR_KERNEL : integer := 5
	);
	port (
		RESET_B, RESET_C, RESET_BLUR : in std_logic; -- Entrada para reiniciar o estado do controlador
		F_CLOCK : in std_logic; -- Entrada de clock (50 MHz)
		F_ON : in std_logic; --Indica a regi�o ativa do frame
		F_ROW : in std_logic_vector(9 downto 0); -- �ndice da linha que est� sendo processada
		H : in std_logic;
		L : in std_logic;
		F_COLUMN : in std_logic_vector(10 downto 0); -- �ndice da coluna que est� sendo processada
		R_OUT : out std_logic_vector(3 downto 0); -- Componente R
		G_OUT : out std_logic_vector(3 downto 0); -- Componente G
		B_OUT : out std_logic_vector(3 downto 0) -- Componente B
	);

end entity PixelGen;
architecture arch of PixelGen is
	signal RGBp : std_logic_vector(11 downto 0); -- Valor atual do pixel
	signal RGBn : std_logic_vector(11 downto 0); -- �ltimo valor definido

	signal R_S, G_S, B_S : std_logic_vector(3 downto 0);

	signal R_S_int, G_S_int, B_S_int : integer;

	signal COLUMN_int, ROW_int : integer;

	constant alpha : integer := 1;
	constant beta : integer := 5;

	constant VGA_WIDTH : integer := 800;
	constant VGA_HEIGHT : integer := 600;

	type rgb_grid_type is array (0 to BLUR_KERNEL*BLUR_KERNEL-1) of std_logic_vector(11 downto 0);
	
	type rgb_split_type is array (0 to 2) of integer;
	type rgb_split_grid_type is array (0 to BLUR_KERNEL*BLUR_KERNEL-1) of rgb_split_type;

	type conditions_type is array (0 to BLUR_KERNEL-1) of boolean;

	signal RGB_grid : rgb_grid_type;
	signal RGB_split_grid : rgb_split_grid_type;

	signal RGB_grid_p : rgb_grid_type;
	signal RGB_split_grid_p : rgb_split_grid_type;

	signal column_conditions : conditions_type;
	signal row_conditions : conditions_type;



begin

	-- Cada componente deve ser ativada somente se o frame estiver na regi�o ativa
	R_S <= RGBp(11 downto 8) when F_ON = '1' else
		(others => '0');
	G_S <= RGBp(7 downto 4) when F_ON = '1' else
		(others => '0');
	B_S <= RGBp(3 downto 0) when F_ON = '1' else
		(others => '0');

	R_S_int <= conv_integer(unsigned(R_S));
	G_S_int <= conv_integer(unsigned(G_S));
	B_S_int <= conv_integer(unsigned(B_S));

	COLUMN_int <= conv_integer(unsigned(F_COLUMN));
	ROW_int <= conv_integer(unsigned(F_ROW));

	column_conditions <= (COLUMN_int>1, COLUMN_int>0, true, COLUMN_int<VGA_WIDTH-1, COLUMN_int<VGA_WIDTH-2);
	row_conditions <= (ROW_int>1, ROW_int>0, true, ROW_int<VGA_HEIGHT-1, ROW_int<VGA_HEIGHT-2);

	-- Define um novo valor RGB de acordo com �ndice da coluna
	RGBn <= conv_std_logic_vector(conv_integer((alpha * COLUMN_int*COLUMN_int + beta * ROW_int)), RGBn'length);

	RGB_GRID_GENERATE: for ii in 0 to BLUR_KERNEL*BLUR_KERNEL-1 generate
		RGB_grid(ii) <= conv_std_logic_vector(conv_integer(
			alpha * (COLUMN_int+((ii mod BLUR_KERNEL) - 1))*(COLUMN_int+((ii mod BLUR_KERNEL) - 1)) + beta * (ROW_int+(ii/BLUR_KERNEL - 1))
			), RGBn'length) when column_conditions(ii mod BLUR_KERNEL) and row_conditions(ii/BLUR_KERNEL) else
			(others=>'0');
	end generate RGB_GRID_GENERATE;

	RGB_GRID_SPLIT_GENERATE: for ii in 0 to BLUR_KERNEL*BLUR_KERNEL-1 generate
		RGB_split_grid(ii)(0) <= conv_integer(unsigned(RGB_grid(ii)(11 downto 8)));
		RGB_split_grid(ii)(1) <= conv_integer(unsigned(RGB_grid(ii)(7 downto 4)));
		RGB_split_grid(ii)(2) <= conv_integer(unsigned(RGB_grid(ii)(3 downto 0)));
	end generate RGB_GRID_SPLIT_GENERATE;
	

	-- RGBn <= "000" WHEN F_COLUMN = "0000000000" ELSE -- Preto (Coluna = 0)
	-- 		"001" WHEN F_COLUMN = "0001100100" ELSE -- Azul (Coluna = 100)
	-- 		"010" WHEN F_COLUMN = "0011001000" ELSE -- Verde (Coluna = 200)
	-- 		"011" WHEN F_COLUMN = "0100101100" ELSE -- Ciano (Coluna = 300)
	-- 		"100" WHEN F_COLUMN = "0110010000" ELSE -- Vermelho (Coluna = 400)
	-- 		"101" WHEN F_COLUMN = "0111110100" ELSE -- Magenta (Coluna = 500)
	-- 		"110" WHEN F_COLUMN = "1001011000" ELSE -- Amarelo (Coluna = 600)
	-- 		"111" WHEN F_COLUMN = "1010111100" ELSE -- Branco (Coluna = 700)
	-- 		RGBp; --�ltimo valor definido

	process (F_CLOCK, RESET_B, RESET_C)
		variable R_OUT_blur, G_OUT_blur, B_OUT_blur : integer := 0;
	begin
		if RISING_EDGE(F_CLOCK) then
			if (RESET_B = '1') then

				if H ='1' then

					if (R_S_int <= 8) then
						R_OUT <= conv_std_logic_vector(R_S_int + 7, R_OUT'length);
					elsif (R_S_int > 8) then
						R_OUT <= conv_std_logic_vector(15, R_OUT'length);
					end if;

					if (G_S_int <= 8) then
						G_OUT <= conv_std_logic_vector(G_S_int + 7, G_OUT'length);
					elsif (G_S_int > 8) then
						G_OUT <= conv_std_logic_vector(15, G_OUT'length);
					end if;

					if (B_S_int <= 8) then
						B_OUT <= conv_std_logic_vector((B_S_int + 7), B_OUT'length);
					elsif (B_S_int > 8) then
						B_OUT <= conv_std_logic_vector(15, B_OUT'length);
					end if;
				end if;

				if L = '1' then
					if (R_S_int >= 7) then
						R_OUT <= conv_std_logic_vector((R_S_int - 7), R_OUT'length);
					elsif (R_S_int < 7) then
						--R_OUT <= conv_std_logic_vector(0, R_OUT'length);
						R_OUT <= "0000";
					end if;

					if (G_S_int >= 7) then
						G_OUT <= conv_std_logic_vector((G_S_int - 7), G_OUT'length);
					elsif (G_S_int < 7) then
						--G_OUT <= conv_std_logic_vector(0, G_OUT'length);
						 G_OUT <= "0000";
					end if;

					if (B_S_int >= 7) then
						B_OUT <= conv_std_logic_vector((B_S_int - 7), B_OUT'length);
					elsif (B_S_int < 7) then
						--B_OUT <= conv_std_logic_vector(0, B_OUT'length);
						B_OUT <= "0000";
					end if;
				end if;
			end if;

			if (RESET_C = '1') then
				
				if H = '1' then
					if (R_S_int <= 10 and R_S_int >= 6) then
						R_OUT <= conv_std_logic_vector(3 * (R_S_int - 8) + 8, R_OUT'length);
					elsif (R_S_int > 10) then
						R_OUT <= conv_std_logic_vector(15, R_OUT'length);
					elsif (R_S_int < 6) then
						R_OUT <= conv_std_logic_vector(0, R_OUT'length);
					end if;

					if (B_S_int <= 10 and B_S_int >= 6) then
						B_OUT <= conv_std_logic_vector(3 * (B_S_int - 8) + 8, B_OUT'length);
					elsif (B_S_int > 10) then
						B_OUT <= conv_std_logic_vector(15, B_OUT'length);
					elsif (B_S_int < 6) then
						B_OUT <= conv_std_logic_vector(0, B_OUT'length);
					end if;

					if (G_S <= 10 and G_S >= 6) then
						G_OUT <= conv_std_logic_vector(3 * (G_S_int - 8) + 8, G_OUT'length);
					elsif (G_S > 10) then
						G_OUT <= conv_std_logic_vector(15, G_OUT'length);
					elsif (G_S < 6) then
						G_OUT <= conv_std_logic_vector(0, G_OUT'length);
					end if;
				end if;

				if (L = '1') then
					R_OUT <= conv_std_logic_vector((R_S_int - 8)/3 + 8, R_OUT'length);
					G_OUT <= conv_std_logic_vector((G_S_int - 8)/3 + 8, G_OUT'length);
					B_OUT <= conv_std_logic_vector((B_S_int - 8)/3 + 8, B_OUT'length);
				end if;

			end if;

			if RESET_BLUR = '1' then

				R_OUT_blur := 0;
				for ii in 0 to BLUR_KERNEL loop
					R_OUT_blur := R_OUT_blur + RGB_split_grid_p(ii)(0);
				end loop;
				if F_ON = '1' then
					R_OUT <= conv_std_logic_vector(R_OUT_blur/(BLUR_KERNEL), R_OUT'length);
				end if;

				G_OUT_blur := 0;
				for ii in 0 to BLUR_KERNEL loop
					G_OUT_blur := G_OUT_blur + RGB_split_grid_p(ii)(1);
				end loop;
				if F_ON='1' then
					G_OUT <= conv_std_logic_vector(G_OUT_blur/(BLUR_KERNEL), G_OUT'length);
				end if;

				B_OUT_blur := 0;
				for ii in 0 to BLUR_KERNEL loop
					B_OUT_blur := B_OUT_blur + RGB_split_grid_p(ii)(2);
				end loop;
				if F_ON='1' then
					B_OUT <= conv_std_logic_vector(B_OUT_blur/(BLUR_KERNEL), B_OUT'length);
				end if;

				-- R_OUT <= conv_std_logic_vector(
				-- RGB_split_grid(0)(0)/9 +
				-- RGB_split_grid(1)(0)/9 +
				-- RGB_split_grid(2)(0)/9 +
				-- RGB_split_grid(3)(0)/9 +
				-- RGB_split_grid(4)(0)/9 +
				-- RGB_split_grid(5)(0)/9 +
				-- RGB_split_grid(6)(0)/9 +
				-- RGB_split_grid(7)(0)/9 +
				-- RGB_split_grid(8)(0)/9, R_OUT'length);
				
				-- G_OUT <= conv_std_logic_vector(
				-- RGB_split_grid(0)(1)/9 +
				-- RGB_split_grid(1)(1)/9 +
				-- RGB_split_grid(2)(1)/9 +
				-- RGB_split_grid(3)(1)/9 +
				-- RGB_split_grid(4)(1)/9 +
				-- RGB_split_grid(5)(1)/9 +
				-- RGB_split_grid(6)(1)/9 +
				-- RGB_split_grid(7)(1)/9 +
				-- RGB_split_grid(8)(1)/9, G_OUT'length);

				-- B_OUT <= conv_std_logic_vector(
				-- RGB_split_grid(0)(2)/9 +
				-- RGB_split_grid(1)(2)/9 +
				-- RGB_split_grid(2)(2)/9 +
				-- RGB_split_grid(3)(2)/9 +
				-- RGB_split_grid(4)(2)/9 +
				-- RGB_split_grid(5)(2)/9 +
				-- RGB_split_grid(6)(2)/9 +
				-- RGB_split_grid(7)(2)/9 +
				-- RGB_split_grid(8)(2)/9, B_OUT'length);
				
				
			end if;

			if (H = '0' and L = '0' and (RESET_B='1' or RESET_C='1')) or 
				(RESET_BLUR='0' and RESET_B='0' and RESET_C='0') then
				R_OUT <= R_S;
				G_OUT <= G_S;
				B_OUT <= B_S;
			end if;
			
		end if;

		for ii in 0 to BLUR_KERNEL*BLUR_KERNEL-1 loop
			RGB_split_grid_p(ii)(0) <= RGB_split_grid(ii)(0);
			RGB_split_grid_p(ii)(1) <= RGB_split_grid(ii)(1);
			RGB_split_grid_p(ii)(2) <= RGB_split_grid(ii)(2);
		end loop;

		RGBp <= RGBn;
	end process;

end architecture arch;