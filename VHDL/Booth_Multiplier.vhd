-- GENERIC BIT REGISTER
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY GENERIC_REG IS 
GENERIC (N : INTEGER );
PORT( clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    ld : IN STD_LOGIC;
    reg_in : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0 );
    reg_out : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0 ));
END ENTITY GENERIC_REG;

ARCHITECTURE GENERIC_REG_ARC OF GENERIC_REG IS
SIGNAL temp_reg : STD_LOGIC_VECTOR (N-1 DOWNTO 0 );
BEGIN
reg_out <= temp_reg;
P3: PROCESS(clk , rst)
BEGIN
    IF rst = '1' THEN
        temp_reg <= (OTHERS => '0');
    ELSIF clk = '1' AND clk'EVENT THEN  
        IF ld = '1' THEN
        temp_reg <= reg_in;
        END IF;
    ELSE
    END IF;
END PROCESS ;
END ARCHITECTURE GENERIC_REG_ARC;

-----------------------------------------------------------------------------------------------
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
    --3 BIT COUNTER
ENTITY COUNTER_3 IS 
PORT( clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;--reset counter
    cnt_enable : IN STD_LOGIC;--enable counting
    clear_counter : IN STD_LOGIC;--load counter with zero
    cnt_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0));
END ENTITY COUNTER_3;

ARCHITECTURE COUNTER_ARC OF COUNTER_3 IS
SIGNAL temp : STD_LOGIC_VECTOR ( 2 DOWNTO 0 );
BEGIN
cnt_out <= temp;
P4: PROCESS(clk , rst)
BEGIN
    IF rst = '1' THEN
        temp <= (OTHERS => '0');
    ELSIF clk = '1' AND clk'EVENT THEN 
        IF cnt_enable ='1' THEN
            IF (temp = "100") THEN temp <= "000"; 
            ELSE temp <= temp + "001";--count up 
            END IF;
        ELSIF clear_counter = '1' THEN
            temp <= "000";
        END IF;
    ELSE 
    END IF;
END PROCESS;
END ARCHITECTURE COUNTER_ARC;



-------------------------------------------------------------------
--Datapath
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.Numeric_Std.all;

ENTITY Booth_DataPath IS PORT(
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    X : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    Y: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    OUTR4: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    new_data : IN STD_LOGIC;-- to empty the temp-reg
    counter_value : IN STD_LOGIC_VECTOR (2 DOWNTO 0));
END ENTITY Booth_DataPath;


ARCHITECTURE DataPath_ARC OF Booth_DataPath IS   

    TYPE memory IS ARRAY (INTEGER RANGE<> ) OF  STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL Y_modified : memory (3 DOWNTO 0); 

    --signal declaration:
    SIGNAL Add_out, shift_out, temp_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Xout_8 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Xout : STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL out_reg_y: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Yout, Y_2scomp : STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL Y_shift ,Y_shift_2scomp: STD_LOGIC_VECTOR(9 DOWNTO 0);
    
    BEGIN
    shift_out <= Y_modified(0) WHEN (counter_value = "000") 
                ELSE (Y_modified(1)(13 DOWNTO 0)&"00")WHEN (counter_value = "001") 
                ELSE (Y_modified(2)(11 DOWNTO 0)&"0000")WHEN (counter_value = "010")
                ELSE (Y_modified(3)(9 DOWNTO 0)&"000000")WHEN (counter_value = "011")
                ELSE x"0000";
                
    Add_out <= x"0000" WHEN (new_data='1') ELSE temp_out + shift_out;
    Xout <= Xout_8 & '0';
    OUTR4 <= temp_out;


--modifying Y:
    Y_2scomp <=  (NOT Yout) +'1';
    Y_shift <= Yout & '0';
    Y_shift_2scomp <= (NOT(Y_shift)) + '1';
    Yout<= out_reg_y(7) & out_reg_y;

    Y_modified(0) <=x"0000" WHEN (Xout(2 DOWNTO 0) ="000" OR Xout(2 DOWNTO 0) ="111")
                    ELSE ((15 DOWNTO 9=>Yout(8)) & Yout) WHEN (Xout(2 DOWNTO 0) ="001" OR Xout(2 DOWNTO 0) ="010")
                    ELSE ((15 DOWNTO 10=>Y_shift(9)) & Y_shift) WHEN (Xout(2 DOWNTO 0) ="011")
                    ELSE ((15 DOWNTO 10=>Y_shift_2scomp(9)) & Y_shift_2scomp) WHEN (Xout(2 DOWNTO 0) ="100")
                    ELSE ((15 DOWNTO 9=>Y_2scomp(8)) & Y_2scomp) WHEN (Xout(2 DOWNTO 0) ="101" OR Xout(2 DOWNTO 0) ="110")
                    ELSE x"0000";

    Y_modified(1) <=x"0000" WHEN (Xout(4 DOWNTO 2) ="000" OR Xout(4 DOWNTO 2) ="111")
                    ELSE ((15 DOWNTO 9=>Yout(8)) & Yout) WHEN (Xout(4 DOWNTO 2) ="001" OR Xout(4 DOWNTO 2) ="010")
                    ELSE ((15 DOWNTO 10=>Y_shift(9)) & Y_shift) WHEN (Xout(4 DOWNTO 2) ="011")
                    ELSE ((15 DOWNTO 10=>Y_shift_2scomp(9)) & Y_shift_2scomp) WHEN (Xout(4 DOWNTO 2) ="100")
                    ELSE ((15 DOWNTO 9=>Y_2scomp(8)) & Y_2scomp) WHEN (Xout(4 DOWNTO 2) ="101" OR Xout(4 DOWNTO 2) ="110")
                    ELSE x"0000";

    Y_modified(2) <=x"0000" WHEN (Xout(6 DOWNTO 4) ="000" OR Xout(6 DOWNTO 4) ="111")
                    ELSE ((15 DOWNTO 9=>Yout(8)) & Yout) WHEN (Xout(6 DOWNTO 4) ="001" OR Xout(6 DOWNTO 4) ="010")
                    ELSE ((15 DOWNTO 10=>Y_shift(9)) & Y_shift) WHEN (Xout(6 DOWNTO 4) ="011")
                    ELSE ((15 DOWNTO 10=>Y_shift_2scomp(9)) & Y_shift_2scomp) WHEN (Xout(6 DOWNTO 4) ="100")
                    ELSE ((15 DOWNTO 9=>Y_2scomp(8)) & Y_2scomp) WHEN (Xout(6 DOWNTO 4) ="101" OR Xout(6 DOWNTO 4) ="110")
                    ELSE x"0000";

    Y_modified(3) <=x"0000" WHEN (Xout(8 DOWNTO 6) ="000" OR Xout(8 DOWNTO 6) ="111")
                    ELSE ((15 DOWNTO 9=>Yout(8)) &Yout) WHEN (Xout(8 DOWNTO 6) ="001" OR Xout(8 DOWNTO 6) ="010")
                    ELSE ((15 DOWNTO 10=>Y_shift(9)) & Y_shift) WHEN (Xout(8 DOWNTO 6) ="011")
                    ELSE ((15 DOWNTO 10=>Y_shift_2scomp(9)) & Y_shift_2scomp) WHEN (Xout(8 DOWNTO 6) ="100")
                    ELSE ((15 DOWNTO 9=>Y_2scomp(8)) & Y_2scomp) WHEN (Xout(8 DOWNTO 6) ="101" OR Xout(8 DOWNTO 6) ="110")
                    ELSE x"0000";


    X_reg : ENTITY WORK.GENERIC_REG(GENERIC_REG_ARC) generic map (N => 8) PORT MAP
     (clk=>clk , rst=>rst , ld=>'1', reg_in=>X , reg_out =>Xout_8);
    Y_reg : ENTITY WORK.GENERIC_REG(GENERIC_REG_ARC) generic map
     (N => 8) PORT MAP (clk=>clk , rst=>rst , ld=>'1', reg_in=>Y , reg_out =>out_reg_y);
    temp_reg : ENTITY WORK.GENERIC_REG(GENERIC_REG_ARC) generic map
     (N => 16) PORT MAP (clk=>clk , rst=>rst , ld=>'1', reg_in=>Add_out , reg_out =>temp_out);
    

END ARCHITECTURE DataPath_ARC ;


-- ---------------------------------------------------------------------



-- -------------------------------------------------------------
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY Booth_Controller IS 
PORT( clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    startMUL : IN STD_LOGIC;
    completeR4 : OUT STD_LOGIC;
    new_data : OUT STD_LOGIC;
    counter_value : OUT STD_LOGIC_VECTOR (2 DOWNTO 0 ));
END ENTITY Booth_Controller;

ARCHITECTURE Controller_ARC OF Booth_Controller IS

TYPE state IS (waitForStart , calculation);
SIGNAL pstate, nstate : state;

SIGNAL count_out_wire : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
SIGNAL start_counting , cnt_clear : STD_LOGIC;

BEGIN

counter_value <= count_out_wire ;
--proccesses:
State_Transition:   PROCESS (clk , rst)
    BEGIN
        IF rst = '1' THEN
        pstate<= waitForStart;
        ELSIF clk = '1' AND clk'EVENT THEN 
            pstate <= nstate;
        END IF;
    END PROCESS;

   PROCESS (pstate , startMUL ,count_out_wire) BEGIN
 --initialization
    completeR4 <= '0';
    start_counting <='0';
    cnt_clear<='0';

    CASE pstate IS
        WHEN waitForStart =>
            IF (startMUL = '1') THEN nstate <= calculation; completeR4 <= '0'; cnt_clear<='1'; 
            ELSE  nstate <= waitForStart; --completeR4 <= '1';
            END IF ;
            new_data<='1';

        WHEN calculation =>
            IF (count_out_wire = "100") THEN nstate <= waitForStart; completeR4 <= '1';
            ELSE  nstate <= calculation; 
            END IF ;
            start_counting <='1';
            new_data<='0';

        END CASE;
    END PROCESS;

    counter : ENTITY WORK.COUNTER_3(COUNTER_ARC) 
    PORT MAP(clk=>clk ,rst=>rst, cnt_enable=>start_counting ,clear_counter=> cnt_clear, cnt_out=> count_out_wire);


END ARCHITECTURE Controller_ARC;


------------------------------------------------------------------------------------

-- top module
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.Numeric_Std.all;

ENTITY BoothMul IS PORT(
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    X : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    Y : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    OUTR4: OUT STD_LOGIC_VECTOR(16 DOWNTO 0);
    startMUL : IN STD_LOGIC;
    completeR4 : OUT STD_LOGIC);
END ENTITY BoothMul;

ARCHITECTURE BoothMul_ARC OF BoothMul IS
    SIGNAL counter_value_wire :  STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL new_data_wire : STD_LOGIC;
    SIGNAL OUTR44 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    BEGIN
    OUTR4<=OUTR44(15)&OUTR44;
   DataPath : ENTITY WORK.Booth_DataPath(DataPath_ARC) PORT MAP (clk =>clk, rst=>rst , X=>X , Y=>Y , counter_value=> counter_value_wire ,OUTR4 =>OUTR44, new_data=>new_data_wire);
   Controller : ENTITY WORK.Booth_Controller(Controller_ARC) PORT MAP(clk=>clk, rst=>rst, startMUL=> startMUL, completeR4=>completeR4 , counter_value=> counter_value_wire , new_data=>new_data_wire);

END ARCHITECTURE BoothMul_ARC ;