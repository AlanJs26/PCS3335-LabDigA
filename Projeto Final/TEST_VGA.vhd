
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
 
ENTITY DE0_NANO IS
    PORT ( 
        CLOCK_50 : IN STD_LOGIC;
        KEY       : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		  SW        : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        VGA_HS    : OUT STD_LOGIC;        
        VGA_VS   : OUT STD_LOGIC;
        VGA_R            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        VGA_G            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        VGA_B            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		  GPIO_1           : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		  LEDR             : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
		  );
END DE0_NANO;
 
ARCHITECTURE arch OF DE0_NANO IS
 
COMPONENT VGASync IS
    PORT(
        RESET : IN STD_LOGIC;
        F_CLOCK : IN STD_LOGIC;
        F_HSYNC : OUT STD_LOGIC;
        F_VSYNC : OUT STD_LOGIC;
        F_ROW : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        F_COLUMN : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
        F_DISP_ENABLE : OUT STD_LOGIC
    );
END COMPONENT VGASync;
 
COMPONENT PixelGen IS
    generic(
        BLUR_KERNEL : integer := 5
    );
    PORT(
        RESET_B, RESET_C, RESET_BLUR : IN STD_LOGIC;
        F_CLOCK : IN STD_LOGIC;
        F_ON : IN STD_LOGIC;
        F_ROW : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        F_COLUMN : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		  H: IN STD_LOGIC;
		  L: IN STD_LOGIC;
        R_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        G_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        B_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END COMPONENT PixelGen;
 
SIGNAL RESET, RESET_B, RESET_C, RESET_BLUR : STD_LOGIC;
 
--�ndice da linha/coluna atual
SIGNAL CURRENT_ROW : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL CURRENT_COLUMN : STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL DISP_ENABLE : STD_LOGIC;

SIGNAL H_SYNC_SIGNAL, V_SYNC_SIGNAL : STD_LOGIC;
SIGNAL R_SIGNAL, G_SIGNAL, B_SIGNAL : STD_LOGIC_VECTOR(3 DOWNTO 0);
 
BEGIN
 
    --M�dulo de sincronismo
    VGA : VGASync PORT MAP(
                RESET => RESET,
                F_CLOCK => CLOCK_50, 
                F_HSYNC => H_SYNC_SIGNAL, 
                F_VSYNC => V_SYNC_SIGNAL, 
                F_ROW => CURRENT_ROW,
                F_COLUMN => CURRENT_COLUMN,
                F_DISP_ENABLE => DISP_ENABLE);
 
    --M�dulo para gerar os pixels
    PIXELS : PixelGen 
                generic map (
                    BLUR_KERNEL => 5
                )
                PORT MAP(
                RESET_B => RESET_B,
					 RESET_C => RESET_C,
					 RESET_BLUR => RESET_BLUR,
                F_CLOCK => CLOCK_50, 
                F_ON => DISP_ENABLE,
                F_ROW => CURRENT_ROW,
                F_COLUMN => CURRENT_COLUMN,
                H => not KEY(3),
                L => not KEY(2),
                R_OUT => R_SIGNAL,
                G_OUT => G_SIGNAL,
                B_OUT => B_SIGNAL);

	RESET <= SW(9);
	RESET_B <= SW(0);
	RESET_C <= SW(1);
	RESET_BLUR <= SW(2);	
					 
	--Associação de pinos para conexão VGA 
	VGA_R <= R_SIGNAL;
	VGA_G <= G_SIGNAL;
	VGA_B <= B_SIGNAL;
	
	VGA_HS <= H_SYNC_SIGNAL;
	VGA_VS <= V_SYNC_SIGNAL;
	
	--Sinais de controle
	GPIO_1(0) <= H_SYNC_SIGNAL;
	LEDR(0) <= RESET;
	
    
END arch;