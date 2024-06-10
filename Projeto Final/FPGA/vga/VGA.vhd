library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- use ieee.NUMERIC_STD.all;

entity VGA is
    generic (
        WIDTH : integer := 800;
        HEIGHT : integer := 600;
        COLOR_DEPTH : integer := 24;
        RAM_WORD : integer;
        RAM_ADDRESS : integer
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
        address_offset : out std_logic_vector(RAM_ADDRESS-1 downto 0);

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

    signal done_s,x_valid,y_valid : std_logic;

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
    VGA_R <= pixel(11 downto 8) when x_valid='1' and y_valid='1' else (others=>'0');
    VGA_G <= pixel(7 downto 4) when x_valid='1' and y_valid='1' else (others=>'0');
    VGA_B <= pixel(3 downto 0) when x_valid='1' and y_valid='1' else (others=>'0');


    VGA_HS <= H_SYNC_SIGNAL;
    VGA_VS <= V_SYNC_SIGNAL;


    address_offset <= (others=>'0');
    x <= conv_integer(unsigned(CURRENT_COLUMN)) when x_valid='1' else 0;
    y <= conv_integer(unsigned(CURRENT_ROW)) when y_valid='1' else 0;

    x_valid <= '1' when CURRENT_COLUMN < std_logic_vector(conv_unsigned(WIDTH, CURRENT_COLUMN'length)) else '0';
    y_valid <= '1' when CURRENT_ROW < std_logic_vector(conv_unsigned(HEIGHT, CURRENT_ROW'length)) else '0';

    done_s <= '1' when x_valid='0' and y_valid='0' else
            '0';
    -- done_s <= '1' when conv_integer(unsigned(CURRENT_COLUMN)) >= 800 and   else
    --         '0';

    done <= done_s;

end arch;