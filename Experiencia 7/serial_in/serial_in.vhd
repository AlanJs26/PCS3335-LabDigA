library ieee;
use ieee.numeric_bit.all;

entity serial_in_entity is
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
end serial_in_entity;
architecture arch of serial_in_entity is

  component clock_diviser_2 is
    port (
        reset : in bit;
        clk_in : in bit;
        clk_out : out bit
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

  signal clock_div, clock_div_2, clock_div_rst : bit;
  signal data : bit_vector(WIDTH downto 0);
  signal data_counter : integer := 0;

  signal reverse_data : bit_vector(WIDTH-1 downto 0);

  signal serial_data_p : bit;

begin

  serial_data_p <= serial_data when POLARITY=true else not serial_data;

  CLOCK_DIVISER_2_INSTANCE : clock_diviser_2
  port map(
      clock_div_rst, clock, clock_div_2
  );
  CLOCK_DIVISER_4_INSTANCE : clock_diviser_2
  port map(
      clock_div_rst, clock_div_2, clock_div
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