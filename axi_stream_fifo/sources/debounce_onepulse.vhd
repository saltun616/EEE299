library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce_onepulse is
    generic (
        CLK_FREQ_HZ : integer := 100_000_000; 
        DEBOUNCE_MS : integer := 5             
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        btn_in    : in  std_logic;
        pulse_out : out std_logic              
    );
end entity debounce_onepulse;

architecture rtl of debounce_onepulse is

    constant TICK_MAX : integer := (CLK_FREQ_HZ / 1000) * DEBOUNCE_MS;

    signal sync0, sync1     : std_logic := '0';
    signal stable, stable_d : std_logic := '0';
    signal tick_cnt         : integer range 0 to TICK_MAX := 0;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            sync0 <= btn_in;
            sync1 <= sync0;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                tick_cnt <= 0;
                stable   <= '0';
            elsif sync1 /= stable then
                if tick_cnt = TICK_MAX then
                    stable   <= sync1;
                    tick_cnt <= 0;
                else
                    tick_cnt <= tick_cnt + 1;
                end if;
            else
                tick_cnt <= 0;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                stable_d <= '0';
            else
                stable_d <= stable;
            end if;
        end if;
    end process;

    pulse_out <= stable and (not stable_d);

end architecture rtl;