library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.NUMERIC_STD.all;
use ieee.NUMERIC_STD_UNSIGNED.all;


entity images_register is
    generic (
        WIDTH : integer := 800;
        HEIGHT : integer := 600;
        COLOR_DEPTH : integer := 24
    );
    port (
        clock : in std_logic;
        x, y : in integer;
        RW : in std_logic;
        address_offset : in std_logic_vector(19 downto 0);
        
        data : in std_logic_vector(COLOR_DEPTH-1 downto 0);

        pixel : out std_logic_vector(COLOR_DEPTH-1 downto 0)
    );
end images_register;
architecture arch of images_register is

    component ram1port is
        port (
            clock : in std_logic := '1';
            address : in std_logic_vector (19 downto 0);
            data : in std_logic_vector (COLOR_DEPTH-1 downto 0);
            wren : in std_logic;
            q : out std_logic_vector (COLOR_DEPTH-1 downto 0)
        );
    end component;

    signal xy_address : std_logic_vector(19 downto 0);

begin

    RAM1PORT_INSTANCE : ram1port port map (
        address => xy_address + address_offset,
        clock => clock,
        data => data,
        wren => RW,
        q => pixel
    );
    
    xy_address <= std_logic_vector(to_unsigned((x + y * WIDTH) * 3, 20));

    
end arch;