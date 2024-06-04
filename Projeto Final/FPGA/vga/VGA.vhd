library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- use ieee.NUMERIC_STD.all;

entity VGA is
    generic (
        WIDTH : integer := 800;
        HEIGHT : integer := 600;
        COLOR_DEPTH : integer := 24
    );
    port (
        clock, reset : in std_logic;
        VGA_HS : out std_logic;
        VGA_VS : out std_logic;
        VGA_R : out std_logic_vector(3 downto 0);
        VGA_G : out std_logic_vector(3 downto 0);
        VGA_B : out std_logic_vector(3 downto 0);

        done : out std_logic;
        
        x, y : out integer;
        address_offset : out std_logic_vector(19 downto 0);

        pixel : in std_logic_vector(COLOR_DEPTH - 1 downto 0)
    );
end VGA;

architecture arch of VGA is

    component VGASync is
        port (
            RESET : in std_logic;
            F_CLOCK : in std_logic;
            F_HSYNC : out std_logic;
            F_VSYNC : out std_logic;
            F_ROW : out std_logic_vector(9 downto 0);
            F_COLUMN : out std_logic_vector(10 downto 0);
            F_DISP_ENABLE : out std_logic
        );
    end component VGASync;

    --�ndice da linha/coluna atual
    signal CURRENT_ROW : std_logic_vector(9 downto 0);
    signal CURRENT_COLUMN : std_logic_vector(10 downto 0);
    signal DISP_ENABLE : std_logic;

    signal H_SYNC_SIGNAL, V_SYNC_SIGNAL : std_logic;
    signal R_SIGNAL, G_SIGNAL, B_SIGNAL : std_logic;

begin

    --M�dulo de sincronismo
    VGA : VGASync port map(
        RESET => RESET,
        F_CLOCK => clock,
        F_HSYNC => H_SYNC_SIGNAL,
        F_VSYNC => V_SYNC_SIGNAL,
        F_ROW => CURRENT_ROW,
        F_COLUMN => CURRENT_COLUMN,
        F_DISP_ENABLE => DISP_ENABLE);

    --Associação de pinos para conexão VGA 
    VGA_R <= pixel(19 downto 16);
    VGA_G <= pixel(11 downto 8);
    VGA_B <= pixel(3 downto 0);

    VGA_HS <= H_SYNC_SIGNAL;
    VGA_VS <= V_SYNC_SIGNAL;


    address_offset <= (others=>'0');
    x <= conv_integer(unsigned(CURRENT_COLUMN));
    y <= conv_integer(unsigned(CURRENT_ROW));

    done <= '1' when CURRENT_COLUMN = std_logic_vector(conv_unsigned(WIDTH, 11)) and CURRENT_ROW = std_logic_vector(conv_unsigned(HEIGHT, 10)) else
            '0';

end arch;