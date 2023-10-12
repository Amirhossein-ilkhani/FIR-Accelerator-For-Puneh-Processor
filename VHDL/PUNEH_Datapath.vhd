LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Datapath IS
  PORT (
    clk, rst, AND_LGU, NOT_LGU, ADD, MUL, sel1_ARU, selIMM_LGU,
	selMEM_LGU, ldAC, zeroAC, selIMM_AC, selMEM_AC, selARU_AC,
	selLGU_AC, ldPC, selINC_PC, selMEM_PC, selIMM_PC, ldIN, 
	selINC_IN, selMEM_IN, conOF, SE12bits, SE4bits, ldIR, ldOF,
	selPC_OF, selIMM_OF, selIN_ADR, selPC_ADR, selAC_MEM, selIR_ADR,
	seldataBus, INC1, INC2, selSET_SR, selLGU_SR, selARU_SR, selMO_ARU,
	selIN_MEM, selPC_MEM, LSB0E: IN std_logic;


  INC0, ld_counter, selInt_MEM, selInt_PC, selSR_MEM,
  selMEM_OF, selMEM_SR, clr1, clr2, ldINTRP, sel0, selc: IN std_logic;
  selofout, self: IN std_logic;

  completeR4        : OUT std_logic;

  in_intrp          : IN std_logic_vector(0 DOWNTO 0);

  flag1, flag2      : OUT std_logic_vector(0 DOWNTO 0);


	enSKP      : OUT std_logic; 
	SHF        : IN std_logic_vector(1 DOWNTO 0);
	dataBus    : INOUT std_logic_vector(15 DOWNTO 0);
	ldSR       : IN std_logic_vector(3 DOWNTO 0);
	addrBus    : OUT std_logic_vector(15 DOWNTO 0);
  IRout      : OUT std_logic_vector(15 DOWNTO 0);


  seladdrBus : IN std_logic

  );
END Datapath;

ARCHITECTURE rtl OF Datapath IS
  SIGNAL Z1, Z2, N1, N2, C, V             : std_logic;
  SIGNAL toINC                            : std_logic_vector(1 DOWNTO 0);
  SIGNAL toOF, OFout, toSR, expected, obs : std_logic_vector(3 DOWNTO 0);
  SIGNAL w                                : std_logic_vector(11 DOWNTO 0);
  SIGNAL fg1,fg2                          : std_logic_vector(3 DOWNTO 0);
  SIGNAL IR_out_reg             : std_logic_vector(15 DOWNTO 0);
  SIGNAL ARU_AC, LGU_AC, MEM_AC, IMM_AC, AC_MEM, MO, MO_ARU, toAC,
  PC_MEM, toPC, toIN, IN_MEM, INC_PC, INC2_out, toBuff : std_logic_vector(15 DOWNTO 0);
  

  SIGNAL toBuff2  : std_logic_vector(15 DOWNTO 0);


  SIGNAL cnt_out            : std_logic_vector(3 DOWNTO 0);
  SIGNAL cnt_mem            : std_logic_vector(15 DOWNTO 0);
  SIGNAL out_max_counter    : std_logic_vector(15 DOWNTO 0);
  

  SIGNAL SR_MEM            : std_logic_vector(15 DOWNTO 0);

  SIGNAL out_max11            : std_logic_vector(3 DOWNTO 0);
 
BEGIN
  fg1 <= (Z1 & N1 & "ZZ");
  fg2 <= (Z2 & N2 & C & V);


   SR_MEM<= x"000" & w(3 DOWNTO 0);
   cnt_mem<=x"0af" & cnt_out;
  

  LGU_1 : ENTITY work.LGU PORT MAP (AC_MEM, MO, LGU_AC, AND_LGU, NOT_LGU, SHF, Z1, N1);


  ARU_1 : ENTITY work.ARU PORT MAP (in0=>AC_MEM,in1=> MO_ARU,Out_P=> ARU_AC, ADD=>ADD, MUL=>MUL,Z=> Z2, N=>N2,C=> C,V=>V,clk=>clk,rst=> rst,completeR4=>completeR4);

  MUX_1  : ENTITY work.Mux2to1 PORT MAP ("0000000000000001", MO, sel1_ARU, selMO_ARU, MO_ARU);
  MUX_2  : ENTITY work.Mux2to1 PORT MAP (IMM_AC, MEM_AC, selIMM_LGU, selMEM_LGU, MO);
  MUX_3  : ENTITY work.Mux4to1 PORT MAP (IMM_AC, MEM_AC, ARU_AC, LGU_AC, selIMM_AC,
															selMEM_AC, selARU_AC, selLGU_AC, toAC);
                         
  MUX_4  : ENTITY work.Mux3to1 PORT MAP (PC_MEM(15 DOWNTO 12), IMM_AC(3 DOWNTO 0),
                       MEM_AC(15 DOWNTO 12), selPC_OF, selIMM_OF, selMEM_OF, toOF);

  MUX_5  : ENTITY work.Mux4to1 PORT MAP (INC_PC, MEM_AC, IMM_AC, x"0AF1", selINC_PC,
                       selMEM_PC, selIMM_PC, selInt_PC, toPC);

  MUX_6  : ENTITY work.Mux2to1 PORT MAP (INC2_out, MEM_AC, selINC_IN, selMEM_IN, toIN);
  MUX_7  : ENTITY work.Mux4to1 PORT MAP (in0 => IN_MEM, in1 => INC_PC, in2 => AC_MEM,
                                        in3 => SR_MEM,  sel0 => selIN_MEM, sel1 => selPC_MEM,
                                        sel2=> selAC_MEM, sel3 => selSR_MEM, Out_P => toBuff);
                                  
  MUX_8  : ENTITY work.Mux4to1 PORT MAP (IN_MEM, IMM_AC, PC_MEM, out_max_counter, 
                                        selIN_ADR,selIR_ADR, selPC_ADR, selInt_MEM , toBuff2);
  MUX_9  : ENTITY work.Mux3to1 PORT MAP ("10", "01", "00", INC2, INC1, INC0, toINC);

  MUX_10 : ENTITY work.Mux4to1 PORT MAP (IR_out_reg(3 DOWNTO 0), fg1, fg2, MEM_AC(3 DOWNTO 0),
                                       selSET_SR,selLGU_SR, selARU_SR, selMEM_SR, toSR);

  MUX_11  : ENTITY work.Mux2to1 PORT MAP (in0=>"0000", in1=>"0000",  sel0=>self, sel1=>selofout,  out_P=>out_max11);

  counter : ENTITY work.counter_4 PORT MAP (clk=>clk, rst=>rst,ld_counter=>ld_counter,cnt_out=>cnt_out);

  mux_counter :  ENTITY work.Mux2to1 PORT MAP (in0=>x"0AF0",in1=>cnt_mem,sel0=>sel0,sel1=>selc,out_P=>out_max_counter);


  AC     : ENTITY work.Reg_P PORT MAP (clk, rst, toAC, AC_MEM, ldAC, zeroAC);
  IR     : ENTITY work.Reg_P PORT MAP (clk, rst, MEM_AC, IR_out_reg, ldIR, '0');
  PC     : ENTITY work.Reg_P PORT MAP (clk, rst, toPC, PC_MEM, ldPC, '0');
  IN_Reg : ENTITY work.Reg_P PORT MAP (clk, rst, toIN, IN_MEM, ldIN, '0');
  OF_Reg : ENTITY work.Reg_P PORT MAP (clk, rst, toOF, OFout, ldOF, '0');
  SR_Z   : ENTITY work.Reg_P PORT MAP (clk, rst, toSR(3 DOWNTO 3), w(3 DOWNTO 3), ldSR(3), '0');-- because it is std_vector so (3 downto 3)
  SR_N   : ENTITY work.Reg_P PORT MAP (clk, rst, toSR(2 DOWNTO 2), w(2 DOWNTO 2), ldSR(2), '0');
  SR_C   : ENTITY work.Reg_P PORT MAP (clk, rst, toSR(1 DOWNTO 1), w(1 DOWNTO 1), ldSR(1), '0');
  SR_V   : ENTITY work.Reg_P PORT MAP (clk, rst, toSR(0 DOWNTO 0), w(0 DOWNTO 0), ldSR(0), '0');
  

  INTRP_Reg1 : ENTITY work.Reg_P PORT MAP (clk=>clk, rst=>rst, ld=> ldINTRP, clr=>clr1, Out_P=>flag1(0 DOWNTO 0), in_P=>in_intrp(0 DOWNTO 0));
  INTRP_Reg2 : ENTITY work.Reg_P PORT MAP (clk=>clk, rst=>rst, ld=> ldINTRP, clr=>clr2, Out_P=>flag2(0 DOWNTO 0), in_P=>in_intrp(0 DOWNTO 0));


  IMM_1 : ENTITY work.IMM PORT MAP (IR_out_reg(11 DOWNTO 0), out_max11, IMM_AC, conOF, SE12bits, SE4bits, LSB0E);
  INC_1 : ENTITY work.INC PORT MAP (PC_MEM, toINC, INC_PC);
  INC_2 : ENTITY work.INC PORT MAP (MEM_AC, "01", INC2_out);
  dataBus <= (OTHERS => 'Z') WHEN seldataBus = '0' ELSE toBuff;


  addrBus <= toBuff2 WHEN seladdrBus = '1' ELSE (OTHERS => 'Z');
  
  expected <= IR_out_reg(3 DOWNTO 0);
  w(4)     <= NOT(w(0) XOR expected(0));
  w(5)     <= NOT(w(1) XOR expected(1));
  w(6)     <= NOT(w(2) XOR expected(2));
  w(7)     <= NOT(w(3) XOR expected(3));
  obs      <= IR_out_reg(7 DOWNTO 4);
  w(8)     <= w(4) AND obs(0);
  w(9)     <= w(5) AND obs(1);
  w(10)    <= w(6) AND obs(2);
  w(11)    <= w(7) AND obs(3);
  enSKP    <= w(8) OR w(9) OR w(10) OR w(11);
  MEM_AC   <= dataBus;

  IRout <= IR_out_reg;

END ARCHITECTURE;