library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
 
entity DE0_NANO is
    port ( 
        CLOCK_50 : in std_logic;
        KEY      : in std_logic_vector(3 downto 0);
        VGA_HS   : out std_logic;
        VGA_VS   : out std_logic;
        VGA_R    : out std_logic_vector(3 downto 0);
        VGA_G    : out std_logic_vector(3 downto 0);
        VGA_B    : out std_logic_vector(3 downto 0);
        GPIO_1   : out std_logic_vector(35 downto 0);
        LEDR     : out std_logic_vector(9 downto 0)
    );
end DE0_NANO;
 
architecture arch OF DE0_NANO IS
 
component VGASync is
    port(
        RESET         : in std_logic;
        F_CLOCK       : in std_logic;
        F_HSYNC       : out std_logic;
        F_VSYNC       : out std_logic;
        F_ROW         : out std_logic_vector(9 downto 0);
        F_COLUMN      : out std_logic_vector(10 downto 0);
        F_DISP_ENABLE : out std_logic
    );
end component VGASync;
 
component PixelGen IS
    port(
        RESET    : in std_logic;
        F_CLOCK  : in std_logic;
        F_ON     : in std_logic;
        F_ROW    : in std_logic_vector(9 downto 0);
        F_COLUMN : in std_logic_vector(10 downto 0);
        R_OUT    : out std_logic;
        G_OUT    : out std_logic;
        B_OUT    : out std_logic
    );
end component PixelGen;
 
signal RESET : std_logic;
 
--�ndice da linha/coluna atual
signal CURRENT_ROW : std_logic_vector(9 downto 0);
signal CURRENT_COLUMN : std_logic_vector(10 downto 0);
signal DISP_ENABLE : std_logic;

signal H_SYNC_SIGNAL, V_SYNC_SIGNAL : std_logic;
signal R_SIGNAL, G_SIGNAL, B_SIGNAL : std_logic;
 
BEGIN
 
    --M�dulo de sincronismo
    VGA : VGASync port map(
                RESET => RESET,
                F_CLOCK => CLOCK_50, 
                F_HSYNC => H_SYNC_SIGNAL, 
                F_VSYNC => V_SYNC_SIGNAL, 
                F_ROW => CURRENT_ROW,
                F_COLUMN => CURRENT_COLUMN,
                F_DISP_ENABLE => DISP_ENABLE);
 
    --M�dulo para gerar os pixels
    PIXELS : PixelGen port map(
                RESET => RESET,
                F_CLOCK => CLOCK_50, 
                F_ON => DISP_ENABLE,
                F_ROW => CURRENT_ROW,
                F_COLUMN => CURRENT_COLUMN,
                R_OUT => R_SIGNAL,
                G_OUT => G_SIGNAL,
                B_OUT => B_SIGNAL);

	RESET <= KEY(0);			 
					 
	--Associação de pinos para conexão VGA 
	VGA_R <= R_SIGNAL & R_SIGNAL & R_SIGNAL & R_SIGNAL;
	VGA_G <= G_SIGNAL & G_SIGNAL & G_SIGNAL & G_SIGNAL;
	VGA_B <= B_SIGNAL & B_SIGNAL & B_SIGNAL & B_SIGNAL;
	
	VGA_HS <= H_SYNC_SIGNAL;
	VGA_VS <= V_SYNC_SIGNAL;
	
	--Sinais de controle
	GPIO_1(0) <= H_SYNC_SIGNAL;
	
	LEDR(0) <= RESET;
    
end arch;
