LIBRARY ieee;
USE IEEE.std_logic_1164.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.numeric_std.all;

ENTITY FIR_TOP IS PORT (
    clk : IN STD_LOGIC;
    r : IN STD_LOGIC;
    databus : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    addbus : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    --to DMA
    DataToFir : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    NUMToFir : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    AddFromDMA : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    writeNUM, writetoFIR : IN STD_LOGIC;
    WriteToDMA : OUT STD_LOGIC;
    DataToDMA : OUT std_logic_vector(15 DOWNTO 0);
    AddToDMA : OUT std_logic_vector(6 DOWNTO 0);
    FirCompelete : OUT STD_LOGIC
);
END ENTITY FIR_TOP;

ARCHITECTURE rtl OF FIR_TOP IS
 SIGNAL rst,start,ldDeg,ldNum,en_g,en_s,clr,firld,firrst,eq_s,eq_g,outw : std_logic;
BEGIN
    DP : ENTITY work.DP_FIR(rtl) PORT MAP(
        clk => clk,
        r => r,
        rst => rst,
        addbus => addbus,
        databus => databus,
        DataToFir => DataToFir,
        NUMToFir => NUMToFir,
        AddFromDMA => AddFromDMA,
        writeNUM => writeNUM,
        writetoFIR => writetoFIR,
        outw => outw,
        ldDeg => ldDeg,
        en_g => en_g,
        en_s => en_s,
        clr => clr,
        firld => firld,
        firrst => firrst,
        eq_s => eq_s,
        eq_g => eq_g,
        start => start,
        WriteToDMA => WriteToDMA,
        DataToDMA => DataToDMA,
        AddToDMA => AddToDMA
    );

    controller : ENTITY work.controller_fir(controller_fir_arc) PORT MAP(
        clk => clk,
        r => r,
        rst=> rst,
        start=> start,
        eq_inner=> eq_s,
        eq_outer=> eq_g,  
        en_inner=> en_s,
        en_outer => en_g,
        ld_fir=> firld,
        ld_degree=> ldDeg,
        ld_inner => clr,
        wr_outp=> outw,
        init_fir=> firrst,
        FirCompelete => FirCompelete
    );

END ARCHITECTURE;



