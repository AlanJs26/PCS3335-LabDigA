-- CLOCK DIVISER

library IEEE;
use IEEE.numeric_bit.all;

entity clock_diviser is
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
        -- if counter=((INPUT_CLOCK/TARGET_CLOCK)-1)/2 then
            clk <= not clk;
            counter <= 0;
        end if;
    end if;
  end process p_clk_divider;

  o_clk_div <= clk;
end rtl;