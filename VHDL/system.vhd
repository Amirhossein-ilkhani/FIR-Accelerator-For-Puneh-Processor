library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity system is
   port ( clkin : in    std_logic; 
          rstin : in    std_logic);
end system;

architecture BEHAVIORAL of system is
   signal AddFromDMA  : std_logic_vector (6 downto 0);
   signal addressBUS  : std_logic_vector (15 downto 0);
   signal AddToDMA    : std_logic_vector (6 downto 0);
   signal cpu_grant   : std_logic;
   signal cpu_req     : std_logic;
   signal dataBUS     : std_logic_vector (15 downto 0);
   signal DataToDMA   : std_logic_vector (15 downto 0);
   signal DataToFir   : std_logic_vector (15 downto 0);
   signal dma_grant   : std_logic;
   signal dma_req     : std_logic;
   signal FirComplete : std_logic;
   signal infully     : std_logic;
   signal interrupt   : std_logic;
   signal NUMToFIR    : std_logic_vector (15 downto 0);
   signal outcomplete : std_logic;
   signal outfully    : std_logic;
   signal readmem     : std_logic;
   signal writemem    : std_logic;
   signal writenum    : std_logic;
   signal WriteToDMA  : std_logic;
   signal writetoFIR  : std_logic;
   signal orreadmem,orwritemem,readmemdma,writememdma,readmemcpu,writememcpu :
   std_logic;

   component PUNEH
      port ( clk      : in    std_logic; 
             rst      : in    std_logic; 
             CPU_ACK  : in    std_logic; 
             in_intrp : in    std_logic_vector (0 downto 0); 
             writeMEM : out   std_logic; 
             readMEM  : out   std_logic; 
             CPU_REQ  : out   std_logic; 
             addrBus  : out   std_logic_vector (15 downto 0); 
             dataBus  : inout std_logic_vector (15 downto 0));
   end component;
   
   component MEMORY
      port ( clk      : in    std_logic; 
             rst      : in    std_logic; 
             readMem  : in    std_logic; 
             writeMem : in    std_logic; 
             addrBus  : in    std_logic_vector (15 downto 0); 
             dataBus  : inout std_logic_vector (15 downto 0));
   end component;
   
   component FIR_TOP
      port ( clk          : in    std_logic; 
             r            : in    std_logic; 
             writeNUM     : in    std_logic; 
             writetoFIR   : in    std_logic; 
             databus      : in    std_logic_vector (15 downto 0); 
             addbus       : in    std_logic_vector (15 downto 0); 
             DataToFir    : in    std_logic_vector (15 downto 0); 
             NUMToFir     : in    std_logic_vector (15 downto 0); 
             AddFromDMA   : in    std_logic_vector (6 downto 0); 
             WriteToDMA   : out   std_logic; 
             FirCompelete : out   std_logic; 
             DataToDMA    : out   std_logic_vector (15 downto 0); 
             AddToDMA     : out   std_logic_vector (6 downto 0));
   end component;
   
   component Arbiter
      port ( clk       : in    std_logic; 
             rst       : in    std_logic; 
             dma_req   : in    std_logic; 
             puneh_req : in    std_logic; 
             dma_ack   : out   std_logic; 
             puneh_ack : out   std_logic);
   end component;
   
   component PIC
      port ( IR1     : in    std_logic; 
             IR2     : in    std_logic; 
             IR3     : in    std_logic; 
             ADDRBUS : in    std_logic_vector (15 downto 0); 
             INT     : out   std_logic; 
             DATABUS : out   std_logic_vector (15 downto 0));
   end component;

   component DMA_TOP
      port (
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
   end component;
   
begin

    orreadmem <= readmemcpu OR readmemdma;
    orwritemem <= writememcpu OR writememdma;

    puneh_inst : PUNEH
      port map (clk=>clkin,
                CPU_ACK=>cpu_grant,
                in_intrp(0)=>interrupt,
                rst=>rstin,
                addrBus(15 downto 0)=>addressBUS(15 downto 0),
                CPU_REQ=>cpu_req,
                readMEM=>readmemcpu,
                writeMEM=>writememcpu,
                dataBus(15 downto 0)=>dataBUS(15 downto 0));
   
    mem_inst : MEMORY
      port map (addrBus(15 downto 0)=>addressBUS(15 downto 0),
                clk=>clkin,
                readMem=>orreadmem,
                rst=>rstin,
                writeMem=>orwritemem,
                dataBus(15 downto 0)=>dataBUS(15 downto 0));
   
    fir_inst : FIR_TOP
      port map (addbus(15 downto 0)=>addressBUS(15 downto 0),
                AddFromDMA(6 downto 0)=>AddFromDMA(6 downto 0),
                clk=>clkin,
                databus(15 downto 0)=>dataBUS(15 downto 0),
                DataToFir(15 downto 0)=>DataToFir(15 downto 0),
                NUMToFir(15 downto 0)=>NUMToFIR(15 downto 0),
                r=>rstin,
                writeNUM=>writenum,
                writetoFIR=>writetoFIR,
                AddToDMA(6 downto 0)=>AddToDMA(6 downto 0),
                DataToDMA(15 downto 0)=>DataToDMA(15 downto 0),
                FirCompelete=>FirComplete,
                WriteToDMA=>WriteToDMA);
   
   arbiter_inst : Arbiter
      port map (clk=>clkin,
                dma_req=>dma_req,
                puneh_req=>cpu_req,
                rst=>rstin,
                dma_ack=>dma_grant,
                puneh_ack=>cpu_grant);
   
   pic_inst : PIC
      port map (ADDRBUS(15 downto 0)=>addressBUS(15 downto 0),
                IR1=>infully,
                IR2=>outfully,
                IR3=>outcomplete,
                DATABUS(15 downto 0)=>dataBUS(15 downto 0),
                INT=>interrupt);


    DMA_inst : DMA_TOP 
      port map(
        clk => clkin,
        rst => rstin,
        DMA_grant =>dma_grant,
        writetoDMA => WriteToDMA,
        datatoDMA => DataToDMA,
        addrtoDMA => AddToDMA,
        firComplete => FirComplete,
        addrbus => addressBUS,
        databus => dataBUS,
        writetoFIR => writetoFIR,
        DMA_req => dma_req,
        out_full => outfully,
        in_full => infully,
        datatoFIR => DataToFir,
        cnt_g => AddFromDMA,
        write_num => writenum,
        mem_read => readmemdma,
        mem_write => writememdma,
        numOfData => NUMToFIR,
        out_complete => outcomplete
        );

end BEHAVIORAL;


