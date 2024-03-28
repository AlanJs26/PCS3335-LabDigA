-------------------------------------------------------------------------------
-- Author: Alan Jose dos Santos (alanjose@usp.br)
-- Author: Lucas Franco
-- Module Name: exp4_multisteps
-------------------------------------------------------------------------------
----- MULTISTEPS

library ieee;
use ieee.numeric_bit.all;

entity OLD_multisteps is
    port (
        clk, rst : in bit;
        msgi : in bit_vector(511 downto 0);
        haso : out bit_vector(255 downto 0);
        done : out bit
    );
end OLD_multisteps;

architecture arch of OLD_multisteps is

    component sigma0 is
        port (
            x: in bit_vector(31 downto 0);
            q: out bit_vector(31 downto 0)
        );
    end component;
    
    component sigma1 is
        port (
            x: in bit_vector(31 downto 0);
            q: out bit_vector(31 downto 0)
        );
    end component;

    component stepfun is
        port (
            ai, bi, ci, di, ei, fi, gi, hi : in bit_vector(31 downto 0);
            kpw : in bit_vector(31 downto 0);
            ao, bo, co, do, eo, fo, go, ho : out bit_vector(31 downto 0)
        );
    end component;

    signal sigma0_output, sigma1_output : bit_vector(31 downto 0);
    signal sigma0_input,  sigma1_input  : bit_vector(31 downto 0);

    type state_type is (START, INITIAL_RUNNING, RECURSIVE_RUNNING, DEATH);
    signal state, next_state : state_type;
    signal counter,teste : integer := 0;
    
    type W_array is array (NATURAL range <>) of bit_vector(31 downto 0);
    signal W : W_array(63 downto 0);

    -- signal W_atual  : bit_vector(31 downto 0);
    signal kpw      : bit_vector(31 downto 0);

    type stepfun_array_type is array (NATURAL range <>) of bit_vector(31 downto 0);
    signal stepfun_input : stepfun_array_type(7 downto 0);

    signal stepfun_output : stepfun_array_type(7 downto 0);

    type K_array is array (NATURAL range <>) of bit_vector(31 downto 0);
    constant K : K_array :=
    (
        x"428a2f98", x"71374491", x"b5c0fbcf", x"e9b5dba5",
        x"3956c25b", x"59f111f1", x"923f82a4", x"ab1c5ed5",
        x"d807aa98", x"12835b01", x"243185be", x"550c7dc3",
        x"72be5d74", x"80deb1fe", x"9bdc06a7", x"c19bf174",
        x"e49b69c1", x"efbe4786", x"0fc19dc6", x"240ca1cc",
        x"2de92c6f", x"4a7484aa", x"5cb0a9dc", x"76f988da",
        x"983e5152", x"a831c66d", x"b00327c8", x"bf597fc7",
        x"c6e00bf3", x"d5a79147", x"06ca6351", x"14292967",
        x"27b70a85", x"2e1b2138", x"4d2c6dfc", x"53380d13",
        x"650a7354", x"766a0abb", x"81c2c92e", x"92722c85",
        x"a2bfe8a1", x"a81a664b", x"c24b8b70", x"c76c51a3",
        x"d192e819", x"d6990624", x"f40e3585", x"106aa070",
        x"19a4c116", x"1e376c08", x"2748774c", x"34b0bcb5",
        x"391c0cb3", x"4ed8aa4a", x"5b9cca4f", x"682e6ff3",
        x"748f82ee", x"78a5636f", x"84c87814", x"8cc70208",
        x"90befffa", x"a4506ceb", x"bef9a3f7", x"c67178f2"        
    );
    
    type H_array is array (NATURAL range <>) of bit_vector(31 downto 0);
    constant H : H_array := 
    ( 
        x"6a09e667", x"bb67ae85", x"3c6ef372", x"a54ff53a", x"510e527f", x"9b05688c", x"1f83d9ab", x"5be0cd19"
    );
    
begin

    SIGMA0_INSTANCE : sigma0 port map(sigma0_input, sigma0_output);
    SIGMA1_INSTANCE : sigma1 port map(sigma1_input, sigma1_output);
    
    STEPFUN_INSTANCE : stepfun port map(
        stepfun_input(0),  stepfun_input(1),  stepfun_input(2),  stepfun_input(3),  stepfun_input(4),  stepfun_input(5),  stepfun_input(6),  stepfun_input(7),
        kpw,
        stepfun_output(0), stepfun_output(1), stepfun_output(2), stepfun_output(3), stepfun_output(4), stepfun_output(5), stepfun_output(6), stepfun_output(7)
    );

    process (clk)
    begin
        if rising_edge(clk) then

            case state is
                when START =>
                    if rst = '0' then

                        counter <= counter + 1;
                        teste <= counter;
                        
                        kpw <= bit_vector(unsigned(W(counter)) + unsigned(K(counter)));

                        state <= INITIAL_RUNNING;
                    else
                        state <= START;
                    end if;
                when INITIAL_RUNNING =>
                    if rst = '1' then
                        state <= START;
                    elsif counter >= 16 then                                                
                    
                        kpw <= bit_vector(unsigned(sigma1_output) + unsigned(W(counter-7)) + unsigned(sigma0_output) + unsigned(W(counter-16)) + unsigned(K(counter)));
                        -- kpw <= bit_vector(unsigned(W_atual) + unsigned(K(counter)));
                        
                        state <= RECURSIVE_RUNNING;
                    else
                        counter <= counter + 1;
                        teste <= counter;
                    
                        kpw <= bit_vector(unsigned(W(counter)) + unsigned(K(counter)));
                    
                        state <= INITIAL_RUNNING;
                    end if;
                when RECURSIVE_RUNNING =>
                    if rst = '1' then
                        state <= START;
                    elsif counter >= 63 then
                        kpw <= bit_vector(unsigned(sigma1_output) + unsigned(W((counter-1)-7)) + unsigned(sigma0_output) + unsigned(W((counter-1)-16)) + unsigned(K(counter)));

                        -- stepfun_input(7 downto 0) <= stepfun_output(7 downto 0);

                        state <= DEATH;
                    else
                        kpw <= bit_vector(unsigned(sigma1_output) + unsigned(W((counter-1)-7)) + unsigned(sigma0_output) + unsigned(W((counter-1)-16)) + unsigned(K(counter)));

                        state <= RECURSIVE_RUNNING;
                    end if;
                when DEATH =>
                    if rst = '1' then
                        state <= START;
                    else
                        state <= DEATH;
                    end if;
            end case;

        elsif falling_edge(clk) then

            case state is
                when START =>

                    for i in 0 to 15 loop
                        W(i) <= msgi((i+1)*31+i downto i*31+i);
                    end loop;
                    for i in 16 to 63 loop
                        W(i) <= (others => '0');
                    end loop;

                    counter <= 0;

                    for i in 0 to 7 loop
                        stepfun_input(i) <= H(i);
                    end loop;

                when INITIAL_RUNNING =>

                    sigma0_input <= W(1);
                    sigma1_input <= W(14);
                    
                    stepfun_input(7 downto 0) <= stepfun_output(7 downto 0);

                when RECURSIVE_RUNNING =>
                    counter <= counter + 1;
                    teste <= counter;

                    sigma0_input <= W(counter-15);
                    sigma1_input <= W(counter-2);
                    stepfun_input(7 downto 0) <= stepfun_output(7 downto 0);
                when DEATH =>

                    done <= '1';

            end case;

        end if;

    end process;

    GENERATE_HASO : for i in 0 to 7 generate
        haso((i+1)*31+i downto i*31+i) <= bit_vector(unsigned(stepfun_output(i)) + unsigned(H(i)));
        
    end generate GENERATE_HASO;
end arch; -- arch


-- entity exp4_multisteps_top is
--     port (
--         SW : in bit_vector(9 downto 0);
--         KEY : in bit_vector(3 downto 0);
--         LEDR : out bit_vector(9 downto 0);
--         HEX0 : out bit_vector(6 downto 0);
--         HEX1 : out bit_vector(6 downto 0);
--         HEX2 : out bit_vector(6 downto 0);
--         HEX3 : out bit_vector(6 downto 0);
--         HEX4 : out bit_vector(6 downto 0);
--         HEX5 : out bit_vector(6 downto 0)
--     );
-- end exp4_multisteps_top;

-- architecture arch of exp4_multisteps_top is
--     component hex2seg is
--         port (
--             hex : in bit_vector(3 downto 0); -- Entrada binaria
--             seg : out bit_vector(6 downto 0) -- Saída hexadecimal
--             -- A saída corresponde aos segmentos gfedcba nesta ordem. Cobre 
--             -- todos valores possíveis de entrada.
--         );
--     end component;
--     component stepfun is
--         port (
--             ai, bi, ci, di, ei, fi, gi, hi : in bit_vector(31 downto 0);
--             kpw : in bit_vector(31 downto 0);
--             ao, bo, co, do, eo, fo, go, ho : out bit_vector(31 downto 0)
--         );
--     end component;

--     signal ao_result,
--     bo_result,
--     co_result,
--     do_result,
--     eo_result,
--     fo_result,
--     go_result,
--     ho_result : bit_vector(31 downto 0);

--     signal x, y, z, result : bit_vector(31 downto 0);
--     signal SW_espelhado : bit_vector(7 downto 0);
--     signal option1, option2, option3, option4 : bit_vector(31 downto 0);
--     signal op : bit_vector(1 downto 0);
-- begin
--     op <= SW(9 downto 8);
--     x <= SW(7 downto 0) & SW(7 downto 0) & SW(7 downto 0) & SW(7 downto 0);
--     y <= not x;

--     GENERATE_INVERSE_Z : for i in 0 to 7 generate
--         SW_espelhado(i) <= SW(7 - i);
--     end generate GENERATE_INVERSE_Z;
--     z <= SW_espelhado(7 downto 0) & SW_espelhado(7 downto 0) & SW_espelhado(7 downto 0) & SW_espelhado(7 downto 0);

--     STEPFUN_INSTANCE : stepfun port map(
--         x, x, x, x, x, x, x, x,
--         x,
--         ao_result, bo_result, co_result, do_result, eo_result, fo_result, go_result, ho_result
--     );

--     option1 <= ao_result when KEY(3) = '0' else
--         bo_result;
--     option2 <= co_result when KEY(3) = '0' else
--         do_result;
--     option3 <= eo_result when KEY(3) = '0' else
--         fo_result;
--     option4 <= go_result when KEY(3) = '0' else
--         ho_result;
--     result <= option1 when op = "00" else
--         option2 when op = "01" else
--         option3 when op = "10" else
--         option4 when op = "11" else
--         (others => '0');

--     HEX0C : hex2seg port map(result(3 downto 0), HEX0);
--     HEX1C : hex2seg port map(result(7 downto 4), HEX1);
--     HEX2C : hex2seg port map(result(11 downto 8), HEX2);
--     HEX3C : hex2seg port map(result(15 downto 12), HEX3);
--     HEX4C : hex2seg port map(result(19 downto 16), HEX4);
--     HEX5C : hex2seg port map(result(23 downto 20), HEX5);

--     LEDR <= "00" & result(31 downto 24);

-- end architecture;
