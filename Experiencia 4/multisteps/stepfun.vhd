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