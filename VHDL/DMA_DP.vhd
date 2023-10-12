LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY DMA_DP IS
    PORT (
        clk,rst : IN std_logic;
        addrbus, databus : INOUT std_logic_vector(15 DOWNTO 0);
        datatoDMA : IN std_logic_vector(15 downto 0);
        addrtoDMA : IN std_logic_vector(6 downto 0);
        writetoDMA : IN std_logic;
        numOfData : OUT std_logic_vector(15 downto 0);
        cnt_gout : OUT std_logic_vector(6 downto 0);   
        -------FROM/TO controller
        en, clr_s, clr_g, INw, seladdbus, seldatabus: IN std_logic;
        eq_s, eq_g, active_read, active_write, go_flag : OUT std_logic
    );

END ENTITY DMA_DP;

ARCHITECTURE rtl OF DMA_DP IS

    SIGNAL cnt_g : std_logic_vector(6 downto 0);
    SIGNAL cnt_s : std_logic_vector(2 downto 0);
    SIGNAL ld_flag, ld_add, ld_num, ld_reserved : std_logic;
    SIGNAL RAM_IN_out, RAM_OUT_out : std_logic_vector(15 DOWNTO 0);
    SIGNAL add_ram_out : std_logic_vector(6 downto 0);
    SIGNAL dataout, addout : std_logic_vector(15 DOWNTO 0);
    SIGNAL num_reg, flag_reg, add_reg, reserved_reg : std_logic_vector(15 DOWNTO 0);

BEGIN

small_counter : ENTITY work.COUNTETR(rtl) GENERIC MAP (size => 3) PORT MAP(clk => clk ,rst => rst ,en => en , ld => clr_s, d_in => "000", cnt => cnt_s);

great_counter : ENTITY work.COUNTETR(rtl) GENERIC MAP (size => 7) PORT MAP(clk => clk ,rst => rst ,en => en ,ld => clr_g ,d_in => "0000000", cnt => cnt_g);

eq_s <= '1' WHEN cnt_s = "111" ELSE '0';
eq_g <= '1' WHEN cnt_g = (num_reg(6 DOWNTO 0) - 1)  ELSE '0';


------------------------------------------------------------------------------------------------
flag_reg_inst : ENTITY work.reg16(rtl) PORT MAP(clk => clk ,rst => rst ,ld => ld_flag ,q_in => databus ,q_out => flag_reg);

add_reg_inst : ENTITY work.reg16(rtl) PORT MAP(clk => clk ,rst => rst ,ld => ld_add ,q_in => databus ,q_out => add_reg);

num_reg_inst : ENTITY work.reg16(rtl) PORT MAP(clk => clk ,rst => rst ,ld => ld_num ,q_in => databus ,q_out => num_reg);

reserved_reg_inst : ENTITY work.reg16(rtl) PORT MAP(clk => clk ,rst => rst ,ld => ld_reserved ,q_in => databus ,q_out => reserved_reg);

ld_flag <= '1' WHEN addrbus = x"0C00" ELSE '0';
ld_add <= '1' WHEN addrbus = x"0C01" ELSE '0';
ld_num <= '1' WHEN addrbus = x"0C02" ELSE '0';
ld_reserved <= '1' WHEN addrbus = x"0C03" ELSE '0';

go_flag <= flag_reg(0);
active_write <= flag_reg(2);
active_read <= flag_reg(1);
-----------------------------------------------------------------------------------------------------

RAM_IN : ENTITY work.RAM_IN(rtl) PORT MAP(clk => clk ,addr => cnt_g(6 DOWNTO 0) ,wr => INw ,din => databus, dout => RAM_IN_out);

RAM_OUT : ENTITY work.RAM_OUT(rtl) PORT MAP(clk => clk ,addr => add_ram_out ,wr => writetoDMA, din => datatoDMA, dout => dataout);

add_ram_out <= addrtoDMA(6 DOWNTO 0) WHEN writetoDMA = '1' ELSE cnt_g;

------------------------------------------------------------------------------------------------------

addout <= add_reg + ("000000000" & cnt_g);

databus <= dataout WHEN seldatabus = '1' ELSE (OTHERS => 'Z');
addrbus <= addout WHEN seladdbus = '1' ELSE (OTHERS => 'Z');
     
numOfData <= num_reg;

cnt_gout <= cnt_g;


END ARCHITECTURE;
