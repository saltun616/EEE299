library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity basys3_axis_fifo_uart_demo is
    port (
        clk  : in  std_logic;
        btnC : in  std_logic;
        btnU : in  std_logic;
        btnD : in  std_logic;
        sw   : in  std_logic_vector(7 downto 0);
        led  : out std_logic_vector(15 downto 0);
        seg  : out std_logic_vector(6 downto 0);
        dp   : out std_logic;
        an   : out std_logic_vector(3 downto 0);

        RsRx : in  std_logic;   
        RsTx : out std_logic    
    );
end entity basys3_axis_fifo_uart_demo;

architecture rtl of basys3_axis_fifo_uart_demo is

    signal rst : std_logic;

    signal push_pulse, pop_pulse : std_logic;

    signal s_tvalid : std_logic;
    signal s_tready : std_logic;
    signal s_tdata  : std_logic_vector(7 downto 0);
    signal m_tvalid : std_logic;
    signal m_tready : std_logic;
    signal m_tdata  : std_logic_vector(7 downto 0);

    signal fifo_full  : std_logic;
    signal fifo_empty : std_logic;
    signal fifo_count : std_logic_vector(4 downto 0);

    signal rx_dv   : std_logic;
    signal rx_data : std_logic_vector(7 downto 0);

    signal tx_tvalid : std_logic;
    signal tx_tready : std_logic;

    signal refresh_cnt : unsigned(19 downto 0) := (others => '0');
    signal digit_sel    : std_logic_vector(1 downto 0);
    signal digit_value  : std_logic_vector(3 downto 0);

    signal count_int  : integer range 0 to 16;
    signal count_tens : integer range 0 to 1;
    signal count_ones : integer range 0 to 9;

    function to_7seg(nibble : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case nibble is
            when "0000" => return "1000000";
            when "0001" => return "1111001";
            when "0010" => return "0100100";
            when "0011" => return "0110000";
            when "0100" => return "0011001";
            when "0101" => return "0010010";
            when "0110" => return "0000010";
            when "0111" => return "1111000";
            when "1000" => return "0000000";
            when "1001" => return "0010000";
            when others => return "1111111";
        end case;
    end function;

begin

    rst <= btnC;

    u_debounce_push : entity work.debounce_onepulse
        port map (clk => clk, rst => rst, btn_in => btnU, pulse_out => push_pulse);

    u_debounce_pop : entity work.debounce_onepulse
        port map (clk => clk, rst => rst, btn_in => btnD, pulse_out => pop_pulse);

    u_uart_rx : entity work.uart_rx
        generic map (CLK_FREQ_HZ => 100_000_000, BAUD_RATE => 115200)
        port map (clk => clk, rst => rst, rx_serial => RsRx,
                   rx_dv => rx_dv, rx_data => rx_data);

    s_tvalid <= push_pulse or rx_dv;
    s_tdata  <= sw when push_pulse = '1' else rx_data;

    m_tready <= pop_pulse;

    u_fifo : entity work.axis_fifo
        generic map (DATA_WIDTH => 8, DEPTH => 16)
        port map (
            clk           => clk,
            rst           => rst,
            s_axis_tvalid => s_tvalid,
            s_axis_tready => s_tready,
            s_axis_tdata  => s_tdata,
            m_axis_tvalid => m_tvalid,
            m_axis_tready => m_tready,
            m_axis_tdata  => m_tdata,
            fifo_full     => fifo_full,
            fifo_empty    => fifo_empty,
            fifo_count    => fifo_count
        );

    tx_tvalid <= pop_pulse and m_tvalid; 

    u_uart_tx : entity work.uart_tx
        generic map (CLK_FREQ_HZ => 100_000_000, BAUD_RATE => 115200)
        port map (clk => clk, rst => rst,
                   tx_axis_tvalid => tx_tvalid, tx_axis_tready => tx_tready,
                   tx_axis_tdata => m_tdata, tx_serial => RsTx);

    led(7 downto 0)   <= m_tdata;
    led(8)            <= fifo_empty;
    led(9)            <= fifo_full;
    led(14 downto 10) <= fifo_count;
    led(15)           <= m_tvalid;

    count_int  <= to_integer(unsigned(fifo_count));
    count_tens <= count_int / 10;
    count_ones <= count_int mod 10;

    process(clk)
    begin
        if rising_edge(clk) then
            refresh_cnt <= refresh_cnt + 1;
        end if;
    end process;

    digit_sel <= std_logic_vector(refresh_cnt(19 downto 18));

    process(digit_sel, m_tdata, count_tens, count_ones)
    begin
        case digit_sel is
            when "00" =>
                an          <= "1110";
                digit_value <= std_logic_vector(to_unsigned(count_ones, 4));
            when "01" =>
                an          <= "1101";
                digit_value <= std_logic_vector(to_unsigned(count_tens, 4));
            when "10" =>
                an          <= "1011";
                digit_value <= m_tdata(3 downto 0);
            when others =>
                an          <= "0111";
                digit_value <= m_tdata(7 downto 4);
        end case;
    end process;

    seg <= "1111111" when (digit_sel(1) = '1' and fifo_empty = '1')
           else to_7seg(digit_value);
    dp  <= '1';

end architecture rtl;