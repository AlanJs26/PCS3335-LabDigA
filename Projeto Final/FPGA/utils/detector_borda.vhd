library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity detector_borda is
	generic (
		subida : boolean := true
	);
	port (
		clock	: in  std_logic;
		reset	: in  std_logic;
		borda	: in  std_logic;
		update  : out std_logic
	);
end detector_borda;

architecture rlt of detector_borda is
    type estados is (Waiting_Rise, Work, Waiting_Fall);
    signal EA : estados;
	signal amostragem: std_logic;
begin
	process(reset, clock)
	begin
	  if reset = '1' then
			EA <= Waiting_Rise;
	  elsif rising_edge(clock) then
			if (EA = Waiting_Fall and amostragem = '0') then
				EA <= Waiting_Rise;
			elsif (EA = Waiting_Rise and amostragem = '1') then
				EA <= Work;
			elsif (EA = Work) then
				EA <= Waiting_Fall;
			end if;
	  end if;
	end process;

	amostragem <= borda when subida else not borda;
		
	update <= '1' when EA = Work else '0';
		
end architecture;