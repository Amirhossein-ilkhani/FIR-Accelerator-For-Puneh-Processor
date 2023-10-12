LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
use ieee.std_logic_1164.STD_LOGIC;
USE IEEE.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY Controller IS 
   
	PORT(
		clk, rst, enSKP : IN STD_LOGIC;
		inst  : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		ldIR, ldOF, ldPC, ldIN, ldAC, zeroAC, seldataBus, selPC_OF,
	    selIMM_OF, selINC_IN, selMEM_IN, selIMM_LGU, selMEM_LGU, sel1_ARU,
		selMO_ARU, selINC_PC, selMEM_PC, selIMM_PC, selIN_ADR, selIR_ADR,
		selPC_ADR, selAC_MEM, selIMM_AC, selMEM_AC, selARU_AC, selLGU_AC,
		conOF, SE12bits, SE4bits, AND_LGU, NOT_LGU, ADD, MUL, readMEM, writeMEM,
		selSET_SR, INC1, INC2, selARU_SR, selLGU_SR,selIN_MEM, selPC_MEM, LSB0E : OUT STD_LOGIC;

		selInt_MEM,clear_counter,INC0,selInt_PC,ld_counter,
		selSR_MEM, selMEM_OF, selMEM_SR, ldINTRP,
		clr2, clr1, sel0, selc: OUT STD_LOGIC;
		selofout, self: OUT STD_LOGIC;
		completeR4					  : IN STD_LOGIC;
		in_intrp, flag1, flag2        : IN std_logic_vector(0 DOWNTO 0);

		SHF   : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		ldSR  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		

		seladdrBus : OUT std_logic;
		CPU_ACK : IN std_logic;
		CPU_REQ :OUT std_logic
		);		
END Controller;
	
ARCHITECTURE ctrl OF Controller IS
    CONSTANT  LDm		    : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0000";
	CONSTANT  LDa		    : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0001";
	CONSTANT  LDn		    : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0010";
	CONSTANT  STa		    : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0011";
	CONSTANT  STn		    : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0100";
	CONSTANT  INa		    : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0101";
	CONSTANT  ANm		    : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0110";
	CONSTANT  ANa		    : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0111";
	CONSTANT  ADm		    : STD_LOGIC_VECTOR (3 DOWNTO 0):= "1000";
	CONSTANT  ADa		    : STD_LOGIC_VECTOR (3 DOWNTO 0):= "1001";
	CONSTANT  ADn		    : STD_LOGIC_VECTOR (3 DOWNTO 0):= "1010";
	CONSTANT  MLa		    : STD_LOGIC_VECTOR (3 DOWNTO 0):= "1011";
	CONSTANT  JMa		    : STD_LOGIC_VECTOR (3 DOWNTO 0):= "1100";
	CONSTANT  JMn   	    : STD_LOGIC_VECTOR (3 DOWNTO 0):= "1101";
	CONSTANT  JSR    		: STD_LOGIC_VECTOR (3 DOWNTO 0):= "1110";
	CONSTANT  INST15        : STD_LOGIC_VECTOR (3 DOWNTO 0):= "1111";
	CONSTANT  TYPE1         : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0000";
	CONSTANT  LOm           : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0001";
	CONSTANT  SRA_LGU       : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0010";
	CONSTANT  SRL_LGU       : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0011";
	CONSTANT  SLL_LGU       : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0100";
	CONSTANT  SKP           : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0101";
	CONSTANT  SET           : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0110";
	CONSTANT  LPO           : STD_LOGIC_VECTOR (7 DOWNTO 0):= "00000000";
	CONSTANT  LOP           : STD_LOGIC_VECTOR (7 DOWNTO 0):= "00000001";
	CONSTANT  ACZ           : STD_LOGIC_VECTOR (7 DOWNTO 0):= "00000010";
	CONSTANT  ACN           : STD_LOGIC_VECTOR (7 DOWNTO 0):= "00000011";
	CONSTANT  ACI           : STD_LOGIC_VECTOR (7 DOWNTO 0):= "00000100";

	CONSTANT  EIN           : STD_LOGIC_VECTOR (3 DOWNTO 0):= "0111";
	CONSTANT  SIC           : STD_LOGIC_VECTOR (3 DOWNTO 0):= "1000";
	CONSTANT  RIC           : STD_LOGIC_VECTOR (3 DOWNTO 0):= "1001";

	TYPE state IS (fetch, exec1, exec2, save_pc, exec3, exec4);
	SIGNAL pstate, nstate : state;
	
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			pstate <= fetch;
		ELSIF clk = '1' AND clk'EVENT THEN
			pstate <= nstate;
		END IF;
	END PROCESS;
	
	PROCESS (pstate, inst, in_intrp, CPU_ACK) BEGIN 
	    ldSR <= "0000"; ldIR <= '0'; ldOF <= '0'; ldPC <= '0'; 
		ldIN <= '0'; ldAC <= '0'; zeroAC <= '0'; seldataBus <= '0';
		selPC_OF <= '0'; selIMM_OF <= '0';  selINC_IN <= '0'; selMEM_IN <= '0';
		selIMM_LGU <= '0'; selMEM_LGU <= '0'; sel1_ARU <= '0'; selMO_ARU <= '0';
		selINC_PC <= '0'; selMEM_PC <= '0'; selIMM_PC <= '0'; selIN_ADR <= '0'; 
		selIR_ADR <= '0'; selPC_ADR <= '0';  selAC_MEM <= '0';  selIMM_AC <= '0'; 
		selMEM_AC <= '0'; selARU_AC <= '0';  selLGU_AC <= '0'; conOF <= '0'; 
		SE12bits <= '0';  SE4bits <= '0';  AND_LGU <= '0';  NOT_LGU <= '0';  
		SHF <= "00"; ADD <= '0';  MUL <= '0';  readMEM <= '0'; sel0<='0';
		writeMEM <= '0'; INC1 <= '0';  INC2 <= '0'; 
		selSET_SR <= '0'; selARU_SR <= '0'; selLGU_SR <= '0';
		selIN_MEM <= '0'; selPC_MEM <= '0'; LSB0E <= '0';CPU_REQ<='0';seladdrbus <= '0';


		selInt_MEM	<='0';INC0<='0';
		selInt_PC <='0';selSR_MEM<='0';
		ldINTRP<='0';clr2 <='0';
		clr1<='0'; ld_counter<='0';

		CASE pstate IS  
			WHEN fetch =>

			IF(CPU_ACK = '1') THEN seladdrbus <= '1';readMEM <= '1'; END IF;
			CPU_REQ<='1';
			--
				 selPC_ADR <= '1';	ldIR <= '1'; 
				 ld_counter<='1';

				 IF (in_intrp ="1" AND flag1="0") THEN
				 ldINTRP <='1'; 
				 ELSE 
				 ldINTRP <='0';
				 END IF;
 
			WHEN save_pc =>

			IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
			CPU_REQ<='1';
			--
				selInt_MEM	<='1';  writeMEM<='1';INC0<='1';
				selPC_MEM<='1';sel0 <= '1';
				selInt_PC <='1';ldPC <= '1';


			IF(CPU_ACK = '1') THEN seldataBus <= '1'; END IF;
			CPU_REQ<='1';

				clr2 <='1';

			WHEN exec1 =>
    			CASE inst(15 downto 12) IS
                	WHEN LDm =>
						SE4bits <= '1';  selIMM_AC <= '1';  ldAC <= '1'; 
					    INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
				    WHEN LDa =>

					IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
					CPU_REQ<='1';
					
						conOF <= '1';  selIR_ADR <= '1';  readMEM <= '1';
					    selMEM_AC <= '1';  ldAC <= '1'; 
					    INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';						
					WHEN LDn =>
					
					IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
					CPU_REQ<='1';
					
						conOF <= '1';  selIR_ADR <= '1';  readMEM <= '1';
					    selMEM_IN <= '1';  ldIN <= '1';			
			        WHEN STa =>
					
					IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
					CPU_REQ<='1';
					
						conOF <= '1';  selIR_ADR <= '1';  selAC_MEM <= '1';
						  writeMEM <= '1'; 
						INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
						IF(CPU_ACK = '1') THEN seldataBus <= '1'; END IF;	
						CPU_REQ<='1';
					WHEN STn =>
					
					IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
					CPU_REQ<='1';
					
						conOF <= '1';  selIR_ADR <= '1';  readMEM <= '1';
						selMEM_IN <= '1';  ldIN <= '1';	
				    WHEN INa =>
					
					IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
					CPU_REQ<='1';
					
						conOF <= '1';  selIR_ADR <= '1';  readMEM <= '1'; 
						selINC_IN <= '1';  ldIN <= '1';							
					WHEN ANm =>
						SE4bits	<= '1';  selIMM_LGU <= '1';  AND_LGU <= '1';
						selLGU_AC <= '1';  ldAC <= '1';  
						selLGU_SR <= '1';  ldSR <= "1100";
						INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';			
			        WHEN ANa =>
					
					IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
					CPU_REQ<='1';
					
						conOF <= '1';  selIR_ADR <= '1';  readMEM <= '1'; 
						selMEM_LGU <= '1';  AND_LGU <= '1';  selLGU_AC <= '1'; ldAC <= '1';  
						selLGU_SR <= '1';  ldSR <= "1100";	
						INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
				    WHEN ADm =>
						SE4bits	<= '1';  selIMM_LGU <= '1';  selMO_ARU <= '1';
						ADD	<= '1';  selARU_AC <= '1';  ldAC <= '1';	
						selARU_SR <= '1';  ldSR <= "1111"; 
						INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
				    WHEN ADa =>
					
					IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
					CPU_REQ<='1';
					
						conOF <= '1';  selIR_ADR <= '1';  readMEM <= '1'; 
						selMEM_LGU <= '1';  selMO_ARU <= '1';  ADD <= '1'; 
						selARU_AC <= '1';  ldAC <= '1';  
						selARU_SR <= '1';  ldSR <= "1111";
						INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';						
					WHEN ADn =>
					
					IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
					CPU_REQ<='1';
					
						conOF <= '1';  selIR_ADR <= '1';  readMEM <= '1';
						selMEM_IN <= '1';  ldIN <= '1';				
			        WHEN MLa =>
					
					IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
					CPU_REQ<='1';

						conOF <= '1';  selIR_ADR <= '1';  readMEM <= '1';
						selMEM_LGU <= '1';  selMO_ARU <= '1'; 

					WHEN JMa =>
						IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
						CPU_REQ<='1';
						conOF <= '1';  selIMM_PC <= '1';  ldPC <= '1';
					WHEN JMn =>

					IF (inst(11 downto 0) = "111111110000") THEN 
								self<= '1'; 
						ELSE
							selofout<='1'; 
						end if;
						
						IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
						CPU_REQ<='1';

						conOF <= '1';  selIR_ADR <= '1';  readMEM <= '1';
						selMEM_PC <= '1';  ldPC <= '1'; 
					WHEN JSR =>
					
					IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
					CPU_REQ<='1';
					
						conOF <= '1';  selIR_ADR <= '1';  INC1 <= '1';
						selPC_MEM <= '1';  IF(CPU_ACK = '1') THEN seldataBus <= '1'; END IF;   
						writeMEM <= '1';  selIMM_PC <= '1';  ldPC <= '1';
					WHEN INST15 =>
					    CASE inst(11 downto 8) IS
                	        WHEN TYPE1 =>
							    CASE inst(7 downto 0) IS
								    WHEN LPO =>
										selPC_OF <= '1';  ldOF  <= '1';  
										INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
									WHEN LOP =>
										LSB0E <= '1';  selIMM_PC <= '1';  ldPC <= '1'; 
									WHEN ACZ =>
										IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
										CPU_REQ<='1';
										zeroAC <= '1';  
										selLGU_SR <= '1';  ldSR <= "1100";
										INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
									WHEN ACN =>
										NOT_LGU <= '1';  selLGU_AC <= '1';  ldAC <= '1'; 
										selLGU_SR <= '1';  ldSR <= "1100"; 
										INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
									WHEN ACI =>
										sel1_ARU <= '1';  ADD <= '1';
										selARU_AC <= '1';  ldAC <= '1'; 
										INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
									WHEN OTHERS =>
										INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
					            END CASE;
							WHEN LOm =>
								SE12bits <= '1';  selIMM_OF <= '1';  ldOF <= '1';
						        INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
							WHEN SRA_LGU =>	
							    SE12bits <= '1';  selIMM_LGU <= '1';	SHF <= "00";
								selLGU_AC <= '1';  ldAC <= '1';
								INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
							WHEN SRL_LGU =>
								SE12bits <= '1';  selIMM_LGU <= '1';  SHF <= "01";
								selLGU_AC <= '1';  ldAC <= '1';
								INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1'; 
							WHEN SLL_LGU =>
							    SE12bits <= '1';  selIMM_LGU <= '1';  SHF <= "10";
								selLGU_AC <= '1';  ldAC <= '1';
								INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
							WHEN SKP =>
							    IF (enSKP = '1') THEN 
								    INC2 <= '1'; 
						        ELSE
									INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
					            end if;
							WHEN SET =>
							    selSET_SR <= '1';  ldSR <= inst (7 downto 4);
								INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';

							
							WHEN SIC=>
							selAC_MEM<='1';	
							IF(CPU_ACK = '1') THEN seldataBus <= '1'; END IF;
							CPU_REQ<='1';
							
							IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
							CPU_REQ<='1';
							
							selInt_MEM<='1';writeMEM <= '1';ldAC<='1';	
							selc<='1';
							
							WHEN RIC=>
							
							IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
							CPU_REQ<='1';
							
							readMEM <= '1';ldAC<='1';selMEM_AC <= '1';selInt_MEM<='1';
							selc<='1';
							
							IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
							CPU_REQ<='1';
							
							WHEN EIN=>
							clr1<='1'; 
							INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
							
							WHEN OTHERS =>
							INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
				        END CASE;
					WHEN OTHERS =>	
				        INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
				END CASE;
			WHEN exec2 =>	
			    CASE inst(15 downto 12) IS
                	WHEN LDn =>
						
						IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
						CPU_REQ<='1';
						
						selIN_ADR <= '1';  readMEM <= '1';  
						selMEM_AC <= '1'; ldAC <= '1';
						INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
				    WHEN STn =>
					
					IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
					CPU_REQ<='1';
					
						selIN_ADR <= '1';  selAC_MEM <= '1'; 
						IF(CPU_ACK = '1') THEN seldataBus <= '1'; END IF;
						CPU_REQ<='1';
						writeMEM <= '1';  
						INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
                    WHEN INa =>
					
					IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
					CPU_REQ<='1';
					
						conOF <= '1';  selIR_ADR <= '1';  selIN_MEM <= '1';
						IF(CPU_ACK = '1') THEN seldataBus <= '1'; END IF;
						CPU_REQ<='1';
						writeMEM <= '1';	
						INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
				    WHEN ADn =>
					
					IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
					CPU_REQ<='1';
					
						selIN_ADR <= '1';  readMEM <= '1';  selMEM_LGU <= '1';
						selMO_ARU <= '1';  ADD <= '1';  selARU_AC <= '1';  ldAC <= '1';
						selARU_SR <= '1';  ldSR <= "1111";
						INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
				    WHEN JSR =>
						INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
					
					
					WHEN MLa =>
					
					IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
					CPU_REQ<='1';
					
						MUL <= '1';
						conOF <= '1';  selIR_ADR <= '1';  readMEM <= '1';
						selMEM_LGU <= '1';  selMO_ARU <= '1'; 

					
					WHEN INST15 =>
						CASE inst(11 downto 8) IS
					
							WHEN SIC=>
							LSB0E<='1';selIMM_AC<='1';writeMEM <= '1';selAC_MEM<='1';
							
							IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
							CPU_REQ<='1';
						
							IF(CPU_ACK = '1') THEN seldataBus <= '1'; END IF;
							
							selInt_MEM<='1';
							selc<='1';
					 
							WHEN RIC=>
							
							IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
							CPU_REQ<='1';
							
							readMEM <= '1';selInt_MEM<='1';selMEM_OF<='1';ldOF<='1';
							selc<='1';	
                    WHEN OTHERS =>
					    INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';
						END CASE;
						
					WHEN OTHERS =>
					
                END CASE;

			
			WHEN exec3 =>
				CASE inst(15 downto 12) IS
					
					WHEN MLa =>
					selARU_AC <= '1';  ldAC <= '1';
					selARU_SR <= '1';  ldSR <= "1000"; 
					INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';

					WHEN INST15 =>
					CASE inst(11 downto 8) IS
					
						WHEN SIC=>
						
						IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
						CPU_REQ<='1';
						
							selIN_MEM<='1';selInt_MEM<='1';
							IF(CPU_ACK = '1') THEN seldataBus <= '1'; END IF;
							CPU_REQ<='1';
							writeMEM <= '1';	
							selc<='1';
					 
						WHEN RIC=>
						
						IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
						CPU_REQ<='1';
						
						readMEM <= '1';selInt_MEM<='1';selMEM_IN<='1';ldIN<='1';
						selc<='1';
						WHEN OTHERS =>
					END CASE;
					WHEN OTHERS =>
				END CASE;

			
			WHEN exec4 =>
				CASE inst(15 downto 12) IS
				WHEN INST15 =>
					CASE inst(11 downto 8) IS
					
						WHEN SIC=>
							selSR_MEM<='1';selInt_MEM<='1';
							IF(CPU_ACK = '1') THEN seldataBus <= '1'; END IF;
							CPU_REQ<='1';
							writeMEM <= '1';	
							selc<='1';
							INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';	
					
						WHEN RIC=>
						
						IF(CPU_ACK = '1') THEN seladdrbus <= '1'; END IF;
						CPU_REQ<='1';
						
						readMEM <= '1';selInt_MEM<='1';selMEM_SR<='1';ldSR<="1111";
						selc<='1'; 
						INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';	
						WHEN OTHERS =>
							INC1 <= '1';  selINC_PC <= '1';  ldPC <= '1';	
					END CASE;
					WHEN OTHERS =>
				END CASE;
				
			
            END CASE;				
	END PROCESS;

	PROCESS (pstate, inst, completeR4) BEGIN 		
	    CASE pstate IS  
			WHEN fetch =>	
				IF ( rst = '1') THEN 
					nstate <= fetch;

				ELSIF (flag1="1"  AND flag2 = "1") THEN
					nstate <= save_pc;
				ELSE
					nstate <= exec1;
				END IF; 

		WHEN save_pc =>	

				nstate <= fetch;	
						 					   
			WHEN exec1 =>
                CASE inst(15 downto 12) IS  
		         	WHEN LDm =>			
					    nstate <= fetch;
					WHEN LDa =>
						IF(CPU_ACK = '1') THEN	nstate <= fetch; ELSE nstate <= exec1;END IF;					
					WHEN LDn =>
						IF(CPU_ACK = '1')THEN	nstate <= exec2;  ELSE nstate <= exec1;END IF;	
					WHEN STa =>
						IF(CPU_ACK = '1')THEN	nstate <= fetch;  ELSE nstate <= exec1;END IF;		
					WHEN STn =>
						IF(CPU_ACK = '1')THEN	nstate <= exec2;  ELSE nstate <= exec1;END IF;	
					WHEN INa =>
						IF(CPU_ACK = '1')THEN	nstate <= exec2;  ELSE nstate <= exec1;END IF;
					WHEN ANm =>
						nstate <= fetch;	
					WHEN ANa =>
						IF(CPU_ACK = '1')THEN	nstate <= fetch;  ELSE nstate <= exec1;END IF;		
					WHEN ADm =>
						nstate <= fetch;	
					WHEN ADa =>
						IF(CPU_ACK = '1')THEN	nstate <= fetch;  ELSE nstate <= exec1;END IF;	
					WHEN ADn =>
						IF(CPU_ACK = '1')THEN	nstate <= exec2;  ELSE nstate <= exec1;END IF;	
                    WHEN MLa =>
						IF(CPU_ACK = '1')THEN	nstate <= exec2;  ELSE nstate <= exec1;END IF;	
					WHEN JMa =>
					
						IF(CPU_ACK = '1')THEN	nstate <= fetch;  ELSE nstate <= exec1;END IF;	
					WHEN JMn =>
						IF(CPU_ACK = '1')THEN	nstate <= fetch;  ELSE nstate <= exec1;END IF;	
					WHEN JSR =>
						IF(CPU_ACK = '1')THEN	nstate <= exec2; ELSE nstate <= exec1;END IF;	
					WHEN INST15 =>

						CASE inst(11 downto 8) IS
							WHEN SIC=>
							IF(CPU_ACK = '1')THEN	nstate <= exec2; ELSE nstate <= exec1;END IF;	
							WHEN RIC=>
							IF(CPU_ACK = '1')THEN	nstate <= exec2; ELSE nstate <= exec1;END IF;	
							WHEN OTHERS =>
								nstate <= fetch;
								END CASE;

						
					WHEN OTHERS =>	
						nstate <= fetch;		
		        END CASE;

			WHEN exec2 =>
				CASE inst(15 downto 12) IS
					WHEN LDn =>
					IF(CPU_ACK = '1')THEN	nstate <= fetch;  ELSE nstate <= exec2;END IF;	
					WHEN STn =>
					IF(CPU_ACK = '1')THEN	nstate <= fetch;  ELSE nstate <= exec2;END IF;	
					WHEN INa =>
					IF(CPU_ACK = '1')THEN	nstate <= fetch;  ELSE nstate <= exec2;END IF;	
					WHEN ADn =>
						nstate <= fetch;
					WHEN JSR =>
						nstate <= fetch;


					WHEN MLa =>
					IF(CPU_ACK = '1')THEN	
						IF(completeR4='1') THEN
							nstate <= exec3;
						ELSE
						 	nstate <= exec2;
						END IF;
					ELSE nstate <= exec2;END IF;	

					WHEN INST15 =>
						CASE inst(11 downto 8) IS
							WHEN SIC=>
							IF(CPU_ACK = '1')THEN	nstate <= exec3;  ELSE nstate <= exec2;END IF;
								
							WHEN RIC=>
							IF(CPU_ACK = '1')THEN	nstate <= exec3;  ELSE nstate <= exec2;END IF;
								
							WHEN OTHERS =>
								nstate <= fetch;
						END CASE;		
				WHEN OTHERS =>	
				nstate <= fetch;	
			END CASE;
	

			WHEN exec3 =>
				CASE inst(15 downto 12) IS
				WHEN MLa =>
					nstate <= fetch;

				WHEN INST15 =>
					CASE inst(11 downto 8) IS
						WHEN SIC=>
						IF(CPU_ACK = '1')THEN	nstate <= exec4;  ELSE nstate <= exec3;END IF;	
						WHEN RIC=>
						IF(CPU_ACK = '1')THEN	nstate <= exec4;  ELSE nstate <= exec3;END IF;
						WHEN OTHERS =>	
						nstate <= fetch;
					END CASE;
					WHEN OTHERS =>
						nstate <= fetch;
				END CASE;

			WHEN exec4 =>
				CASE inst(15 downto 12) IS
				WHEN INST15 =>

					CASE inst(11 downto 8) IS
						WHEN SIC=>
						IF(CPU_ACK = '1')THEN	nstate <= fetch;  ELSE nstate <= exec4;END IF;
						WHEN RIC=>
						IF(CPU_ACK = '1')THEN	nstate <= fetch;  ELSE nstate <= exec4;END IF;
						WHEN OTHERS =>
							nstate <= fetch;	
					END CASE;
					WHEN OTHERS =>
						nstate <= fetch;
				END CASE;

			WHEN OTHERS =>	
			nstate <= fetch;	
		END CASE;
	END PROCESS;
END ctrl;

