library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    generic (
        CLK_FREQ_HZ : integer := 100_000_000;
        BAUD_RATE   : integer := 115200
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        rx_serial : in  std_logic;
        rx_dv     : out std_logic;                  
        rx_data   : out std_logic_vector(7 downto 0)
    );
end entity uart_rx;

architecture rtl of uart_rx is

    constant CLKS_PER_BIT : integer := CLK_FREQ_HZ / BAUD_RATE;

    type state_t is (S_IDLE, S_START, S_DATA, S_STOP);
    signal state : state_t := S_IDLE;

    signal rx_sync0, rx_sync1 : std_logic := '1';
    signal clk_cnt : integer range 0 to CLKS_PER_BIT-1 := 0;
    signal bit_idx : integer range 0 to 7 := 0;
    signal data_sh : std_logic_vector(7 downto 0) := (others => '0');
    signal dv_i    : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            rx_sync0 <= rx_serial;
            rx_sync1 <= rx_sync0;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state   <= S_IDLE;
                dv_i    <= '0';
                clk_cnt <= 0;
                bit_idx <= 0;
            else
                dv_i <= '0';
                case state is
                    when S_IDLE =>
                        clk_cnt <= 0;
                        bit_idx <= 0;
                        if rx_sync1 = '0' then          
                            state <= S_START;
                        end if;

                    when S_START =>
                        if clk_cnt = (CLKS_PER_BIT-1)/2 then
                            if rx_sync1 = '0' then
                                clk_cnt <= 0;
                                state   <= S_DATA;
                            else
                                state <= S_IDLE;         
                            end if;
                        else
                            clk_cnt <= clk_cnt + 1;
                        end if;

                    when S_DATA =>
                        if clk_cnt = CLKS_PER_BIT-1 then
                            clk_cnt <= 0;
                            data_sh(bit_idx) <= rx_sync1;
                            if bit_idx = 7 then
                                state <= S_STOP;
                            else
                                bit_idx <= bit_idx + 1;
                            end if;
                        else
                            clk_cnt <= clk_cnt + 1;
                        end if;

                    when S_STOP =>
                        if clk_cnt = CLKS_PER_BIT-1 then
                            dv_i  <= '1';
                            state <= S_IDLE;
                        else
                            clk_cnt <= clk_cnt + 1;
                        end if;
                end case;
            end if;
        end if;
    end process;

    rx_dv   <= dv_i;
    rx_data <= data_sh;

end architecture rtl;