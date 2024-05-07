
entity exp8_sha256_top is
  port (
      CLOCK_50 : in bit;
      LEDR : out bit_vector(9 downto 0);
      GPIO_0 : in bit_vector(35 downto 0);
      GPIO_1 : out bit_vector(35 downto 0)
  );
end exp8_sha256_top;

architecture arch of exp8_sha256_top is


  component clock_diviser is
    generic (
      CLOCK_MUL : integer
    );
    port (
      i_clk : in bit;
      i_rst : in bit;
      o_clk_div : out bit
    );
  end component;

  component sha256 is
    port (clock, reset : in  bit;		-- Clock da placa, GPIO_0_D2  
            serial_in    : in  bit;		-- GPIO_0_D0
            LEDR : out bit_vector(9 downto 0);
            serial_out	 : out bit		-- GPIO_0_D1
    );
  end component;

  signal clock : bit;

  signal reset, serial_in, serial_out : bit;


begin   

  SHA256_IMPL: sha256 port map(clock, reset, serial_in, LEDR, serial_out);

  reset <= GPIO_0(1); -- pino 15
  
  serial_in <= GPIO_0(0); -- pino 7
  GPIO_1(0) <= serial_out; -- pino 6

  CLOCK_DIVISER_INSTANCE : clock_diviser
  generic map(
    -- CLOCK_MUL => 1301
    CLOCK_MUL => (50000000/19200)/2 
  )
  port map(
      CLOCK_50, '0', clock
  );



end architecture;


  -------   DIVISOR DE CLOCK 


  library IEEE;
  use IEEE.numeric_bit.all;
  
  entity clock_diviser is
    generic (
      CLOCK_MUL : integer
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
        counter <= 0;
      elsif (rising_edge(i_clk)) then
          counter <= counter + 1;
  
          if counter=CLOCK_MUL then
              clk <= not clk;
              counter <= 0;
          end if;
      end if;
    end process p_clk_divider;
  
    o_clk_div <= clk;
  end rtl;
