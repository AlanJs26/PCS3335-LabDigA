
entity exp7_sha256_1b_top is
    port (
        -- SW : in bit_vector(9 downto 0);
        CLOCK_50 : in bit;
        GPIO_0 : in bit_vector(35 downto 0);
        GPIO_1 : out bit_vector(35 downto 0);
        -- KEY : in bit_vector(3 downto 0);
        LEDR : out bit_vector(9 downto 0);
        HEX0 : out bit_vector(7 downto 0);
        HEX1 : out bit_vector(7 downto 0);
        HEX2 : out bit_vector(7 downto 0);
        HEX3 : out bit_vector(7 downto 0);
        HEX4 : out bit_vector(7 downto 0);
        HEX5 : out bit_vector(7 downto 0)
    );
  end exp7_sha256_1b_top;
  
  architecture arch of exp7_sha256_1b_top is
    
    component ascii_display is
        port (
          input: in   bit_vector(7 downto 0); -- ASCII 8 bits
          output: out bit_vector(7 downto 0)  -- ponto + abcdefg
        );
      end component;

    component sha256_1b is
        port (
            clock, reset : in bit; -- Clock da placa, GPIO_0_D2  
            serial_in : in bit; -- GPIO_0_D0
            serial_out : out bit; -- GPIO_0_D1
            haso_sha256 : out bit_vector(255 downto 0)
        );
    end component;


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
  
    signal clock, reset, clock_19200 : bit;
  
    signal serial_in, serial_out : bit;

    signal haso_sha256 : bit_vector(255 downto 0);

  
  begin
  
    reset <= GPIO_0(0); -- GPIO 6;  
    serial_in <= GPIO_0(1); -- GPIO 7;
    GPIO_1(1) <= serial_out; -- GPIO 5;

    clock <= CLOCK_50;
  
  
    sha256 : sha256_1b port map(clock_19200, reset, serial_in, serial_out, haso_sha256);

    CLOCK_DIVISER_4800 : clock_diviser
    generic map (
      CLOCK_MUL => (50000000/19200)/2 --Alann is loser
    )
    port map(clock, '0', clock_19200);
    
  
    HEX0_DISPLAY : ascii_display port map(haso_sha256(7 downto 0), HEX0);
    HEX1_DISPLAY : ascii_display port map(haso_sha256(15 downto 8), HEX1);

  
    -- HEX1 <= (others=>'1');
    -- HEX2 <= (others=>'1');
    -- HEX3 <= (others=>'1');
    -- HEX4 <= (others=>'1');
    -- HEX5 <= (others=>'1');
  
    LEDR <= (others=>'0');
  
  end architecture;
  
  


  library IEEE;
  use IEEE.numeric_bit.all;
  
  entity clock_diviser is
    generic (
  --     INPUT_CLOCK : integer; 
  --     TARGET_CLOCK : integer
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
