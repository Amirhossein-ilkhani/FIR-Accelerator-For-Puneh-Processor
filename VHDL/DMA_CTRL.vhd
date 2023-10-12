library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY DMA_CTRL IS 
PORT(
    clk ,rst : IN std_logic;
    seldatabus ,sel_addbus : OUT std_logic;
    eq_g ,eq_s : IN std_logic;
    go_flag : IN std_logic;
    active_read : IN std_logic;
    active_write : IN std_logic;
    DMA_grant : IN std_logic;
    clr_g ,clr_s : OUT std_logic;
    DMA_req : OUT std_logic;
    INw : OUT std_logic;
    en : OUT std_logic;
    in_full ,out_full : OUT std_logic;
    write_num : OUT std_logic;
    mem_read : OUT std_logic;
    mem_write : OUT std_logic;
    out_complete : OUT std_logic;
    firComplete : IN std_logic
    );

END ENTITY DMA_CTRL;

ARCHITECTURE rtl OF DMA_CTRL IS

TYPE state IS (wait_state, grant_read, read_stste, ralease_r, end_read, grant_write, write_state, release_w, end_w ,fir_comp);
SIGNAL pstate, nstate : state;
BEGIN
NEXT_STATE : PROCESS (clk , rst)
    BEGIN
        IF rst = '1' THEN
            pstate<= wait_state;
        ELSIF clk = '1' AND clk'EVENT THEN 
            pstate <= nstate;
        END IF;
    END PROCESS;

STATE_TRANSITION: PROCESS (pstate ,eq_g ,eq_s ,DMA_grant ,go_flag , active_read , active_write ,firComplete) BEGIN
    nstate<=wait_state;
    CASE pstate IS
        WHEN wait_state =>
            IF (go_flag = '0' AND fircomplete = '0') THEN 
                nstate <= wait_state;
            ELSIF (go_flag = '0' AND fircomplete = '1') THEN 
                nstate <= fir_comp;
            ELSIF (go_flag = '1' AND active_read = '1') THEN
                nstate <= grant_read;
            ELSIF (go_flag = '1' AND active_write = '1') THEN
                nstate <= grant_write;
            END IF ;
            
        WHEN grant_read =>
            if DMA_grant = '1' then
                nstate <= read_stste;
            else
                nstate <= grant_read;
            end if;

        WHEN read_stste =>
            if eq_s = '0' AND eq_g = '0' then
                nstate <= read_stste;
            ELSIF eq_s = '1' AND eq_g = '0' then
                nstate <= ralease_r;
            ELSIF eq_g = '1' then
                nstate <= end_read;
            end if;

        WHEN ralease_r =>
                    nstate <= grant_read;

        WHEN end_read =>
            IF (go_flag = '1') THEN 
                nstate <= end_read;
            ELSE
                nstate <= wait_state;
            END IF ;

        WHEN grant_write =>
                if DMA_grant = '1' then
                    nstate <= write_state;
                else 
                    nstate <= grant_write;
                end if;

        WHEN write_state => 
            if eq_s = '0' AND eq_g = '0' then
                nstate <= write_state;
            ELSIF eq_s = '1' AND eq_g = '0' then
                nstate <= release_w;
            ELSIF eq_g = '1' then
                nstate <= end_w;
            end if;

        WHEN release_w =>
            nstate <= grant_write;
        
        WHEN end_w =>
            IF (go_flag = '1') THEN 
                nstate <= end_w;
            ELSE
                nstate <= wait_state;
            END IF ;

        WHEN fir_comp =>
                IF (go_flag = '0') THEN
                    nstate <= fir_comp;
                ELSE 
                    nstate <= wait_state;
                END IF;
        
    END CASE;
    END PROCESS;

    OUTPUTS:   PROCESS (pstate) BEGIN
    clr_g <= '0';
    clr_s <= '0';
    DMA_req <= '0';
    en <= '0';
    en <= '0';
    INw <= '0';
    out_full <= '0';
    in_full <= '0';
    write_num <= '0';
    seldatabus <= '0';
    sel_addbus <= '0';
    mem_read <= '0';
    mem_write <= '0';
    out_complete <= '0';

    CASE pstate IS
        
        WHEN wait_state =>
            clr_g <= '1';
            clr_s <= '1';

        WHEN grant_read =>
            DMA_req <= '1';
            write_num <= '1';

        WHEN read_stste =>
            DMA_req <= '1';
            en <= '1';
            INw <= '1';
            mem_read <= '1';
            sel_addbus <= '1';
        
        WHEN ralease_r =>
            DMA_req <= '0';

        WHEN end_read =>
            in_full <= '1';

        WHEN grant_write =>
            DMA_req <= '1';
            write_num <= '1';

        WHEN write_state =>
            DMA_req <= '1';
            en <= '1';
            seldatabus <= '1';
            sel_addbus <= '1';
            mem_write <= '1';

        WHEN release_w =>
            DMA_req <= '0';

        WHEN end_w =>
            DMA_req <= '0';
            out_complete <= '1';
            
        WHEN fir_comp =>
            out_full <= '1';

    END CASE;
    END PROCESS;
END ARCHITECTURE;
