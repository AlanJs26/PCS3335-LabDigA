library IEEE;
use IEEE.numeric_bit.all;

entity serial_in_entity is
    generic (
        POLARITY : boolean := true;
        WIDTH : natural := 8;
        PARITY : natural := 1;
        CLOCK_MUL : positive := 4
    );
    port (
        clock, reset, start, serial_data : in bit;
        done, parity_bit, parity_calculado : out bit;
        parallel_data : out bit_vector(width - 1 downto 0)
    );
end entity;

architecture libarch of serial_in_entity is
    signal transitionflag : bit_vector(5 downto 0);
    -- 00001 rst, 00010 rest->strt, 00100 strt->poll, 01000 poll->poll, 10000 poll->rest
    signal state : bit_vector(1 downto 0);
    -- 00 rest, 01 start, 10 poll

    --signal started:bit := '0'; --set to 1 when strt is run, set to 0 when process ends
    signal last4count : bit := '0';

    signal count1 : bit_vector(15 downto 0);
    signal clk19200, triggerc1, rstcount1 : bit;

    signal datareg : bit_vector(width downto 0);
    --debug
    signal polling : bit;
    --end debug
    signal paralaux : bit_vector(width downto 0);
    signal doneaux : bit;
    signal count2 : bit_vector(1 downto 0);
    component counter4bits is
        generic (
            width : natural := 4
        );
        port (
            clk : in bit;
            rst : in bit;
            count : out bit_vector(width - 1 downto 0)
        );
    end component;

    component parity_def is
        generic (
            POLARITY : BOOLEAN;
            WIDTH : NATURAL;
            PARITY : NATURAL
        );
        port (
            data : in bit_vector(WIDTH - 1 downto 0);
            q : out bit
        );
    end component;
begin
    counter1 : counter4bits
        generic map(width => 16)
        port map(
            clk => clk19200,
            rst => rstcount1,
            count => count1
        );
    counter2 : counter4bits
        generic map(width => 2)
        port map(
            clk => clk19200,
            rst => rstcount1,
            count => count2
        );

    PARITY_DEF_INSTANCE : parity_def 
        generic map(POLARITY => POLARITY, WIDTH => WIDTH, PARITY => PARITY)
        port map(paralaux(width downto 1), parity_calculado);

    clk19200 <= clock;
    transitionflag <= "000001" when reset = '1' else
        "000010" when (state = "00" and start = '1' and serial_data = '0') else
        "000100" when (state = "00" and ((start = '1' and serial_data = '1') or (start = '0'))) else --resting state
        serial_data & "01000" when (state = "10" and count2 = "01") else --when counter is a ((multiple of four) + 1)
        "010000" when (state = "10" and unsigned(count1) >= 4 * (width + 2)) else
        (others => '0');
    stateproc : process (transitionflag, clk19200)
    begin
        if (clk19200'event and clk19200 = '1') then
            case transitionflag(4 downto 0) is
                when "00001" => --reset transition 
                    state <= "00";
                    rstcount1 <= not rstcount1;
                    doneaux <= '0';
                when "00010" => --start transmission 
                    doneaux <= '0';
                    state <= "10";
                when "00100" => --idling 
                    rstcount1 <= not rstcount1;
                when "01000" => --poll data 
                    state <= "10";
                    polling <= transitionflag(5);
                    datareg <= datareg(width - 1 downto 0) & transitionflag(5);
                when "10000" => --stop data polling when counter hits limit 
                    state <= "00";
                    doneaux <= '1';
                when others =>
            end case;
        end if;

    end process;

    done <= doneaux;

    paralaux <= datareg(width downto 0) when (doneaux = '1') else
        paralaux;

    parallel_data <= not paralaux(width downto 1);
    parity_bit <= paralaux(0);

end architecture;