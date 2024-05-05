-- This module is for a basic divide by 2 in VHDL.
entity clock_diviser_2 is
  port (
    reset : in bit;
    clk_in : in bit;
    clk_out : out bit
  );
end clock_diviser_2;

architecture div2_arch of clock_diviser_2 is
  signal clk_state : bit;

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