library ieee;
use ieee.numeric_bit.all;

entity serial_in is
  generic (
    POLARITY : boolean := TRUE;
    WIDTH : natural := 8;
    PARITY : natural := 1;
    CLOCK_MUL : positive := 4
  );
  port (
    clock, reset, start, serial_data : in bit;
    done, parity_bit : out bit;
    parallel_data : out bit_vector(WIDTH - 1 downto 0)
  );
end serial_in;
architecture arch of serial_in is

  component clock_diviser is
    generic (
      INPUT_CLOCK : integer; 
      TARGET_CLOCK : integer
    );
    port (
      i_clk : in bit;
      i_rst : in bit;
      o_clk_div : out bit
    );
  end component;

  component bit_reverser is
    generic (
      WIDTH : positive
    );
    port (
      i_data : in bit_vector(WIDTH-1 downto 0);
      o_data : out bit_vector(WIDTH-1 downto 0)
    );
  end component;

  type state_t is (wait_start, reset_clock, receive_data, rest);
  signal next_state, current_state : state_t;

  signal clock_div, clock_div_rst : bit;
  signal data : bit_vector(WIDTH downto 0);
  signal data_counter : integer := 0;

  signal reverse_data : bit_vector(WIDTH-1 downto 0);

  signal serial_data_p : bit;

begin

  serial_data_p <= serial_data when POLARITY=true else not serial_data;

  CLOCK_DIVISER_INSTANCE : clock_diviser 
  generic map(
      -- INPUT_CLOCK => 50000000,
      INPUT_CLOCK => 4800*4,
      TARGET_CLOCK => 4800
      -- TARGET_CLOCK => 50000000/4
      -- TARGET_CLOCK => 4800*CLOCK_MUL
  )
  port map(
      clock, clock_div_rst, clock_div
  );

  BIT_REVERSER_INSTANCE : bit_reverser 
  generic map(
      WIDTH => WIDTH
  )
  port map(
      data(WIDTH downto 1), reverse_data
  );

  STATES_PROCESS : process (clock, reset, start)
  begin

    if reset = '1' then
      current_state <= wait_start;
    elsif (rising_edge(clock)) then
      current_state <= next_state;
    end if;
    
  end process;

  -- Logica de proximo estado
  next_state <=
    wait_start when current_state=rest and start='1' else
    reset_clock when current_state=wait_start and serial_data_p='0' and start='1' else
    receive_data when current_state=reset_clock else
    rest when (current_state=receive_data and data_counter>=WIDTH+2) else
    next_state;

  clock_div_rst <= '1' when current_state=reset_clock else '0';

  parity_bit <= data(0) when PARITY=1 else not data(0);

  parallel_data <= reverse_data;

  
  done <= '1' when current_state=rest or data_counter>=WIDTH+2 else '0';

  MAIN_PROCESS : process (clock_div, clock_div_rst, reset)
  begin
    if reset = '1' then
      data_counter <= 0;
    end if;

    if rising_edge(clock_div_rst) then
      data_counter <= 0;
      data <= (others=>'0');
    elsif rising_edge(clock_div) then
            
      if current_state=receive_data then
        data_counter <= data_counter + 1;

        for i in WIDTH downto 1 loop
          data(i) <= data(i-1);
        end loop;
        data(0) <= serial_data_p;

      end if;


    end if;
  end process;
end architecture;


-- CLOCK DIVISER

library IEEE;
use IEEE.numeric_bit.all;

entity clock_diviser is
  generic (
    INPUT_CLOCK : integer; 
    TARGET_CLOCK : integer
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

        if counter=((INPUT_CLOCK/TARGET_CLOCK)-1)/2 then
            clk <= not clk;
            counter <= 0;
        end if;
    end if;
  end process p_clk_divider;

  o_clk_div <= clk;
end rtl;


entity bit_reverser is
  generic (
    WIDTH : positive
  );
  port (
    i_data : in bit_vector(WIDTH-1 downto 0);
    o_data : out bit_vector(WIDTH-1 downto 0)
  );
end entity bit_reverser;

architecture arch of bit_reverser is
begin
  process(i_data)
  begin
    for i in 0 to WIDTH-1 loop
      o_data(i) <= i_data(WIDTH-1-i);
    end loop;
  end process;
end architecture;