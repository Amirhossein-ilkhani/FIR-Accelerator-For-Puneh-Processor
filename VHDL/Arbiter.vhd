LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Arbiter IS
    PORT(clk , rst : IN STD_LOGIC;dma_req,puneh_req:IN STD_LOGIC;dma_ack,puneh_ack:OUT STD_LOGIC);
END ENTITY;

ARCHITECTURE Arbiter_arc OF Arbiter IS
SIGNAL puneh_ack_pre,dma_ack_pre,puneh_ack_new,dma_ack_new : STD_LOGIC_VECTOR(0 DOWNTO 0);

BEGIN
puneh_ack_pre(0) <= ((NOT puneh_ack_new(0) AND puneh_req AND (NOT dma_req)) OR (puneh_ack_new(0) AND (NOT dma_ack_new(0)) AND puneh_req));
dma_ack_pre(0) <=((NOT puneh_ack_new(0)) AND dma_req) OR ((NOT dma_ack_new(0)) AND (NOT puneh_req) AND dma_req);

u1 : ENTITY WORK.Reg_P(behaviour) PORT MAP(clk=>clk ,rst=> rst , in_P=> puneh_ack_pre,Out_P=> puneh_ack_new, ld=>'1' ,clr=> '0' );  
u2 : ENTITY WORK.Reg_P(behaviour) PORT MAP(clk=>clk , rst=>rst , in_P=> dma_ack_pre,Out_P=> dma_ack_new, ld=>'1' ,clr=> '0' );

dma_ack<=dma_ack_new(0);
puneh_ack<=puneh_ack_new(0);

END ARCHITECTURE;
