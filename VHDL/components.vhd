LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY reg32 IS
    PORT (
        clk,rst,en : IN std_logic;
        q_in : IN std_logic_vector(31 DOWNTO 0);
        q_out : OUT std_logic_vector(31 DOWNTO 0)
    );
END ENTITY reg32;

ARCHITECTURE rtl OF reg32 IS
BEGIN
    main_PROC : PROCESS(clk)
    BEGIN
        IF (clk='1' AND clk'EVENT) THEN
            IF (rst = '1') THEN
                q_out <= (OTHERS => '0');
            ELSIF(en = '1') THEN
                q_out <= q_in ;
            END IF;
        END IF;

    END PROCESS;

END ARCHITECTURE;
-----------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY reg16 IS
    PORT (
        clk,rst,ld : IN std_logic;
        q_in : IN std_logic_vector(15 DOWNTO 0);
        q_out : OUT std_logic_vector(15 DOWNTO 0)
    );
END ENTITY reg16;

ARCHITECTURE rtl OF reg16 IS
BEGIN
    main_PROC : PROCESS(clk)
    BEGIN
        IF (clk='1' AND clk'EVENT) THEN
            IF (rst = '1') THEN
                q_out <= (OTHERS => '0');
            ELSIF(ld = '1') THEN
                q_out <= q_in ;
            END IF;
        END IF;

    END PROCESS;
    
END ARCHITECTURE;
------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY reg3 IS
    PORT (
        clk,rst,ld : IN std_logic;
        q_in : IN std_logic_vector(2 DOWNTO 0);
        q_out : OUT std_logic_vector(2 DOWNTO 0)
    );
END ENTITY reg3;

ARCHITECTURE ARC OF reg3 IS
BEGIN
    main_PROC : PROCESS(clk)
    BEGIN
        IF (clk='1' AND clk'EVENT) THEN
            IF (rst = '1') THEN
                q_out <= (OTHERS => '0');
            ELSIF(ld = '1') THEN
                q_out <= q_in ;
            END IF;
        END IF;

    END PROCESS;
    
END ARCHITECTURE;
-----------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.Std_Logic_unsigned.all;

ENTITY RAM IS
    GENERIC(size :  INTEGER := 128);
    PORT (
        clk : IN std_logic;
        addr : IN std_logic_vector(6 DOWNTO 0);
        wr : IN std_logic :='0';
        din : IN std_logic_vector(15 DOWNTO 0);
        dout : OUT std_logic_vector(15 DOWNTO 0) 
    );
END ENTITY RAM;

ARCHITECTURE ARC OF RAM IS
    TYPE memory IS ARRAY (INTEGER RANGE <>) OF std_logic_vector(15 DOWNTO 0);
    SIGNAL mem : memory(0 TO size-1) := (OTHERS => x"0000"); 
BEGIN
    write : PROCESS(clk)
    BEGIN
        IF clk='1' AND clk'EVENT THEN
            IF wr = '1' THEN 
                mem(to_integer(unsigned(addr))) <= din;
            END IF ;
        END IF;
    END PROCESS;

    dout <= mem(to_integer(unsigned(addr)));

END ARCHITECTURE;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.Std_Logic_unsigned.all;

ENTITY RAM_cof IS
    GENERIC(size :  INTEGER := 16);
    PORT (
        clk : IN std_logic;
        addr : IN std_logic_vector(3 DOWNTO 0);
        wr : IN std_logic :='0';
        din : IN std_logic_vector(15 DOWNTO 0);
        dout : OUT std_logic_vector(15 DOWNTO 0) 
    );
END ENTITY RAM_cof;

ARCHITECTURE rtl OF RAM_cof IS
    TYPE memory IS ARRAY (INTEGER RANGE <>) OF std_logic_vector(15 DOWNTO 0);
    SIGNAL mem : memory(0 TO size-1) := (OTHERS => x"0000"); 
BEGIN
    write : PROCESS(clk)
    BEGIN
        IF clk='1' AND clk'EVENT THEN
            IF wr = '1' THEN 
                mem(to_integer(unsigned(addr))) <= din;
            END IF ;
        END IF;
    END PROCESS;

    dout <= mem(to_integer(unsigned(addr)));

END ARCHITECTURE;

------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.Std_Logic_unsigned.all;

ENTITY RAM_IN IS
    GENERIC(size :  INTEGER := 128);
    PORT (
        clk : IN std_logic;
        addr : IN std_logic_vector(6 DOWNTO 0);
        wr : IN std_logic :='0';
        din : IN std_logic_vector(15 DOWNTO 0);
        dout : OUT std_logic_vector(15 DOWNTO 0) 
    );
END ENTITY RAM_IN;

ARCHITECTURE rtl OF RAM_IN IS
    TYPE memory IS ARRAY (INTEGER RANGE <>) OF std_logic_vector(15 DOWNTO 0);
    SIGNAL mem : memory(0 TO size-1) := (OTHERS => x"0000"); 
BEGIN
    write : PROCESS(clk)
    BEGIN
        IF clk='1' AND clk'EVENT THEN
            IF wr = '1' THEN 
                mem(to_integer(unsigned(addr))) <= din;
            END IF ;
        END IF;
    END PROCESS;

    dout <= mem(to_integer(unsigned(addr)));

END ARCHITECTURE;

----------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.Std_Logic_unsigned.all;

ENTITY RAM_OUT IS
    GENERIC(size :  INTEGER := 128);
    PORT (
        clk : IN std_logic;
        addr : IN std_logic_vector(6 DOWNTO 0);
        wr : IN std_logic :='0';
        din : IN std_logic_vector(15 DOWNTO 0);
        dout : OUT std_logic_vector(15 DOWNTO 0) 
    );
END ENTITY RAM_OUT;

ARCHITECTURE rtl OF RAM_OUT IS
    TYPE memory IS ARRAY (INTEGER RANGE <>) OF std_logic_vector(15 DOWNTO 0);
    SIGNAL mem : memory(0 TO size-1) := (OTHERS => x"0000");
BEGIN
    write : PROCESS(clk)
    BEGIN
        IF clk='1' AND clk'EVENT THEN
            IF wr = '1' THEN 
                mem(to_integer(unsigned(addr))) <= din;
            END IF ;
        END IF;
    END PROCESS;

    dout <= mem(to_integer(unsigned(addr)));

END ARCHITECTURE;
-----------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.Std_Logic_unsigned.all;

ENTITY COUNTETR IS
    generic(size : INTEGER := 4);
    PORT(
        clk,rst,en,ld : IN std_logic;
        d_in : IN std_logic_vector(size-1 DOWNTO 0);
        cnt : OUT std_logic_vector(size-1 DOWNTO 0)
    );
END ENTITY COUNTETR;

ARCHITECTURE rtl OF COUNTETR IS
BEGIN
    main_PROC : PROCESS(clk,rst)
        VARIABLE temp : std_logic_vector(size-1 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        IF clk='1' AND clk'EVENT THEN
            IF rst = '1' THEN
                temp := (OTHERS => '0');
            ELSIF ld = '1' THEN
                temp := d_in;
            ELSIF en = '1' THEN
                temp := temp + 1;
            END IF;
        END IF;

        cnt <= temp;
    END PROCESS;

END ARCHITECTURE;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;

ENTITY fir1 IS
    PORT (
        clk,rst,en : IN std_logic;
        x,cof : IN std_logic_vector(15 DOWNTO 0);
        y : OUT std_logic_vector(15 DOWNTO 0)
    );
END ENTITY fir1;

ARCHITECTURE rtl OF fir1 IS
    SIGNAL mul,add,reg_out : std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');
BEGIN
        ins1 : ENTITY work.reg32(rtl) PORT MAP(clk,rst,en,add,reg_out);
        mul <= cof * x ;
        add <= mul + reg_out;
        y <= reg_out(15 DOWNTO 0);
        
END ARCHITECTURE;