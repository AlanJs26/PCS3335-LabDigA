
entity exp4_multisteps_top is
    port (
        SW : in bit_vector(9 downto 0);
		CLOCK_50,GPI0_0_D0, GPI0_0_D1 : in bit;
        KEY : in bit_vector(3 downto 0);
        LEDR : out bit_vector(9 downto 0);
        HEX0 : out bit_vector(6 downto 0);
        HEX1 : out bit_vector(6 downto 0);
        HEX2 : out bit_vector(6 downto 0);
        HEX3 : out bit_vector(6 downto 0);
        HEX4 : out bit_vector(6 downto 0);
        HEX5 : out bit_vector(6 downto 0)
    );
end exp4_multisteps_top;

architecture arch of exp4_multisteps_top is
    component hex2seg is
        port (
            hex : in bit_vector(3 downto 0); -- Entrada binaria
            seg : out bit_vector(6 downto 0) -- Saída hexadecimal
            -- A saída corresponde aos segmentos gfedcba nesta ordem. Cobre 
            -- todos valores possíveis de entrada.
        );
    end component;
    
    component display is
        port (
          input: in   bit_vector(7 downto 0); -- ASCII 8 bits
          output: out bit_vector(7 downto 0)  -- ponto + abcdefg
        );
      end component;

    component serial_out is
        generic (
            POLARITY : BOOLEAN := TRUE;
            WIDTH : NATURAL := 8;
            PARITY : NATURAL := 1;
            STOP_BITS : NATURAL
        );
        port (
            clock, reset, tx_go : in BIT;
            data : in bit_vector(WIDTH - 1 downto 0);
            tx_done : out BIT;
            serial_o : out BIT
        );
    end component;

    constant POLARITY : BOOLEAN := TRUE;
    constant WIDTH : NATURAL := 8;
    constant PARITY : NATURAL := 1;
    constant STOP_BITS : NATURAL := 2;
    signal clock, reset, tx_go : bit;
    signal data : bit_vector(WIDTH - 1 downto 0);
    signal tx_done, serial_o : bit;

begin   
    data(WIDTH - 1 downto 0) <= SW(WIDTH - 1 downto 0);

    reset <= GPI0_0_D0; --SEI LA COMO É ESSE GPIO;
    tx_go <= GPI0_0_D1; --SE N SABAI COMO FAZER O DO RESET, IMAGINA DESSE;
	clock <= CLOCK_50;
        
    SERIAL_OUT_INSTANCE : serial_out 
    generic map(
        POLARITY => POLARITY,
        WIDTH => WIDTH,
        PARITY => PARITY,
        STOP_BITS => STOP_BITS
    )
    port map(
        clock, reset, tx_go,
        data,
        tx_done,
        serial_o
    );

    -- rst <= '1' when KEY(3) = '0' else '0';
     
    if KEY(3) = '0' generate
        HEX0C : display port map(data(WIDTH - 1 downto 0), HEX0);
    end generate;

    if KEY(3) = '1' generate
        HEX0C : hex2seg port map(data(3 downto 0), HEX0);
        HEX1C : hex2seg port map(data(7 downto 4), HEX1);
    end generate;

    LEDR(9) <= tx_done;
    LEDR(7 downto 0) <= data(7 downto 0);

end architecture;
