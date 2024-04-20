-- BIT REVERSER

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