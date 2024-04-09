
entity exp5_serial_out_top is
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
end exp5_serial_out_top;

architecture arch of exp5_serial_out_top is
    component hex2seg is
        port (
            hex : in bit_vector(3 downto 0); -- Entrada binaria
            seg : out bit_vector(6 downto 0) -- SaÃ­da hexadecimal
            -- A saÃ­da corresponde aos segmentos gfedcba nesta ordem. Cobre 
            -- todos valores possÃ­veis de entrada.
        );
    end component;
    
    component display is
        port (
          input: in   bit_vector(7 downto 0); -- ASCII 8 bits
          output: out bit_vector(7 downto 0)  -- ponto + abcdefg
        );
      end component;

    component serial_out is
        generic (
            POLARITY : BOOLEAN;
            WIDTH : NATURAL;
            PARITY : NATURAL;
            STOP_BITS : NATURAL
        );
        port (
            clock, reset, tx_go : in BIT;
            data : in bit_vector(WIDTH - 1 downto 0);
            tx_done : out BIT;
            serial_o : out BIT
        );
    end component;

    component clock_diviser is
        generic (
            CLOCK_MUL : positive
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
    constant STOP_BITS : NATURAL := 2;

    signal clock, reset, tx_go : bit;
    signal data : bit_vector(WIDTH - 1 downto 0);
    signal tx_done, serial_o : bit;

    signal hex2seg_hex0_output, hex2seg_hex1_output : bit_vector(6 downto 0);
    signal display_hex0_output : bit_vector(7 downto 0);

begin   
    data(WIDTH - 1 downto 0) <= SW(WIDTH - 1 downto 0);

    reset <= GPIO_0(0); --SEI LA COMO Ã ESSE GPIO;
    tx_go <= GPIO_0(1); --SE N SABAI COMO FAZER O DO RESET, IMAGINA DESSE;

    CLOCK_DIVISER_INSTANCE : clock_diviser
    generic map(
        CLOCK_MUL => 10416
    )
    port map(
        CLOCK_50, '0', clock
    );
        
    SERIAL_OUT_INSTANCE : serial_out 
    generic map(
        POLARITY => POLARITY,
        WIDTH => WIDTH,
        PARITY => PARITY,
        STOP_BITS => STOP_BITS
    )
    port map(
        clock, reset, tx_go,
        data,
        tx_done,
        serial_o
    );

    GPIO_1(2) <= serial_o;

    -- rst <= '1' when KEY(3) = '0' else '0';
     


    HEX0C_DISPLAY : display port map(data(7 downto 0), display_hex0_output);

    
    HEX0 <= display_hex0_output(7 downto 0) when KEY(3) = '1' else '0' & hex2seg_hex0_output;
    
    HEX1 <= hex2seg_hex1_output when KEY(3) = '0' else (others=>'1');


    HEX0C_HEX2SEG : hex2seg port map(data(3 downto 0), hex2seg_hex0_output);
    HEX1C_HEX2SEG : hex2seg port map(data(7 downto 4), hex2seg_hex1_output);

    HEX2 <= (others=>'1');
    HEX3 <= (others=>'1');
    HEX4 <= (others=>'1');
    HEX5 <= (others=>'1');

    LEDR(9) <= tx_done;
    LEDR(7 downto 0) <= data(7 downto 0);

end architecture;


-- CLOCK DIVISER

library IEEE;
use IEEE.numeric_bit.all;

entity clock_diviser is
  generic (
    CLOCK_MUL : positive := 4
  );
  port (
    i_clk : in bit;
    i_rst : in bit;
    o_clk_div : out bit
  );
end clock_diviser;
architecture rtl of clock_diviser is

  signal clk : bit;
  signal counter : integer := 0;

begin
  p_clk_divider : process (i_clk)
  begin
    if i_rst='1' then
      clk <= '0';
      counter <= 1;
    elsif (rising_edge(i_clk)) then
        counter <= counter + 1;

        if counter=10417 then
            clk <= not clk;
            counter <= 1;
        end if;
    end if;
  end process p_clk_divider;

  o_clk_div <= clk;
end rtl;
