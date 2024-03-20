-------------------------------------------------------------------------------
-- Author: Alan Jose dos Santos (alanjose@usp.br)
-- Author: Lucas Franco
-- Module Name: exp3_somador
-------------------------------------------------------------------------------

entity stepfun is
    port (
        ai, bi, ci, di, ei, fi, gi, hi : in bit_vector(31 downto 0);
        kpw : in bit_vector(31 downto 0);
        ao, bo, co, do, eo, fo, go, ho : out bit_vector(31 downto 0)
    );
end stepfun;
architecture ARCH_STEPFUN of stepfun is

    ------------- COMPONENTS -------------

    component sum0 is
        port (
            x : in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end component;
    component sum1 is
        port (
            x : in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end component;
    component ch is
        port (
            x, y, z : in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end component;
    component maj is
        port (
            x, y, z : in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end component;
    component somador is
        port (
            a, b : in bit_vector(31 downto 0);
            q : out bit_vector(31 downto 0)
        );
    end component;

    ------------- SIGNALS -------------

    signal sum0_result,
    sum1_result,
    ch_result,
    maj_result : bit_vector(31 downto 0);

    signal somador1_result,
    somador2_result,
    somador3_result,
    somador4_result,
    somador5_result,
    somador6_result : bit_vector(31 downto 0);
begin

    CH_MAP : ch port map(ei, fi, gi, ch_result);
    SUM1_MAP : sum1 port map(ei, sum1_result);
    MAJ_MAP : maj port map(ai, bi, ci, maj_result);
    SUM0_MAP : sum0 port map(ai, sum0_result);

    SOMADOR1_MAP : somador port map(hi, kpw, somador1_result);
    SOMADOR2_MAP : somador port map(ch_result, somador1_result, somador2_result);
    SOMADOR3_MAP : somador port map(sum1_result, somador2_result, somador3_result);
    SOMADOR4_MAP : somador port map(maj_result, somador3_result, somador4_result);
    SOMADOR5_MAP : somador port map(sum0_result, somador4_result, somador5_result);
    SOMADOR6_MAP : somador port map(di, somador3_result, somador6_result);
    ao <= somador5_result;
    bo <= ai;
    co <= bi;
    do <= ci;
    eo <= somador6_result;
    fo <= ei;
    go <= fi;
    ho <= gi;

end ARCH_STEPFUN; -- ARCH_STEPFUN

------------- SOMADOR -------------

library ieee;
use ieee.numeric_bit.all;

entity somador is
    port (
        a, b : in bit_vector(31 downto 0);
        q : out bit_vector(31 downto 0)
    );
end somador;
architecture ARCH_SOMADOR of somador is
    signal soma : unsigned(31 downto 0);
begin
    soma <= unsigned(a) + unsigned(b);

    q <= bit_vector(soma);
end ARCH_SOMADOR; -- ARCH_SOMADOR

entity exp3_somador_top is
    port (
        SW   : in  bit_vector(9 downto 0);
        KEY  : in  bit_vector(3 downto 0);
        LEDR : out bit_vector(9 downto 0);
        HEX0 : out bit_vector(6 downto 0);
        HEX1 : out bit_vector(6 downto 0);
        HEX2 : out bit_vector(6 downto 0);
        HEX3 : out bit_vector(6 downto 0);
        HEX4 : out bit_vector(6 downto 0);
        HEX5 : out bit_vector(6 downto 0)
    );
end exp3_somador_top;

architecture arch of exp3_somador_top is
    component hex2seg is
        port (
            hex : in bit_vector(3 downto 0); -- Entrada binaria
            seg : out bit_vector(6 downto 0) -- Saída hexadecimal
            -- A saída corresponde aos segmentos gfedcba nesta ordem. Cobre 
            -- todos valores possíveis de entrada.
        );
    end component;
    component stepfun is
        port (
            ai, bi, ci, di, ei, fi, gi, hi : in bit_vector(31 downto 0);
            kpw : in bit_vector(31 downto 0);
            ao, bo, co, do, eo, fo, go, ho : out bit_vector(31 downto 0)
        );
    end component;

    signal ao_result,
    bo_result,
    co_result,
    do_result,
    eo_result,
    fo_result,
    go_result,
    ho_result : bit_vector(31 downto 0);

    signal x, y, z, result : bit_vector(31 downto 0);
    signal SW_espelhado : bit_vector(7 downto 0);
    signal option1, option2, option3, option4 : bit_vector(31 downto 0);
    signal op : bit_vector(1 downto 0);
begin
    op <= SW(9 downto 8);
    x <= SW(7 downto 0) & SW(7 downto 0) & SW(7 downto 0) & SW(7 downto 0);
    y <= not x;

    GENERATE_INVERSE_Z : for i in 0 to 7 generate
        SW_espelhado(i) <= SW(7 - i);
    end generate GENERATE_INVERSE_Z;
    z <= SW_espelhado(7 downto 0) & SW_espelhado(7 downto 0) & SW_espelhado(7 downto 0) & SW_espelhado(7 downto 0);

    STEPFUN_INSTANCE : stepfun port map(
        x, x, x, x, x, x, x, x,
        x,
        ao_result, bo_result, co_result, do_result, eo_result, fo_result, go_result, ho_result
    );
    
    option1 <= ao_result when KEY(3) = '0' else bo_result;
    option2 <= co_result when KEY(3) = '0' else do_result;
    option3 <= eo_result when KEY(3) = '0' else fo_result;
    option4 <= go_result when KEY(3) = '0' else ho_result;
    result <= option1 when op = "00" else
              option2 when op = "01" else
              option3 when op = "10" else
              option4 when op = "11" else (others => '0');

    HEX0C : hex2seg port map(result(3 downto 0), HEX0);
    HEX1C : hex2seg port map(result(7 downto 4), HEX1);
    HEX2C : hex2seg port map(result(11 downto 8), HEX2);
    HEX3C : hex2seg port map(result(15 downto 12), HEX3);
    HEX4C : hex2seg port map(result(19 downto 16), HEX4);
    HEX5C : hex2seg port map(result(23 downto 20), HEX5);

    LEDR <= "00" & result(31 downto 24);

end architecture;
