
entity exp6_serial_in_top is
  port (
      SW : in bit_vector(9 downto 0);
      CLOCK_50 : in bit;
      GPIO_0 : in bit_vector(35 downto 0);
      GPIO_1 : out bit_vector(35 downto 0);
      KEY : in bit_vector(3 downto 0);
      LEDR : out bit_vector(9 downto 0);
      HEX0 : out bit_vector(7 downto 0);
      HEX1 : out bit_vector(6 downto 0);
      HEX2 : out bit_vector(6 downto 0);
      HEX3 : out bit_vector(6 downto 0);
      HEX4 : out bit_vector(6 downto 0);
      HEX5 : out bit_vector(6 downto 0)
  );
end exp6_serial_in_top;

architecture arch of exp6_serial_in_top is
  component hex2seg is
      port (
          hex : in bit_vector(3 downto 0); -- Entrada binaria
          seg : out bit_vector(6 downto 0) -- Saída hexadecimal
          -- A saída corresponde aos segmentos gfedcba nesta ordem. Cobre 
          -- todos valores possíveis de entrada.
      );
  end component;
  
  component ascii_display is
      port (
        input: in   bit_vector(7 downto 0); -- ASCII 8 bits
        output: out bit_vector(7 downto 0)  -- ponto + abcdefg
      );
    end component;

  component serial_in is
      generic (
        POLARITY : boolean;
        WIDTH : natural;
        PARITY : natural;
        CLOCK_MUL : positive
      );
      port (
        clock, reset, start, serial_data : in bit;
        done, parity_bit : out bit;
        parallel_data : out bit_vector(WIDTH - 1 downto 0)
      );
  end component;

  component clock_diviser is
    generic (
      -- INPUT_CLOCK : integer; 
      -- TARGET_CLOCK : integer
      CLOCK_MUL : integer
    );
    port (
      i_clk : in bit;
      i_rst : in bit;
      o_clk_div : out bit
    );
  end component;

  constant POLARITY : BOOLEAN := TRUE;
  constant WIDTH : NATURAL := 8;
  constant PARITY : NATURAL := 1;
  constant CLOCK_MUL : POSITIVE := 4;

  signal clock, reset : bit;

  signal start, serial_data, done, parity_bit : bit;

  signal parallel_data : bit_vector(WIDTH-1 downto 0);

  signal parallel_data_latch : bit_vector(WIDTH-1 downto 0);

  signal hex2seg_hex0_output, hex2seg_hex1_output : bit_vector(6 downto 0);
  signal display_hex0_output : bit_vector(7 downto 0);

begin   

  reset <= GPIO_0(0); --SEI LA COMO É ESSE GPIO;
  start <= GPIO_0(1); --SE N SABAI COMO FAZER O DO RESET, IMAGINA DESSE;

  CLOCK_DIVISER_INSTANCE : clock_diviser
  generic map(
    -- INPUT_CLOCK => 50000000,
    -- INPUT_CLOCK => 4800*4,
    -- TARGET_CLOCK => 4800*4
    CLOCK_MUL => 1301
  )
  port map(
      CLOCK_50, '0', clock
  );


      
  SERIAL_IN_INSTANCE : serial_in
  generic map(
      POLARITY => POLARITY,
      WIDTH => WIDTH,
      PARITY => PARITY,
      CLOCK_MUL => CLOCK_MUL
  )
  port map(
    clock, reset, start, serial_data,
    done, parity_bit,
    parallel_data
  );

  parallel_data_latch <= parallel_data_latch when parallel_data = "00000000" else parallel_data;

  serial_data <= GPIO_0(2);

  -- rst <= '1' when KEY(3) = '0' else '0';

  HEX0C_DISPLAY : ascii_display port map(parallel_data_latch(7 downto 0), display_hex0_output);

  
  HEX0 <= display_hex0_output(7 downto 0);
  
  
  -- HEX0C_HEX2SEG : hex2seg port map(parallel_data(3 downto 0), hex2seg_hex0_output);
  -- HEX1C_HEX2SEG : hex2seg port map(parallel_data(7 downto 4), hex2seg_hex1_output);
      
  HEX1 <= (others=>'1');
  HEX2 <= (others=>'1');
  HEX3 <= (others=>'1');
  HEX4 <= (others=>'1');
  HEX5 <= (others=>'1');

  LEDR(8) <= GPIO_0(2);
  LEDR(9) <= done;
  LEDR(7 downto 0) <= parallel_data(7 downto 0);

end architecture;

