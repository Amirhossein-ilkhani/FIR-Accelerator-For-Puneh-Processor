LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

ENTITY test_fir IS
END ENTITY test_fir;


ARCHITECTURE arc_test OF test_fir IS
	SIGNAL clk,r : STD_LOGIC := '0';
	-- SIGNAL r,writeNUM,writetoFIR : STD_LOGIC;
	-- signal databus,addbus,DataToFir,NUMToFir : std_logic_vector(15 DOWNTO 0);
	-- SIGNAL AddFromDMA : STD_LOGIC_VECTOR(6 DOWNTO 0);

    BEGIN	
	clk <= NOT clk AFTER 2 NS WHEN NOW <= 5000 NS ELSE '0';
	r <= '0','1'AFTER 15 NS, '0' AFTER 20 NS;

    test : ENTITY WORK.system(BEHAVIORAL) PORT MAP (clkin=>clk,rstin=>r);
    -- PROCESS
	-- BEGIN
	-- 	WAIT FOR 25 NS;
	-- 	NUMToFir <= x"000f";
	-- 	writeNUM <= '1';
	-- 	writetoFIR <= '0';
	-- 	WAIT FOR 5 NS;
	-- 	DataToFir <= x"0001";
	-- 	AddFromDMA <= "0000000";
	-- 	writeNUM <= '0';
	-- 	writetoFIR <= '1';
	-- 	wait for 5 NS;
	-- 	DataToFir <= x"0002";
	-- 	AddFromDMA <= "0000001";
	-- 	writeNUM <= '0';
	-- 	writetoFIR <= '1';
	-- 	wait for 5 NS;
	-- 	wait;

	-- 	-- WAIT FOR 25 NS;
	-- 	-- addbus<=x"0B00";
	-- 	-- databus <= x"0008";
	-- 	-- WAIT FOR 5 NS;
	-- 	-- addbus<=x"0B01";
	-- 	-- databus <= x"0001";
	-- 	-- wait for 5 NS;
	-- 	-- wait;

	-- 	-- WAIT FOR 25 NS;
	-- 	-- -- interrupt pulse for one clk
	-- 	-- addbus<=x"0C06";
	-- 	-- WAIT FOR 10 NS;
	-- 	-- addbus<=x"0001";
	-- 	-- wait for 2 NS;
	-- 	-- wait;
	-- END PROCESS;	
END ARCHITECTURE arc_test;
