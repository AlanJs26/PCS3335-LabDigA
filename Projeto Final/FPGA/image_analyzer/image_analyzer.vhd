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
        filter : in std_logic_vector(1 downto 0);
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
end image_analyzer;
---------------------------------------- MARK: Architecture --------------------------------------------------  
architecture arch of image_analyzer is

    signal enable_all : std_logic;

    ---------------------------------------- MARK: Componente Hex2Seg --------------------------------------------------  

    component hex2seg is
        port ( hex : in  std_logic_vector(3 downto 0); -- Entrada binaria
               seg : out std_logic_vector(6 downto 0)  -- Saída hexadecimal
               -- A saída corresponde aos segmentos gfedcba nesta ordem. Cobre 
               -- todos valores possíveis de entrada.
            );
    end component;

    ---------------------------------------- MARK: Componente Clock Diviser --------------------------------------------------  
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
            parallel_data : out std_logic_vector(7 downto 0)
        );
    end component;

    signal reset_serial_in, start_serial_in, serial_data_in, done_serial_in, parity_bit, parity_calculado : std_logic;
    signal parallel_data : std_logic_vector(7 downto 0);

    ---------------------------------------- MARK: Componente Images Register --------------------------------------------------  
    
    constant RAM_WORD : integer := 12;
	constant RAM_ADDRESS : integer := 17;

    -- constant ADDRESS_OFFSET_C : std_logic_vector(19 downto 0) := std_logic_vector(conv_unsigned(WIDTH * HEIGHT + 10, 20));
    signal ADDRESS_OFFSET_C : std_logic_vector(RAM_ADDRESS-1 downto 0);
    
    component images_register is
        generic (
            WIDTH : integer := 800;
            HEIGHT : integer := 600;
            COLOR_DEPTH : integer := 24;
            RAM_WORD : integer;
            RAM_ADDRESS : integer
        );
        port (
            clock : in std_logic;
            x, y : in integer;
            RW : in std_logic;
            address_offset : in std_logic_vector(RAM_ADDRESS-1 downto 0);
            data : in std_logic_vector(COLOR_DEPTH-1 downto 0);
    
            pixel : out std_logic_vector(COLOR_DEPTH-1 downto 0)
        );
    end component;

    signal x_counter,y_counter : integer;
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

    signal reset_counter_2D, clock_counter_2D : std_logic;
    signal enable_counter_2D : std_logic;

    ---------------------------------------- MARK: Componente counter --------------------------------------------------  

    component counter is
        generic(
            MAX: integer
        );
        port (
            clock, reset : in std_logic;
            enable : in std_logic;
            q : out integer
        );
    end component;

    signal word_counter : integer := 0;
    signal reset_counter, enable_counter : std_logic;

    ---------------------------------------- MARK: Componente VGA --------------------------------------------------  

    component VGA is
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
    
            pixel : in std_logic_vector(COLOR_DEPTH-1 downto 0)
        );
    end component;

    signal reset_VGA, done_VGA : std_logic;    

    ---------------------------------------- MARK: Componente Shift Register --------------------------------------------------  

    component shift_register is
        generic (
            WIDTH_IN : natural;
            WIDTH : natural
        );
        port (
            clk, reset, enable : in std_logic;
            data_in : in std_logic_vector(WIDTH_IN - 1 downto 0);
            data_out : out std_logic_vector(WIDTH - 1 downto 0)
        );
    end component;

    signal enable_shift_register, reset_shift_register : std_logic;
    signal data_shift_register : std_logic_vector(RAM_WORD-1 downto 0);

    ---------------------------------------- MARK: Detector de Borda --------------------------------------------------  

    component detector_borda is
        generic (
            subida : boolean := true
        );
        port (
            clock	: in std_logic;
            reset	: in std_logic;
            borda	: in std_logic;
            update: out std_logic
        );
    end component;

    signal done_serial_in_borda, reset_detector_borda : std_logic;

    ---------------------------------------- MARK: Maquina de Estados --------------------------------------------------  

    type state_t is (wait_start, recebendo, processando, enviando);
    signal next_state, current_state : state_t;

    begin
    ---------------------------------------- MARK: Port Maps e Signals ---------------------------------------- 
    CLOCK_DIVISER_INSTANCE : clock_diviser
    generic map(
        CLOCK_MUL => (50000000/(115200*2*4))/2
    )
    port map(
        i_clk => clock,
        i_rst => '0',
        o_clk_div => clock_div
    );
    
    SERIAL_IN_INSTANCE : serial_in
    generic map(
        POLARITY => POLARITY,
        WIDTH => 8,
        PARITY => PARITY,
        CLOCK_MUL => CLOCK_MUL
    )
    port map(
        clock_div, reset_serial_in, start_serial_in, serial_data_in,
        done_serial_in, parity_bit, parity_calculado,
        parallel_data
    );

    IMAGES_REGISTER_INSTANCE : images_register
    generic map(
        WIDTH => WIDTH,
        HEIGHT => HEIGHT,
        COLOR_DEPTH => COLOR_DEPTH,
        RAM_WORD => RAM_WORD,
        RAM_ADDRESS => RAM_ADDRESS
    )
    port map(
        clock => clock,
        x => x_ram,
        y => y_ram,
        RW => RW,
        address_offset => ADDRESS_OFFSET_C,
        data => data_shift_register,
        pixel => pixel
    );

    COUNTER_2D_INSTANCE : counter_2D
    generic map(
        WIDTH => WIDTH,
        HEIGHT => HEIGHT
    )
    port map(
        clock => clock_counter_2D,
        reset => reset_counter_2D,
        enable => enable_counter_2D, 
        x => x_counter,
        y => y_counter
    );

    COUNTER_INSTANCE : counter
    generic map(
        MAX => 3
    )
    port map(
        clock => done_serial_in_borda,
        enable => enable_counter,
        reset => reset_counter,
        q => word_counter
    );

    VGA_INSTANCE : VGA
    generic map(
        WIDTH => WIDTH,
        HEIGHT => HEIGHT,
        COLOR_DEPTH => COLOR_DEPTH,
        RAM_WORD => RAM_WORD,
        RAM_ADDRESS => RAM_ADDRESS
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

    SHIFT_REGISTER_INSTANCE : shift_register
    generic map(
        WIDTH_IN => 4,
        WIDTH => RAM_WORD
    )
    port map(
        clk => clock,
        reset => reset_shift_register,
        enable => enable_shift_register,
        data_in => parallel_data(3 downto 0),
        data_out => data_shift_register
    );

    DETECTOR_BORDA_INSTANCE : detector_borda
    generic map(
        subida => false
    )
    port map(
        clock => clock,
        reset => reset_detector_borda,
        borda => done_serial_in,
        update => done_serial_in_borda
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
        wait_start when current_state = enviando and done_vga = '1' else
        recebendo when current_state = wait_start and done_serial_in_borda = '1' and (enable_all='1' or parallel_data="10101010") else
        -- recebendo when current_state = wait_start and done_serial_in = '1' and parity_calculado = parity_bit else
        processando when current_state = recebendo and (x_counter = WIDTH-1 and y_counter = HEIGHT-1) else
        enviando when current_state = processando else
        current_state;


    LEDR(9 downto 6) <= (others=>'0');
    LEDR(5) <= reset;
    LEDR(4) <= done_serial_in;
    LEDR(3 downto 0) <= "0001" when current_state = wait_start else
                        "0010" when current_state = recebendo else
                        "0100" when current_state = processando else
                        "1000" when current_state = enviando else
                        "0000";

    
    reset_serial_in <= '0';
    start_serial_in <= '1';
    enable_shift_register <= '1' when done_serial_in_borda = '1' else '0';
    reset_shift_register <= '1' when current_state = wait_start else '0';

    RW <= '1' when done_serial_in = '1' and word_counter = 2 and (current_state = processando or current_state = recebendo) else '0';

    x_ram <= x_counter when current_state /= enviando and current_state /= wait_start else x_vga;
    y_ram <= y_counter when current_state /= enviando and current_state /= wait_start else y_vga;

    -- reset_VGA <= '0' when current_state = enviando or current_state = wait_start else '1';
    reset_VGA <= '0';

    reset_detector_borda <= '1' when current_state=enviando else '0';

    clock_counter_2D <= '1' when done_serial_in_borda='1' and word_counter = 2 else '0';
    enable_counter_2D <= '1' when current_state = recebendo;
    reset_counter_2D <= '1' when current_state = wait_start else '0';

    enable_counter <= '1' when current_state = recebendo;
    reset_counter <= '1' when current_state = wait_start else '0';

    serial_data_in <= GPIO_1(0);
    enable_all <= not KEY(2);


    -- DISPLAY X
    HEX0_INSTANCE: HEX2Seg
	Port map (
		hex => std_logic_vector(conv_unsigned(y_counter mod 10, 4)),
		seg => HEX0
	);
    HEX1_INSTANCE: HEX2Seg
	Port map (
		hex => std_logic_vector(conv_unsigned(y_counter/10 mod 10, 4)),
		seg => HEX1
	);
    HEX2_INSTANCE: HEX2Seg
	Port map (
		hex => std_logic_vector(conv_unsigned(y_counter/100 mod 10, 4)),
		seg => HEX2
	);

    -- DISPLAY Y
    HEX3_INSTANCE: HEX2Seg
	Port map (
		hex => std_logic_vector(conv_unsigned(x_counter mod 10, 4)),
		seg => HEX3
	);
    HEX4_INSTANCE: HEX2Seg
	Port map (
		hex => std_logic_vector(conv_unsigned(x_counter/10 mod 10, 4)),
		seg => HEX4
	);
    HEX5_INSTANCE: HEX2Seg
	Port map (
		hex => std_logic_vector(conv_unsigned(x_counter/100 mod 10, 4)),
		seg => HEX5
	);
    

    -- Completar a maquina de estados para que fique alternando entre os estados processando e enviando atÃƒÂƒÃ‚Â© que um novo sinal serial seja recebido
    -- Adicionar os filtros
    -- modificar o VGA para que ele leia a imagem da memoria ram e mostre na tela

end;