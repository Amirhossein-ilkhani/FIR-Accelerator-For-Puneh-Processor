LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY PUNEH IS
  PORT ( 
    clk      : IN STD_LOGIC;
    rst      : IN STD_LOGIC;
    in_intrp : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
    dataBus  : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    writeMEM : OUT STD_LOGIC;
    readMEM  : OUT STD_LOGIC;
    addrBus  : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    CPU_ACK : IN std_logic;
    CPU_REQ : OUT std_logic
  );
END ENTITY PUNEH;
ARCHITECTURE toplevel OF PUNEH IS
  SIGNAL inst : STD_LOGIC_VECTOR (15 DOWNTO 0);
  SIGNAL ldSR : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL SHF  : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL enSKP, ldIR, ldOF, ldPC, ldIN, ldAC, zeroAC, seldataBus, selPC_OF,
  selIMM_OF, selMEM_IN, selIMM_LGU, selMEM_LGU, sel1_ARU, selMO_ARU,
  selINC_PC, selMEM_PC, selIMM_PC, selIN_ADR, selIR_ADR, selPC_ADR,
  selAC_MEM, selIMM_AC, selMEM_AC, selARU_AC, selLGU_AC, conOF,
  SE12bits, SE4bits, AND_LGU, NOT_LGU, ADD, MUL, selSET_SR, selINC_IN,
  INC1, INC2, selARU_SR, selLGU_SR, selIN_MEM, selPC_MEM, LSB0E : STD_LOGIC;
 
  SIGNAL selInt_MEM,INC0,selInt_PC,ld_counter ,selSR_MEM,selMEM_OF,selMEM_SR,ldINTRP,clr2,clr1,completeR4,sel0,selc : STD_LOGIC;
  SIGNAL selofout, self : STD_LOGIC;


  SIGNAL seladdrBus : STD_LOGIC;

  SIGNAL flag1, flag2        : STD_LOGIC_VECTOR(0 DOWNTO 0);
BEGIN
  Datapath_inst : ENTITY work.Datapath (rtl)
    PORT MAP(
      clk        => clk,
      rst        => rst,
      dataBus    => dataBus,
      AND_LGU    => AND_LGU,
      NOT_LGU    => NOT_LGU,
      SHF        => SHF,
      ADD        => ADD,
      MUL        => MUL,
      sel1_ARU   => sel1_ARU,
      selIMM_LGU => selIMM_LGU,
      selMEM_LGU => selMEM_LGU,
      ldAC       => ldAC,
      zeroAC     => zeroAC,
      selIMM_AC  => selIMM_AC,
      selMEM_AC  => selMEM_AC,
      selARU_AC  => selARU_AC,
      selLGU_AC  => selLGU_AC,
      ldPC       => ldPC,
      selINC_PC  => selINC_PC,
      selMEM_PC  => selMEM_PC,
      selIMM_PC  => selIMM_PC,
      ldIN       => ldIN,
      selINC_IN  => selINC_IN,
      selMEM_IN  => selMEM_IN,
      conOF      => conOF,
      SE12bits   => SE12bits,
      SE4bits    => SE4bits,
      ldIR       => ldIR,
      ldOF       => ldOF,
      selPC_OF   => selPC_OF,
      selIMM_OF  => selIMM_OF,
      selIN_ADR  => selIN_ADR,
      selPC_ADR  => selPC_ADR,
      selAC_MEM  => selAC_MEM,
      selIR_ADR  => selIR_ADR,
      seldataBus => seldataBus,
      INC1       => INC1,
      INC2       => INC2,
      ldSR       => ldSR,
      selSET_SR  => selSET_SR,
      selLGU_SR  => selLGU_SR,
      selARU_SR  => selARU_SR,
      enSKP      => enSKP,
      addrBus    => addrBus,
      IRout      => inst,
      selMO_ARU  => selMO_ARU,
      selIN_MEM  => selIN_MEM,
      selPC_MEM  => selPC_MEM,
      LSB0E      => LSB0E,

      selInt_MEM => selInt_MEM,
      INC0 => INC0,
      sel0 => sel0, 
      selc =>selc,
      selInt_PC => selInt_PC,
      ld_counter => ld_counter,
      selSR_MEM => selSR_MEM,
      selMEM_OF => selMEM_OF,
      selMEM_SR => selMEM_SR,
      ldINTRP => ldINTRP,
      clr2 => clr2,
      clr1 => clr1,
      completeR4 => completeR4,
      in_intrp => in_intrp,
      flag1 => flag1,
      flag2 => flag2,
      selofout=>selofout,
      self=>self,


      seladdrBus=>seladdrBus
    );

  Controller_inst : ENTITY work.Controller (ctrl)
    PORT MAP(
      clk        => clk,
      rst        => rst,
      enSKP      => enSKP,
      inst       => inst,
      ldIR       => ldIR,
      ldOF       => ldOF,
      ldPC       => ldPC,
      ldIN       => ldIN,
      ldAC       => ldAC,
      zeroAC     => zeroAC,
      seldataBus => seldataBus,
      selPC_OF   => selPC_OF,
      selIMM_OF  => selIMM_OF,
      selINC_IN  => selINC_IN,
      selMEM_IN  => selMEM_IN,
      selIMM_LGU => selIMM_LGU,
      selMEM_LGU => selMEM_LGU,
      sel1_ARU   => sel1_ARU,
      selMO_ARU  => selMO_ARU,
      selINC_PC  => selINC_PC,
      selMEM_PC  => selMEM_PC,
      selIMM_PC  => selIMM_PC,
      selIN_ADR  => selIN_ADR,
      selIR_ADR  => selIR_ADR,
      selPC_ADR  => selPC_ADR,
      selAC_MEM  => selAC_MEM,
      selIMM_AC  => selIMM_AC,
      selMEM_AC  => selMEM_AC,
      selARU_AC  => selARU_AC,
      selLGU_AC  => selLGU_AC,
      conOF      => conOF,
      SE12bits   => SE12bits,
      SE4bits    => SE4bits,
      AND_LGU    => AND_LGU,
      NOT_LGU    => NOT_LGU,
      ADD        => ADD,
      MUL        => MUL,
      readMEM    => readMEM,
      writeMEM   => writeMEM,
      selSET_SR  => selSET_SR,
      INC1       => INC1,
      INC2       => INC2,
      selARU_SR  => selARU_SR,
      selLGU_SR  => selLGU_SR,
      selIN_MEM  => selIN_MEM,
      selPC_MEM  => selPC_MEM,
      LSB0E      => LSB0E,
      SHF        => SHF,
      ldSR       => ldSR,

      selInt_MEM =>selInt_MEM,
      INC0 =>INC0,
      selInt_PC=>selInt_PC,
      ld_counter=>ld_counter,
      selSR_MEM=>selSR_MEM,
      selMEM_OF=>selMEM_OF,
      selMEM_SR=>selMEM_SR,
      ldINTRP=>ldINTRP,
      clr2=>clr2,
      clr1=>clr1,
      completeR4=>completeR4,
      in_intrp=>in_intrp,
      flag1=>flag1,
      flag2=>flag2,
      sel0 => sel0, 
      selc =>selc,
      selofout=>selofout,
      self=>self,

      seladdrBus=>seladdrBus,
      CPU_ACK =>CPU_ACK,
      CPU_REQ => CPU_REQ
    );
END ARCHITECTURE;
