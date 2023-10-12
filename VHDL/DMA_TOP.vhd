LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY DMA_TOP IS
    PORT (
        clk ,rst : IN std_logic;
        DMA_grant : IN std_logic;
        writetoDMA : IN std_logic;
        datatoDMA : IN std_logic_vector(15 downto 0);
        addrtoDMA : IN std_logic_vector(6 downto 0);
        firComplete : IN std_logic;
        addrbus : INOUT std_logic_vector(15 downto 0);
        databus : INOUT std_logic_vector(15 downto 0);
        writetoFIR : OUT std_logic;
        DMA_req : OUT std_logic;
        out_full : OUT std_logic;
        in_full : OUT std_logic;
        datatoFIR : OUT std_logic_vector(15 downto 0);
        cnt_g : OUT std_logic_vector(6 DOWNTO 0);
        write_num : OUT std_logic;
        mem_read : OUT std_logic;
        mem_write : OUT std_logic;
        numOfData : OUT std_logic_vector(15 downto 0);
        out_complete : OUT std_logic
        );
END ENTITY DMA_TOP;

ARCHITECTURE rtl OF DMA_TOP IS
    SIGNAL en, clr_s, clr_g, INw, seladdbus, seldatabus, eq_s, eq_g, active_read, active_write, go_flag :std_logic;
BEGIN

    DP : ENTITY work.DMA_DP(rtl) PORT MAP(
        clk => clk,
        rst => rst,
        addrbus => addrbus, 
        databus => databus,
        datatoDMA => datatoDMA,
        addrtoDMA  => addrtoDMA,
        writetoDMA  => writetoDMA,
        numOfData  => numOfData,
        cnt_gout  => cnt_g,  
        -------FROM/TO controller
        en => en, 
        clr_s => clr_s, 
        clr_g => clr_g, 
        INw => INw, 
        seladdbus => seladdbus, 
        seldatabus => seldatabus,
        eq_s => eq_s, 
        eq_g => eq_g, 
        active_read => active_read, 
        active_write => active_write, 
        go_flag  => go_flag
    );  

    CTRL : ENTITY work.DMA_CTRL(rtl) PORT MAP(
        clk => clk,
        rst => rst,
        seldatabus => seldatabus,
        sel_addbus => seladdbus,
        eq_g => eq_g,
        eq_s => eq_s,
        go_flag => go_flag,
        active_read => active_read,
        active_write => active_write,
        DMA_grant => DMA_grant,
        clr_g => clr_g,
        clr_s => clr_s,
        DMA_req => DMA_req,
        INw => INw,
        en => en,
        in_full => in_full,
        out_full => out_full,
        write_num => write_num,
        mem_read => mem_read,
        mem_write => mem_write,
        out_complete => out_complete,
        firComplete => firComplete
    );

    writetoFIR <= INw;
    datatoFIR <= databus;
END ARCHITECTURE;
