library ieee;
use ieee.numeric_bit.all;

entity serial_out is
    generic (
        POLARITY : BOOLEAN := TRUE;
        WIDTH : NATURAL := 7;
        PARITY : NATURAL := 1;
        STOP_BITS : NATURAL := 1
    );
    port (
        clock, reset, tx_go : in BIT;
        data : in bit_vector(WIDTH - 1 downto 0);
        tx_done : out BIT;
        serial_o : out BIT
    );
end serial_out;

architecture serial_out_arch of serial_out is

    signal counter : INTEGER := - 1;

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
 
    signal parity_q : bit;
    
    signal high_low : bit;

begin
    PARITY_DEF_INSTANCE : parity_def 
        generic map(POLARITY => POLARITY, WIDTH => WIDTH, PARITY => PARITY)
        port map(data, parity_q);

    high_low <= '1' when POLARITY=true else '0';
    
    identifier : process (clock, reset)
    begin

        if reset = '1' or falling_edge(reset) then
            serial_o <= high_low;
            tx_done <= '0';
        elsif rising_edge(clock) and (tx_go='1' or counter>=0) then
            counter <= counter + 1;

            if counter < 0 then -- START
                serial_o <= high_low;
                tx_done <= '0';
            elsif counter >= 0 and counter <= WIDTH - 1 then -- DADOS
                if POLARITY=TRUE then
                    serial_o <= data(counter);
                    else
                    serial_o <= not data(counter);            
                end if;
            elsif counter <= (WIDTH - 1) + 1 then -- PARIDADE
                serial_o <= parity_q;
            elsif counter <= (WIDTH - 1) + 2 + STOP_BITS then -- STOP
                serial_o <= high_low;
            else
                serial_o <= high_low; -- REPOUSO
                tx_done <= '1';
            end if;

        end if;

    end process;
end serial_out_arch; -- serial_out_arch


----------------------------------------PARIDADE----------------------------------------

entity parity_def is
    generic (
        POLARITY : BOOLEAN := TRUE;
        WIDTH : NATURAL := 7;
        PARITY : NATURAL := 1
    );
    port (
        data : in bit_vector(WIDTH - 1 downto 0);
        q : out bit
    );
end entity;

architecture parity_def_arch of parity_def is
    signal paridade : bit_vector(WIDTH-2 downto 0);
    signal saida : bit;
begin
    
    paridade(0) <= data(0) xor data(1);
    PARIDADE_GENERATE : for i in 1 to WIDTH-2 generate
        paridade(i) <= paridade(i-1) xor data(i+1);
    end generate;

    saida <= paridade(WIDTH-2) when PARITY=1 else not paridade(WIDTH-2);

    q <= saida when POLARITY=TRUE else not saida;
end parity_def_arch ; -- parity_def_arch