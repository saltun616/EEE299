library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axis_fifo is
    generic (
        DATA_WIDTH : integer := 8;
        DEPTH      : integer := 16   
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        s_axis_tvalid : in  std_logic;
        s_axis_tready : out std_logic;
        s_axis_tdata  : in  std_logic_vector(DATA_WIDTH-1 downto 0);

        m_axis_tvalid : out std_logic;
        m_axis_tready : in  std_logic;
        m_axis_tdata  : out std_logic_vector(DATA_WIDTH-1 downto 0);

        fifo_full  : out std_logic;
        fifo_empty : out std_logic;
        fifo_count : out std_logic_vector(4 downto 0) 
    );
end entity axis_fifo;

architecture rtl of axis_fifo is

    constant ADDR_WIDTH : integer := 4; 

    type mem_array is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem : mem_array := (others => (others => '0'));

    signal wr_ptr : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal rd_ptr : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal cnt    : unsigned(ADDR_WIDTH downto 0)   := (others => '0'); 

    signal full_i, empty_i : std_logic;
    signal wr_en, rd_en     : std_logic;

begin

    full_i  <= '1' when cnt = DEPTH else '0';
    empty_i <= '1' when cnt = 0     else '0';

    s_axis_tready <= not full_i;   
    m_axis_tvalid <= not empty_i; 

    wr_en <= s_axis_tvalid and (not full_i);
    rd_en <= m_axis_tready and (not empty_i);

    m_axis_tdata <= mem(to_integer(rd_ptr));

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                wr_ptr <= (others => '0');
                rd_ptr <= (others => '0');
                cnt    <= (others => '0');
            else
                if wr_en = '1' then
                    mem(to_integer(wr_ptr)) <= s_axis_tdata;
                    wr_ptr <= wr_ptr + 1;
                end if;

                if rd_en = '1' then
                    rd_ptr <= rd_ptr + 1;
                end if;

                if wr_en = '1' and rd_en = '0' then
                    cnt <= cnt + 1;
                elsif wr_en = '0' and rd_en = '1' then
                    cnt <= cnt - 1;
                end if;
            end if;
        end if;
    end process;

    fifo_full  <= full_i;
    fifo_empty <= empty_i;
    fifo_count <= std_logic_vector(cnt);

end architecture rtl;