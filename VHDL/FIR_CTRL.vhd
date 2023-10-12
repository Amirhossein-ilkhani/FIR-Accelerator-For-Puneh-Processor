LIBRARY ieee;
USE IEEE.std_logic_1164.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY controller_fir IS PORT (

    clk : IN STD_LOGIC;
    r : IN STD_LOGIC;
    rst : OUT STD_LOGIC;
    start: IN STD_LOGIC;
    eq_inner, eq_outer : IN STD_LOGIC;
    en_inner, en_outer : OUT STD_LOGIC;
    ld_fir, ld_degree, ld_inner : OUT STD_LOGIC;
    wr_outp: OUT STD_LOGIC;
    init_fir: OUT STD_LOGIC;
    FirCompelete : OUT STD_LOGIC
);
END ENTITY controller_fir;

ARCHITECTURE controller_fir_arc OF controller_fir IS
TYPE state IS(s_wait, init, get_degree, fir_calc1, fir_calc2, done_write, final);
SIGNAL pstate ,nstate: state;

BEGIN
PROCESS(clk,r)
BEGIN
    IF r='1' THEN 
        pstate<=s_wait;
    ELSIF clk='1' AND clk'EVENT THEN
        pstate<= nstate; 
    END IF;
END PROCESS;

PROCESS(pstate, start, eq_inner, eq_outer)
BEGIN
en_inner<='0'; en_outer<='0';
ld_fir<='0'; ld_degree<='0'; ld_inner<='0';
wr_outp<='0';
init_fir<='0';
rst<='0';
FirCompelete <= '0';

CASE pstate IS
    WHEN s_wait =>
        IF start='1' THEN 
            nstate<=init;
        ELSE
             nstate<=s_wait;
        END IF;
        
    WHEN init =>
        nstate<=get_degree;
        rst<='1';

    WHEN get_degree =>
        nstate<= fir_calc1;
        ld_degree<='1';
        en_inner<='1';

    WHEN fir_calc1 =>
    IF eq_inner='1' THEN 
            nstate<=fir_calc2;
        ELSE
             nstate<=fir_calc1;
    END IF;
        ld_fir<='1';
        en_inner<='1';

    WHEN fir_calc2 =>
        nstate<=done_write;
        ld_inner<='1';
        en_outer<='1';
        wr_outp<='1';
    
    WHEN done_write =>
        IF eq_outer='1' THEN 
                nstate<=final;
            ELSE
                nstate<=fir_calc1;
        END IF;
            init_fir<='1';
    WHEN final =>
        nstate<=s_wait;
        FirCompelete <= '1';
    END CASE;
END PROCESS;
END controller_fir_arc;