library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    generic (
        CLK_FREQ_HZ : integer := 100_000_000;
        BAUD_RATE   : integer := 115200
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        tx_axis_tvalid : in  std_logic;
        tx_axis_tready : out std_logic;
        tx_axis_tdata  : in  std_logic_vector(7 downto 0);

        tx_serial : out std_logic
    );
end entity uart_tx;

architecture rtl of uart_tx is

    constant CLKS_PER_BIT : integer := CLK_FREQ_HZ / BAUD_RATE;

    type state_t is (S_IDLE, S_START, S_DATA, S_STOP);
    signal state : state_t := S_IDLE;

    signal clk_cnt  : integer range 0 to CLKS_PER_BIT-1 := 0;
    signal bit_idx  : integer range 0 to 7 := 0;
    signal data_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_reg   : std_logic := '1';
    signal ready_i  : std_logic := '1';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state   <= S_IDLE;
                tx_reg  <= '1';
                ready_i <= '1';
                clk_cnt <= 0;
                bit_idx <= 0;
            else
                case state is
                    when S_IDLE =>
                        tx_reg  <= '1';                 
                        ready_i <= '1';
                        clk_cnt <= 0;
                        bit_idx <= 0;
                        if tx_axis_tvalid = '1' and ready_i = '1' then
                            data_reg <= tx_axis_tdata;
                            ready_i  <= '0';
                            state    <= S_START;
                        end if;

                    when S_START =>
                        tx_reg <= '0';                  
                        if clk_cnt = CLKS_PER_BIT-1 then
                            clk_cnt <= 0;
                            state   <= S_DATA;
                        else
                            clk_cnt <= clk_cnt + 1;
                        end if;

                    when S_DATA =>
                        tx_reg <= data_reg(bit_idx);     
                        if clk_cnt = CLKS_PER_BIT-1 then
                            clk_cnt <= 0;
                            if bit_idx = 7 then
                                state <= S_STOP;
                            else
                                bit_idx <= bit_idx + 1;
                            end if;
                        else
                            clk_cnt <= clk_cnt + 1;
                        end if;

                    when S_STOP =>
                        tx_reg <= '1';                  
                        if clk_cnt = CLKS_PER_BIT-1 then
                            clk_cnt <= 0;
                            ready_i <= '1';
                            state   <= S_IDLE;
                        else
                            clk_cnt <= clk_cnt + 1;
                        end if;
                end case;
            end if;
        end if;
    end process;

    tx_axis_tready <= ready_i;
    tx_serial      <= tx_reg;

end architecture rtl;