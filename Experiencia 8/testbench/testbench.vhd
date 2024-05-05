library ieee;
use ieee.numeric_bit.all;

entity tb is end;

-- architecture arch of tb is

--     ---------------------------------------- MARK: COMPONENTS --------------------------------------------------  
--     component sha256 is
--         port (
--             clock, reset : in bit; -- Clock da placa, GPIO_0_D2  
--             serial_in : in bit; -- GPIO_0_D0
--             serial_out : out bit -- GPIO_0_D1
--         );
--     end component;

--     signal reset, serial_in, serial_out : bit;

--     component parity_def is
--         generic (
--             POLARITY : BOOLEAN;
--             WIDTH : NATURAL;
--             PARITY : NATURAL
--         );
--         port (
--             data : in bit_vector(WIDTH - 1 downto 0);
--             q : out bit
--         );
--     end component;

--     signal parity_data_in : bit_vector(511 downto 0);
--     signal parity_q : bit;

--     ---------------------------------------- MARK: CLOCK SIGNALS --------------------------------------------------  

--     constant PERIOD50M : time := 20 ns;
--     constant PERIOD12_5M : time := 80 ns;

--     signal clock50M, clock12_5M : bit;
--     signal finished : bit := '0';


--     ---------------------------------------- MARK: TEST ARRAY --------------------------------------------------  

--     type test_record is record
--         data_in : bit_vector(511 downto 0);
--         haso_out : bit_vector(255 downto 0);
--         id : string(1 to 3);
--     end record;

--     type tests_array is array (NATURAL range <>) of test_record;

--     constant tests : tests_array :=
--     (
--         (x"000000f8000000000000000000000000000000000000000000000000000000006c204180676974616f204469746f7269626f72612d204c613333352050435333", x"bd02d673ff4e4868c1f015c8ffeb420330b75ee36dbc77d05c6e9b20de7168fd", "ARg"), --00
--         (x"000000f8000000000000000000000000000000000000000000000000000000006c204180676974616f204469746f7269626f72612d204c613333352050435333", x"bd02d673ff4e4868c1f015c8ffeb420330b75ee36dbc77d05c6e9b20de7168fd", "ARg") --01
--     );

--     signal current_test : integer := 0;

-- begin

--     ---------------------------------------- MARK: SIGNAL/COMPONENT MAPPING --------------------------------------------------  

--     clock50M <= not clock50M and not finished after PERIOD50M/2;
--     clock12_5M <= not clock12_5M and not finished after PERIOD12_5M/2;

--     SHA256_INSTANCE : sha256 port map(clock50M, reset, serial_in, serial_out);

--     PARITY_DEF_INSTANCE : parity_def 
--         generic map(
--            POLARITY => TRUE,
--            WIDTH => 512,
--            PARITY => 1
--         )
--         port map(parity_data_in, parity_q);


--     ---------------------------------------- MARK: TESTBENCH_PROCESS --------------------------------------------------  

--     TESTBENCH_PROCESS : process
--     begin


--         -- for k in tests' range loop
--         for k in 0 to 0 loop
--             current_test <= k;

--             reset <= '1';
--             serial_in <= '1';
--             parity_data_in <= tests(k).data_in;

--             wait until rising_edge(clock12_5M);
--             wait until rising_edge(clock12_5M);
--             wait until rising_edge(clock12_5M);
--             wait until rising_edge(clock12_5M);
--             reset <= '0';

--             -- SEND START BIT
--             wait until rising_edge(clock12_5M);
--             serial_in <= '0';

--             -- SEND DATA
--             for i in 0 to 511 loop
--                 wait until rising_edge(clock12_5M);
--                 serial_in <= not tests(k).data_in(i); -- ith bit
--             end loop;


--             -- SEND PARITY BIT
--             wait until rising_edge(clock12_5M);
--             serial_in <= parity_q;


--             -- SEND STOP BITS
--             for i in 1 to 2 loop
--                 wait until rising_edge(clock12_5M);
--                 serial_in <= '1';
--             end loop;


--             parity_data_in <= tests(k).data_in;
--             -- wait transmission
--             wait until falling_edge(serial_out);
--             wait for PERIOD12_5M/2;

--             -- RECEIVE START BIT
--             assert (serial_out = '0') report "Fail (receive) (start_bit): " & tests(k).id & "{" & integer'image(k) & "}" severity error;

--             -- RECEIVE DATA
--             for i in 0 to 255 loop
--                 wait for PERIOD12_5M;
--                 assert (serial_out = not tests(k).haso_out(i)) report "Fail (receive) (D" & integer'image(i) & "): " & tests(k).id & "{" & integer'image(k) & "}" severity error;
--             end loop;

--             -- RECEIVE PARITY BIT
--             assert (serial_out = parity_q) report "Fail (receive) (parity_bit): " & tests(k).id & "{" & integer'image(k) & "}" severity error;

--             -- RECEIVE SERIAL_OUT END
--             assert (serial_out = '1') report "Fail (receive) (end bit): " & tests(k).id & "{" & integer'image(k) & "}" severity error;

--         end loop;

--         wait until rising_edge(clock12_5M);
--         wait until rising_edge(clock12_5M);
--         wait until rising_edge(clock12_5M);
--         wait until rising_edge(clock12_5M);

--         finished <= '1';
--         wait;
--     end process;
-- end arch; -- arch

---------------------------------------- MARK: Arquitetura MONITOR ---------------------------------------- 

architecture arch_monitor of tb is

    component sha256 is
        port (clock, reset : in  bit;		-- Clock da placa, GPIO_0_D2  
                serial_in    : in  bit;		-- GPIO_0_D0
                serial_out	 : out bit		-- GPIO_0_D1
        );
    end component;

    function paridade(vetor : bit_vector) return bit is
        variable parity : bit := '1';
    begin
        for i in vetor'range loop
            parity := parity xor vetor(i);
        end loop;
        return parity;
    end function paridade;

    constant PERIOD19200 : time := 52083   ns;
    constant PERIOD4800  : time := 52083*4 ns;

    type mem_t is array(natural range <>) of bit_vector(7 downto 0);
    constant data_in  : mem_t(63 downto 0) := (x"00", x"00", x"00", x"f8", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"6c", x"20", x"41", x"80", x"67", x"69", x"74", x"61", x"6f", x"20", x"44", x"69", x"74", x"6f", x"72", x"69", x"62", x"6f", x"72", x"61", x"2d", x"20", x"4c", x"61", x"33", x"33", x"35", x"20", x"50", x"43", x"53", x"33");
    constant data_out : mem_t(31 downto 0) := (x"bd", x"02", x"d6", x"73", x"ff", x"4e", x"48", x"68", x"c1", x"f0", x"15", x"c8", x"ff", x"eb", x"42", x"03", x"30", x"b7", x"5e", x"e3", x"6d", x"bc", x"77", x"d0", x"5c", x"6e", x"9b", x"20", x"de", x"71", x"68", x"fd");
    signal reset, serial_in, serial_out : bit;
    signal clock19200, clock4800 : bit;
    signal finished : bit := '0';
begin

    clock19200 <= not clock19200 and not finished after PERIOD19200/2;
    clock4800  <= not clock4800  and not finished after PERIOD4800/2;

    sha256_impl: sha256
    port map(clock19200, reset, serial_in, serial_out);


    Estimulo : process
    begin
        reset <= '1';
        serial_in <= '1';
        wait until rising_edge(clock4800);
        wait until rising_edge(clock4800);
        wait until rising_edge(clock4800);
        wait until rising_edge(clock4800);
        reset <= '0';

        for j in 63 downto 0 loop
            serial_in <= '0';
            wait until rising_edge(clock4800);
            for i in 0 to 7 loop
                serial_in <= data_in(j)(i);
                wait until rising_edge(clock4800);
            end loop;
            serial_in <= paridade(data_in(j));
            wait until rising_edge(clock4800);
            serial_in <= '1';
            wait until rising_edge(clock4800);
        end loop;

        -- wait until falling_edge(serial_out);
        wait until falling_edge(serial_out) for PERIOD19200*100;
        wait for PERIOD4800/2; --Middle of the bit

        for j in 31 downto 0 loop
            --report "Inicio palavra de indice " & integer'image(j);
            assert serial_out = '0' report "StartBit nao detectado" & "Indices (j): (" & integer'image(j) & ")";
            wait for PERIOD4800;
            for i in 0 to 7 loop
                assert serial_out = data_out(j)(i) report "Recebido: " & bit'image(serial_out) & " Esperado: " & bit'image(data_out(j)(i)) & "Indices (j, i): (" & integer'image(j) & ", " & integer'image(i) & ")";
                wait for PERIOD4800;
            end loop;
            assert serial_out = paridade(data_out(j)) report "Paridade";
            wait for PERIOD4800;
            assert serial_out = '1' report "STOP Bits";
            --report "Fim palavra de indice " & integer'image(j);
            wait until serial_out = '0' for 10*PERIOD4800;
            wait for PERIOD4800/2;
        end loop;



            

        reset <= '1';
        serial_in <= '1';
        wait until rising_edge(clock4800);
        reset <= '0';
        wait until rising_edge(clock4800);
        wait until rising_edge(clock4800);
        wait until rising_edge(clock4800);
        wait until rising_edge(clock4800);
        wait until rising_edge(clock4800);
        wait until rising_edge(clock4800);
        wait until rising_edge(clock4800);

        for j in 63 downto 0 loop
            serial_in <= '0';
            wait until rising_edge(clock4800);
            for i in 0 to 7 loop
                serial_in <= data_in(j)(i);
                wait until rising_edge(clock4800);
            end loop;
            serial_in <= paridade(data_in(j));
            wait until rising_edge(clock4800);
            serial_in <= '1';
            wait until rising_edge(clock4800);
        end loop;

        -- wait until falling_edge(serial_out);
        wait until falling_edge(serial_out) for PERIOD19200*100;
        wait for PERIOD4800/2; --Middle of the bit

        for j in 31 downto 0 loop
            --report "Inicio palavra de indice " & integer'image(j);
            assert serial_out = '0' report "StartBit nao detectado" & "Indices (j): (" & integer'image(j) & ")";
            wait for PERIOD4800;
            for i in 0 to 7 loop
                assert serial_out = data_out(j)(i) report "Recebido: " & bit'image(serial_out) & " Esperado: " & bit'image(data_out(j)(i)) & "Indices (j, i): (" & integer'image(j) & ", " & integer'image(i) & ")";
                wait for PERIOD4800;
            end loop;
            assert serial_out = paridade(data_out(j)) report "Paridade";
            wait for PERIOD4800;
            assert serial_out = '1' report "STOP Bits";
            --report "Fim palavra de indice " & integer'image(j);
            wait until serial_out = '0' for 10*PERIOD4800;
            wait for PERIOD4800/2;
        end loop;

        report "this is a message"; -- severity note
        finished <= '1';
        wait;
    end process;
end arch_monitor; -- arch_monitor