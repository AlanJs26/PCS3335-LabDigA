entity shift_register is
    generic (
        WIDTH_IN : natural;
        WIDTH : natural
    );
    port (
        clk, reset, enable : in bit;
        data_in : in bit_vector(WIDTH_IN - 1 downto 0);
        data_out : out bit_vector(WIDTH - 1 downto 0)
    );
end entity;
architecture arch of shift_register is
    signal data : bit_vector(WIDTH - 1 downto 0);
    signal previous_enable : bit;
begin


    process (clk,reset)
    begin
        if reset = '1' then
            data <= (others=>'0');
            previous_enable <= '0';
        elsif rising_edge(clk) then
            if enable = '1'  then
                if previous_enable='0' then
                    previous_enable <= '1';
                    data <= data(WIDTH - 1 - WIDTH_IN downto 0) & data_in;
                end if;
            else
                previous_enable <= '0';
            end if;
        else
        end if;
    end process;

    data_out <= data;

end arch ; -- arch
