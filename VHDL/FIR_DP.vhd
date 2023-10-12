LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;

ENTITY DP_FIR IS
    PORT (
        clk,r,rst : IN std_logic;
        addbus, databus : IN std_logic_vector(15 DOWNTO 0);
        outw, ldDeg, en_g, en_s, clr, firld, firrst : IN std_logic;
        DataToFir : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        NUMToFir : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        AddFromDMA : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        writeNUM, writetoFIR : IN STD_LOGIC;
        eq_s, eq_g, start : OUT std_logic;
        WriteToDMA : OUT std_logic;
        DataToDMA : OUT std_logic_vector(15 DOWNTO 0);
        AddToDMA : OUT std_logic_vector(6 DOWNTO 0)
    );
END ENTITY DP_FIR;

ARCHITECTURE rtl OF DP_FIR IS
    SIGNAL cnt_s : std_logic_vector(3 DOWNTO 0); -- output of small counter
    SIGNAL Deg_reg_out : std_logic_vector(15 DOWNTO 0); -- output of Degree_reg
    SIGNAL RAM_coeff_out : std_logic_vector(15 DOWNTO 0); -- output of RAM_coeff
    SIGNAL Num_reg_out : std_logic_vector(15 DOWNTO 0); -- output of Num_REG

    SIGNAL cnt_g : std_logic_vector(6 DOWNTO 0); -- output of great counter
    signal x : std_logic_vector(15 DOWNTO 0); -- SUB
    signal y : std_logic_vector(15 DOWNTO 0); -- ADDER
    SIGNAL RAM_IN_out : std_logic_vector(15 DOWNTO 0); -- output of RAM_IN
    SIGNAL reset_FIR : std_logic; -- reset for FIR
    SIGNAL FIR_out : std_logic_vector(15 DOWNTO 0); -- output of fir
    SIGNAL RAM_OUT_out : std_logic_vector(15 DOWNTO 0); -- output of RAM_OUT
    SIGNAL reset : std_logic;
    SIGNAL cofw : std_logic;
    SIGNAL MUX_coeff : std_logic_vector(3 DOWNTO 0);-- MUX for COEFF RAM address PORT
    SIGNAL MUX_IN : std_logic_vector(6 DOWNTO 0);-- MUX for IN RAM address PORT

BEGIN
    reset <= rst OR r;

    small_counter : ENTITY work.COUNTETR(rtl) PORT MAP(clk => clk ,rst => reset ,en => en_s ,ld => clr, d_in => "0001", cnt => cnt_s);

    Degree_reg : ENTITY work.reg16(rtl) PORT MAP(clk => clk ,rst => reset ,ld => ldDeg ,q_in => RAM_coeff_out ,q_out => Deg_reg_out);

    RAM_coeff : ENTITY work.RAM_cof(rtl) PORT MAP(clk => clk ,addr => MUX_coeff ,wr => cofw ,din => databus ,dout => RAM_coeff_out);

    MUX_coeff <= addbus(3 DOWNTO 0) WHEN cofw = '1' ELSE cnt_s; 

    eq_s <= '1' WHEN Deg_reg_out(3 downto 0) = cnt_s ELSE '0';

    --------------------------------------------------------------------------------------------

    Num_REG : ENTITY work.reg16(rtl) PORT MAP(clk => clk ,rst => r ,ld => writeNUM ,q_in => NUMToFir ,q_out => Num_reg_out);

    great_counter : ENTITY work.COUNTETR(rtl) GENERIC MAP (size => 7) PORT MAP(clk => clk ,rst => reset ,en => en_g ,ld => '0',d_in => "0000000", cnt => cnt_g);

    -- x <= (Deg_reg_out - '1') - Num_reg_out;
    eq_g <= '1' WHEN (Num_reg_out(6 DOWNTO 0) = cnt_g) ELSE '0';

    ----------------------------------------------------------------------------------------------
    y <= cnt_g + (x"000" & cnt_s) - 1;
    MUX_IN <= AddFromDMA WHEN writetoFIR ='1' ELSE y(6 DOWNTO 0);

    RAM_IN : ENTITY work.RAM_IN(rtl) PORT MAP(clk => clk ,addr => MUX_IN ,wr => writetoFIR ,din => DataToFir, dout => RAM_IN_out);

    FIR : ENTITY work.fir1(rtl) PORT MAP(clk => clk, rst => reset_FIR, en => firld, x => RAM_IN_out, cof => RAM_coeff_out, y => FIR_out);
    
    reset_FIR <= '1' WHEN (reset='1' OR firrst='1') ELSE '0';

    RAM_OUT : ENTITY work.RAM_OUT(rtl) PORT MAP(clk => clk ,addr => cnt_g(6 DOWNTO 0) ,wr => outw, din => FIR_out, dout => RAM_OUT_out);

    -----------------------------------------------------------------------------------------------


    start <= '1' WHEN addbus = x"0C06" ELSE '0';

    cofw <= '1' WHEN ((addbus <= x"0B0F") AND  (addbus >= x"0B00")) ELSE '0';


    AddToDMA <= cnt_g(6 DOWNTO 0);
    WriteToDMA <= outw;
    DataToDMA <= FIR_out;

END ARCHITECTURE;
