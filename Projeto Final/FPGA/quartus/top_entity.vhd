library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity top_entity is
  port (
	 CLOCK_50: in std_logic;
     LEDR : out std_logic_vector(9 downto 0);

     GPIO_1 : in std_logic_vector(35 downto 0);
     KEY : in std_logic_vector(3 downto 0);
     HEX0: out std_logic_vector(6 downto 0);
     HEX1: out std_logic_vector(6 downto 0);
     HEX2: out std_logic_vector(6 downto 0);
     HEX3: out std_logic_vector(6 downto 0);
     HEX4: out std_logic_vector(6 downto 0);
     HEX5: out std_logic_vector(6 downto 0);

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
            KEY : in std_logic_vector(3 downto 0);
            HEX0: out std_logic_vector(6 downto 0);
            HEX1: out std_logic_vector(6 downto 0);
            HEX2: out std_logic_vector(6 downto 0);
            HEX3: out std_logic_vector(6 downto 0);
            HEX4: out std_logic_vector(6 downto 0);
            HEX5: out std_logic_vector(6 downto 0);


            LEDR : out std_logic_vector(9 downto 0);
    
            VGA_HS : out std_logic;
            VGA_VS : out std_logic;
            VGA_R : out std_logic_vector(3 downto 0);
            VGA_G : out std_logic_vector(3 downto 0);
            VGA_B : out std_logic_vector(3 downto 0)
        );
    end component;

    signal reset : std_logic;

    -- component counter_2D is
    --     generic (
    --         WIDTH: integer;
    --         HEIGHT: integer
    --     );
    --     port (
    --         clock, reset: in std_logic;
    --         enable: in std_logic;
    --         x: out integer;
    --         y: out integer
    --     );
    -- end component;

    -- signal reset_counter_2D : std_logic;
    -- signal enable_counter_2D : std_logic;
    -- signal x_counter, y_counter : integer;

    -- component detector_borda is
    --     generic (
    --         subida : boolean := true
    --     );
    --     port (
    --         clock	: in std_logic;
    --         reset	: in std_logic;
    --         borda	: in std_logic;
    --         update: out std_logic
    --     );
    -- end component;

    -- signal key_borda : std_logic;

    -- component hex2seg is
    --     port ( hex : in  std_logic_vector(3 downto 0); -- Entrada binaria
    --            seg : out std_logic_vector(6 downto 0)  -- Saída hexadecimal
    --            -- A saída corresponde aos segmentos gfedcba nesta ordem. Cobre 
    --            -- todos valores possíveis de entrada.
    --         );
    -- end component;


	 
begin


    IMAGE_ANALYZER_INSTANCE : image_analyzer
    generic map(
        WIDTH => 200,
        HEIGHT => 200,
        COLOR_DEPTH => 12
    )
    port map(
        clock => CLOCK_50,
        reset => reset,
        filter => "00",

        GPIO_1 => GPIO_1,
        KEY => KEY,
        HEX0 => HEX0,
        HEX1 => HEX1,
        HEX2 => HEX2,
        HEX3 => HEX3,
        HEX4 => HEX4,
        HEX5 => HEX5,

        LEDR => LEDR,

        VGA_HS => VGA_HS,
        VGA_VS => VGA_VS,
        VGA_R => VGA_R,
        VGA_G => VGA_G,
        VGA_B => VGA_B 
    );

    reset <= not KEY(3);


    -- COUNTER_2D_INSTANCE : counter_2D
    -- generic map(
    --     WIDTH => 5,
    --     HEIGHT => 5
    -- )
    -- port map(
    --     clock => key_borda,
    --     reset => reset,
    --     enable => '1', 
    --     x => x_counter,
    --     y => y_counter
    -- );

    -- DETECTOR_BORDA_INSTANCE : detector_borda
    -- generic map(
    --     subida => true
    -- )
    -- port map(
    --     clock => CLOCK_50,
    --     reset => reset,
    --     borda => not KEY(2),
    --     update => key_borda
    -- );



    -- -- DISPLAY X
    -- HEX0_INSTANCE: HEX2Seg
    -- Port map (
    --     hex => std_logic_vector(conv_unsigned(y_counter mod 10, 4)),
    --     seg => HEX0
    -- );
    -- HEX1_INSTANCE: HEX2Seg
    -- Port map (
    --     hex => std_logic_vector(conv_unsigned(y_counter/10 mod 10, 4)),
    --     seg => HEX1
    -- );
    -- HEX2_INSTANCE: HEX2Seg
    -- Port map (
    --     hex => std_logic_vector(conv_unsigned(y_counter/100 mod 10, 4)),
    --     seg => HEX2
    -- );

    -- -- DISPLAY Y
    -- HEX3_INSTANCE: HEX2Seg
    -- Port map (
    --     hex => std_logic_vector(conv_unsigned(x_counter mod 10, 4)),
    --     seg => HEX3
    -- );
    -- HEX4_INSTANCE: HEX2Seg
    -- Port map (
    --     hex => std_logic_vector(conv_unsigned(x_counter/10 mod 10, 4)),
    --     seg => HEX4
    -- );
    -- HEX5_INSTANCE: HEX2Seg
    -- Port map (
    --     hex => std_logic_vector(conv_unsigned(x_counter/100 mod 10, 4)),
    --     seg => HEX5
    -- );
	 
	 
end architecture;