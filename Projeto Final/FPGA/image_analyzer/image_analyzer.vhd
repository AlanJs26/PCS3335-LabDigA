library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-- use ieee.NUMERIC_STD.all;
-- use ieee.NUMERIC_STD_UNSIGNED.all;
---------------------------------------- MARK: Entity --------------------------------------------------  

entity image_analyzer is
    generic (
        WIDTH : integer := 800;
        HEIGHT : integer := 600;
        COLOR_DEPTH : integer := 24
    );
    port (
        clock, reset : in std_logic;
        done : std_logic;
        filter : std_logic_vector(1 downto 0);

        VGA_HS : out std_logic;
        VGA_VS : out std_logic;
        VGA_R : out std_logic_vector(3 downto 0);
        VGA_G : out std_logic_vector(3 downto 0);
        VGA_B : out std_logic_vector(3 downto 0)
    );
end image_analyzer;
---------------------------------------- MARK: Architecture --------------------------------------------------  
architecture arch of image_analyzer is

    component clock_diviser is
        generic (
        CLOCK_MUL : integer
        );
        port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        o_clk_div : out std_logic
        );
    end component;

    signal clock_div : std_logic;

    ---------------------------------------- MARK: Componente Serial In --------------------------------------------------  
    constant POLARITY : boolean := FALSE;
    constant PARITY : natural := 1;
    constant CLOCK_MUL : positive := 4;
    constant STOP_BITS : natural := 2;
    component serial_in is
        generic (
            POLARITY : boolean;
            WIDTH : natural;
            PARITY : natural;
            CLOCK_MUL : positive
        );
        port (
            clock, reset, start, serial_data : in std_logic;
            done, parity_bit, parity_calculado : out std_logic;
            parallel_data : out std_logic_vector(COLOR_DEPTH - 1 downto 0)
        );
    end component;

    signal reset_serial_in, start_serial_in, serial_data_in, done_serial_in, parity_bit, parity_calculado : std_logic;
    signal parallel_data : std_logic_vector(COLOR_DEPTH - 1 downto 0);

    ---------------------------------------- MARK: Componente Images Register --------------------------------------------------  
    
    -- constant ADDRESS_OFFSET_C : std_logic_vector(19 downto 0) := std_logic_vector(conv_unsigned(WIDTH * HEIGHT + 10, 20));
    signal ADDRESS_OFFSET_C : std_logic_vector(19 downto 0);
    
    component images_register is
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
    end component;

    signal x,y : integer;
    signal x_ram,y_ram : integer;
    signal x_vga,y_vga : integer;
    signal RW : std_logic;
    signal pixel : std_logic_vector(COLOR_DEPTH-1 downto 0);

    ---------------------------------------- MARK: Componente counter 2D --------------------------------------------------  

    component counter_2D is
        generic (
            WIDTH: integer;
            HEIGHT: integer
        );
        port (
            clock, reset: in std_logic;
            enable: in std_logic;
            x: out integer;
            y: out integer
        );
    end component;

    signal reset_counter_2D : std_logic;
    signal enable_counter_2D : std_logic;

    ---------------------------------------- MARK: Componente VGA --------------------------------------------------  

    component VGA is
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
    
            pixel : in std_logic_vector(COLOR_DEPTH-1 downto 0)
        );
    end component;

    signal reset_VGA, done_VGA : std_logic;    

    ---------------------------------------- MARK: UNITED STATES OF SMASH! --------------------------------------------------  

    type state_t is (wait_start, recebendo, processando, enviando);
    signal next_state, current_state : state_t;

    begin
    ---------------------------------------- MARK: Port Maps e Signals ---------------------------------------- 
    SERIAL_IN_INSTANCE : serial_in
    generic map(
        POLARITY => POLARITY,
        WIDTH => COLOR_DEPTH,
        PARITY => PARITY,
        CLOCK_MUL => CLOCK_MUL
    )
    port map(
        clock_div, reset_serial_in, start_serial_in, serial_data_in,
        done_serial_in, parity_bit, parity_calculado,
        parallel_data
    );

    CLOCK_DIVISER_INSTANCE : clock_diviser
    generic map(
        CLOCK_MUL => (50000000/(115200*4))/2
    )
    port map(
        i_clk => clock,
        i_rst => '0',
        o_clk_div => clock_div
    );


    IMAGES_REGISTER_INSTANCE : images_register
    generic map(
        WIDTH => WIDTH,
        HEIGHT => HEIGHT,
        COLOR_DEPTH => COLOR_DEPTH
    )
    port map(
        clock => clock,
        x => x_ram,
        y => y_ram,
        RW => RW,
        address_offset => ADDRESS_OFFSET_C,
        data => parallel_data,
        pixel => pixel
    );

    COUNTER_2D_INSTANCE : counter_2D
    generic map(
        WIDTH => WIDTH,
        HEIGHT => HEIGHT
    )
    port map(
        clock => clock,
        reset => reset_counter_2D,
        enable => enable_counter_2D, 
        x => x,
        y => y
    );

    VGA_INSTANCE : VGA
    generic map(
        WIDTH => WIDTH,
        HEIGHT => HEIGHT,
        COLOR_DEPTH => COLOR_DEPTH
    )
    port map(
        clock => clock, 
        reset => reset_VGA,
        VGA_HS => VGA_HS,
        VGA_VS => VGA_VS,
        VGA_R => VGA_R,
        VGA_G => VGA_G,
        VGA_B => VGA_B,

        x => x_vga,
        y => y_vga,
        address_offset => ADDRESS_OFFSET_C, 
        pixel => pixel,
        done => done_VGA
    );

    ---------------------------------------- MARK: Process ---------------------------------------- 

    STATES_PROCESS : process (clock, reset)
    begin
        if reset = '1' then
            current_state <= wait_start;
        elsif rising_edge(clock) then
            current_state <= next_state;
        end if;
    end process;

    -- Logica de proximo estado
    next_state <=
        wait_start when current_state = wait_start else
        recebendo when current_state = wait_start and done_serial_in = '1' and parity_calculado = parity_bit else
        processando when current_state = recebendo and (x = WIDTH and y = HEIGHT) else
        enviando when current_state = processando and done_vga = '0' else
        current_state;


    enable_counter_2D <= '1' when done_serial_in = '1' else '0';
    reset_counter_2D <= '1' when current_state = wait_start else '0';
    RW <= '1' when done_serial_in = '1' else '0';

    x_ram <= x when current_state /= enviando else x_vga;
    y_ram <= y when current_state /= enviando else y_vga;

    reset_VGA <= '0' when current_state = enviando else '1';


    -- Completar a maquina de estados para que fique alternando entre os estados processando e enviando atÃÂ© que um novo sinal serial seja recebido
    -- Adicionar os filtros
    -- modificar o VGA para que ele leia a imagem da memoria ram e mostre na tela

end;