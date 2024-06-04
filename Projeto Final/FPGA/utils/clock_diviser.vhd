library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- This module is for a basic divide by 2 in VHDL.
entity clock_diviser_2 is
  port (
    reset : in std_logic;
    clk_in : in std_logic;
    clk_out : out std_logic
  );
end clock_diviser_2;

architecture div2_arch of clock_diviser_2 is
  signal clk_state : std_logic;

begin
  process (clk_in, reset)
  begin
    if reset = '1' then
      clk_state <= '0';
    elsif clk_in'event and clk_in = '1' then
      clk_state <= not clk_state;
    end if;
  end process;

  clk_out <= clk_state;

end div2_arch;

-------   DIVISOR DE CLOCK 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
  
  entity clock_diviser is
    generic (
      CLOCK_MUL : integer
    );
    port (
      i_clk : in std_logic;
      i_rst : in std_logic;
      o_clk_div : out std_logic
    );
  end clock_diviser;
  
  architecture rtl of clock_diviser is
    signal clk : std_logic;
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