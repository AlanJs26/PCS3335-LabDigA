library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity top_entity is
  port (
	 CLOCK_50: in std_logic;
     LEDR : out std_logic_vector(9 downto 0);

     GPIO_1 : in std_logic_vector(35 downto 0);

     VGA_HS : out std_logic;
     VGA_VS : out std_logic;
     VGA_R : out std_logic_vector(3 downto 0);
     VGA_G : out std_logic_vector(3 downto 0);
     VGA_B : out std_logic_vector(3 downto 0)
  );
end top_entity ;

architecture arch of top_entity is

    component image_analyzer is
        generic (
            WIDTH : integer;
            HEIGHT : integer;
            COLOR_DEPTH : integer := 24
        );
        port (
            clock, reset : in std_logic;
            filter : in std_logic_vector(1 downto 0);

            GPIO_1 : in std_logic_vector(35 downto 0);

            LEDR : out std_logic_vector(9 downto 0);
    
            VGA_HS : out std_logic;
            VGA_VS : out std_logic;
            VGA_R : out std_logic_vector(3 downto 0);
            VGA_G : out std_logic_vector(3 downto 0);
            VGA_B : out std_logic_vector(3 downto 0)
        );
    end component;

	 
begin


    IMAGE_ANALYZER_INSTANCE : image_analyzer
    generic map(
        WIDTH => 200,
        HEIGHT => 200,
        COLOR_DEPTH => 12
    )
    port map(
        clock => CLOCK_50,
        reset => '0',
        filter => "00",

        GPIO_1 => GPIO_1,
        LEDR => LEDR,

        VGA_HS => VGA_HS,
        VGA_VS => VGA_VS,
        VGA_R => VGA_R,
        VGA_G => VGA_G,
        VGA_B => VGA_B 
    );
	 
	 
end architecture;