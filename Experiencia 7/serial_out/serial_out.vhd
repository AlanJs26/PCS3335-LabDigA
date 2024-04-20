library ieee;
use ieee.numeric_bit.all;

entity serial_out is
    generic (
        POLARITY : BOOLEAN := TRUE;
        WIDTH : NATURAL := 7;
        PARITY : NATURAL := 1;
        STOP_BITS : NATURAL
    );
    port (
        clock, reset, tx_go : in BIT;
        data : in bit_vector(WIDTH - 1 downto 0);
        tx_done : out BIT;
        serial_o : out BIT
    );
end serial_out;

architecture serial_out_arch of serial_out is

    signal counter : INTEGER := -1;

    component parity_def is
        generic (
            POLARITY : BOOLEAN := TRUE;
            WIDTH : NATURAL := 7;
            PARITY : NATURAL := 1
        );
        port (
            data : in bit_vector(WIDTH - 1 downto 0);
            q : out bit
        );
    end component;

    signal data_reg : bit_vector(WIDTH - 1 downto 0);
 
    signal parity_q : bit;
    signal high_low : bit;
    signal tx_done_s : bit;
    signal ended : bit := '1';

begin
    PARITY_DEF_INSTANCE : parity_def 
        generic map(POLARITY => POLARITY, WIDTH => WIDTH, PARITY => PARITY)
        port map(data, parity_q);

    high_low <= '1' when POLARITY=true else '0';

    tx_done <= tx_done_s;
    
    identifier : process (clock, reset)
    begin

        if reset = '1' then
            serial_o <= high_low;
            tx_done_s <= '0';
            counter <= -1;
            data_reg <= data;
            ended <= '0';

        elsif rising_edge(clock) and tx_go='0' and counter<0 then        
            serial_o <= high_low; -- REPOUSO
            counter <= -1;
            data_reg <= data;
            tx_done_s <= ended;
        elsif rising_edge(clock) and (tx_go='1' or counter>=0) then
            tx_done_s <= '0';
            ended <= '0';

            counter <= counter + 1;

            if counter < 0 then -- START
                serial_o <= not high_low;
                tx_done_s <= '0';
                data_reg <= data;

            elsif counter >= 0 and counter <= WIDTH - 1 then -- DADOS
                if POLARITY=TRUE then
                    serial_o <= data_reg(counter);
                else
                    serial_o <= not data_reg(counter);            
                end if;
            elsif counter <= WIDTH then -- PARIDADE
                serial_o <= parity_q;
            elsif counter <= WIDTH + STOP_BITS then -- STOP

                serial_o <= high_low;
                data_reg <= data;
            else
                tx_done_s <= '1';
                counter <= -1;
                ended <= '1';
            end if;
        
        end if;

    end process;
end serial_out_arch; -- serial_out_arch



