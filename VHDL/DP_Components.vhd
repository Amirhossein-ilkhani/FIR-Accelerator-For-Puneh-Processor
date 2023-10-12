LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ARU IS
  PORT (
    in0, in1  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    Out_P     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    ADD, MUL  : IN STD_LOGIC;
	clk, rst  : IN STD_LOGIC;
    Z, N, C, V, completeR4 : OUT STD_LOGIC
  );
END ENTITY ARU;

ARCHITECTURE behaviour OF ARU IS
  SIGNAL result : STD_LOGIC_VECTOR(16 DOWNTO 0);
--modified
  SIGNAL out_mul: STD_LOGIC_VECTOR(16 DOWNTO 0);
  SIGNAL completeR4_copy :STD_LOGIC;
---------------------------------------------
BEGIN
--Using booth multiplier instead of the '*' operation
	booth_mul: ENTITY work.BoothMul(BoothMul_ARC) PORT MAP
	(clk=>clk, rst=>rst, X=>in0(7 DOWNTO 0), Y=>in1(7 DOWNTO 0), OUTR4=>out_mul,
	startMUL=>MUL, completeR4=>completeR4_copy);
	completeR4<=completeR4_copy;
	
	PROCESS (in0, in1, ADD, MUL, completeR4_copy)
	BEGIN		
		IF ADD = '1' THEN
			result <= STD_LOGIC_VECTOR(TO_UNSIGNED(TO_INTEGER(UNSIGNED(in0)) +
					TO_INTEGER(UNSIGNED(in1)), result'length));
		ELSIF MUL = '1' THEN
		--modified
		--boothmul
			-- result <= STD_LOGIC_VECTOR(TO_UNSIGNED(TO_INTEGER(UNSIGNED(in0(7 DOWNTO 0))) *
			-- 		TO_INTEGER(UNSIGNED(in1(7 DOWNTO 0))), result'length));
			IF completeR4_copy='1' THEN
				result <= out_mul;
			END IF;
		-------------------------------------
		END IF;
	END PROCESS;
	Out_P <= result(15 DOWNTO 0);
	C     <= result(16);
	Z     <= '1' WHEN (result(15 DOWNTO 0)= X"0000") ELSE '0';
	N     <= '1' WHEN (result(15)= '1') ELSE '0';
	V     <= '1' WHEN ((in0 (15)='1' AND in1 (15)='1' AND result(15)= '0') OR 
					(in0 (15)='0' AND in1 (15)='0' AND result(15)= '1')) ELSE '0';
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY LGU IS
  PORT (
    in0   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    in1   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    Out_P : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    AND_LGU, NOT_LGU : IN STD_LOGIC;
	SHF   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    Z, N  : OUT STD_LOGIC
  );
END ENTITY LGU;

ARCHITECTURE behaviour OF LGU IS
	SIGNAL result  : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	PROCESS (in0, in1, SHF, AND_LGU, NOT_LGU)
	BEGIN		
		IF AND_LGU = '1' THEN
			result <= in0 AND in1; 
		ELSIF NOT_LGU = '1' THEN
			result <= NOT in0;
		ELSIF SHF = "00" THEN                                    -- arithmetic right shift
			result <= to_stdlogicvector (to_bitvector (STD_LOGIC_VECTOR (unsigned(in0))) SRA to_integer (unsigned(in1(3 DOWNTO 0))));
			       
		ELSIF SHF = "01" THEN                                    -- logical right shift
			result <= STD_LOGIC_VECTOR (unsigned (in0) SRL (to_integer (unsigned (in1(3 DOWNTO 0)))));
	                        
		ELSIF SHF = "10" THEN                                    -- logic left shift
			result <= STD_LOGIC_VECTOR (unsigned (in0) SLL (to_integer (unsigned (in1(3 DOWNTO 0)))));                           
		ELSE
			result <= (OTHERS => '0');
		end if;
	END PROCESS;
	Out_P <= result(15 DOWNTO 0);
	Z     <= '1' WHEN (result(15 DOWNTO 0)= X"0000") ELSE '0';
	N     <= '1' WHEN (result(15)= '1') ELSE '0';
	
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Reg_P IS
  PORT (
    clk, rst: IN STD_LOGIC;
    in_P    : IN STD_LOGIC_VECTOR;
    Out_P   : OUT STD_LOGIC_VECTOR;
	ld, clr : IN STD_LOGIC
	);
END ENTITY Reg_P;
--
ARCHITECTURE behaviour OF Reg_P IS
BEGIN
  PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      Out_P <= (Out_P'RANGE =>'0');
    ELSIF clk = '1' AND clk'event THEN
      IF clr = '1' THEN
        Out_P <= (Out_P'RANGE =>'0');
      ELSIF ld = '1' THEN
        Out_P <= in_P;
      END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY INC IS
  PORT (
    in_P    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    inc_val : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    Out_P   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END ENTITY INC;
--
ARCHITECTURE behaviour OF INC IS

BEGIN
	Out_P <= STD_LOGIC_VECTOR(TO_UNSIGNED(TO_INTEGER(UNSIGNED(in_P)) +
					TO_INTEGER(UNSIGNED(inc_val)), Out_P'length));

END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY INC1 IS
  PORT (
    in_P    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    inc_val : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    Out_P   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END ENTITY INC1;
--
ARCHITECTURE behaviour OF INC1 IS

BEGIN
	Out_P <= STD_LOGIC_VECTOR(TO_UNSIGNED(TO_INTEGER(UNSIGNED(in_P)) +
					TO_INTEGER(UNSIGNED(inc_val)), Out_P'length));

END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY IMM IS
  PORT (
    in0      : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    in1      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    Out_P    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    conOF    : IN STD_LOGIC;
    SE12bits : IN STD_LOGIC;
    SE4bits  : IN STD_LOGIC;
    LSB0E    : IN STD_LOGIC
  );
END ENTITY IMM;
--
ARCHITECTURE behaviour OF IMM IS

BEGIN
	Out_P <=  in1 & in0 WHEN conOF = '1' ELSE
			  in1 & (11 DOWNTO 0 => '0') WHEN LSB0E = '1' ELSE
			  (15 DOWNTO 4 => in0(3)) & in0(3 DOWNTO 0) WHEN SE12bits = '1' ELSE
			  (15 DOWNTO 12 => in0(11)) & in0 WHEN SE4bits = '1' ELSE
			  (OTHERS => '0');
END ARCHITECTURE behaviour;

------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY Mux2to1 IS
	PORT (
		in0, in1   : IN STD_LOGIC_VECTOR;
		sel0, sel1 : IN STD_LOGIC;
		out_P      : OUT STD_LOGIC_VECTOR
	);
END ENTITY Mux2to1;

ARCHITECTURE behaviour OF Mux2to1 IS
BEGIN
	out_P <= in0 WHEN sel0 = '1' ELSE
			  in1 WHEN sel1 = '1' ELSE 
			  (Out_P'RANGE =>'0');
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY Mux4to1 IS
	PORT (
		in0, in1, in2, in3     : IN STD_LOGIC_VECTOR;
		sel0, sel1, sel2, sel3 : IN STD_LOGIC;
		out_P                 : OUT STD_LOGIC_VECTOR
	);
END ENTITY Mux4to1;

ARCHITECTURE behaviour OF Mux4to1 IS
BEGIN
	out_P <=  in0 WHEN sel0 = '1' ELSE
			  in1 WHEN sel1 = '1' ELSE 
			  in2 WHEN sel2 = '1' ELSE 
			  in3 WHEN sel3 = '1' ELSE 
			  (Out_P'RANGE =>'0');
END ARCHITECTURE behaviour;
-----------------------------------------------------------------------------------------------
--modified
--counter
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.numeric_std.ALL;
	
ENTITY counter_4 IS
	PORT (
		ld_counter,clk,rst : IN STD_LOGIC;
		cnt_out            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END ENTITY counter_4;

ARCHITECTURE counter_arc OF counter_4 IS
SIGNAL temp :STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
cnt_out<= temp;
PROCESS(clk,rst)
BEGIN
	IF rst='1' THEN
		temp<=(OTHERS=>'0');
	ELSIF clk='1' AND clk'EVENT THEN
			IF ld_counter ='1' THEN
				temp<="1100";
			ELSE 
				temp<=temp +"0001";
		END IF;
	END IF; 

END PROCESS;
END ARCHITECTURE counter_arc;

--modified
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY Mux3to1 IS
	PORT (
		in0, in1, in2     : IN STD_LOGIC_VECTOR;
		sel0, sel1, sel2  : IN STD_LOGIC;
		out_P             : OUT STD_LOGIC_VECTOR
	);
END ENTITY Mux3to1;

ARCHITECTURE behaviour OF Mux3to1 IS
BEGIN
	out_P <=  in0 WHEN sel0 = '1' ELSE
			  in1 WHEN sel1 = '1' ELSE 
			  in2 WHEN sel2 = '1' ELSE 
			  (Out_P'RANGE =>'0');
END ARCHITECTURE behaviour;
-----------------------------------------------------------------------------