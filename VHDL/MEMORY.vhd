LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
	
ENTITY MEMORY IS
	GENERIC (
		numofinst : INTEGER := 26;
		numofdata : INTEGER := 15 
	);
	PORT (
		clk, rst, readMem, writeMem   : IN STD_LOGIC;
		addrBus     : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		dataBus     : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY MEMORY;

ARCHITECTURE behaviour OF MEMORY IS
	TYPE data_mem IS ARRAY (0 TO 2815) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL dataMEM : data_mem;
	
	IMPURE FUNCTION InitMEMFile
	RETURN data_mem IS
		FILE MemFile : TEXT;
		VARIABLE MemFileLine : LINE;
		VARIABLE GOOD : BOOLEAN;
		VARIABLE fstatus: FILE_OPEN_STATUS;
		VARIABLE Mem : data_mem;
	BEGIN	
		FILE_OPEN (MemFile, "memory.txt", READ_MODE);
		READLINE(MemFile, MemFileLine);
		FOR I IN 0 TO 2815 LOOP
			IF NOT ENDFILE(MemFile) THEN
				READLINE(MemFile, MemFileLine);
				READ(MemFileLine, Mem(I), GOOD);
				REPORT "Status from FILE: '" & BOOLEAN'IMAGE(GOOD) & "'";
			END IF;
		END LOOP;
		
		FILE_close(MemFile);
		RETURN Mem;
	END FUNCTION;
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			dataMEM <= InitMEMFile;
		ELSIF clk = '1' AND clk'EVENT THEN
			IF writeMem = '1' AND addrBus < x"0B00" THEN
				dataMEM(TO_INTEGER(UNSIGNED(addrBus))) <= dataBus;
			END IF;
		END IF;
	END PROCESS;

	dataBus <= dataMEM(TO_INTEGER(UNSIGNED(addrBus))) WHEN (readMem = '1' AND addrBus < x"0B00")ELSE
			(OTHERS => 'Z');
END ARCHITECTURE behaviour;