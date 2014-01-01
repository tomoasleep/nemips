library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sram_mock is
  port(
        data: inout std_logic_vector(31 downto 0);
        address : in std_logic_vector(19 downto 0);
        we : in std_logic;

        debug_addr : in std_logic_vector(19 downto 0);
        debug_data : out std_logic_vector(31 downto 0);
        clk : in std_logic
      );
end sram_mock;

architecture behave of sram_mock is
  constant sram_length : integer := 13;

  subtype sram_data is std_logic_vector(31 downto 0);
  type data_array is array (0 to 2 ** sram_length - 1) of sram_data;

  subtype sram_addr is std_logic_vector(sram_length - 1 downto 0);
  type addr_array is array (0 to 3) of sram_addr;
  type wr_array is array (0 to 3) of std_logic;

  signal ram_buf: data_array;
  signal addr_buf: addr_array;
  signal we_buf: wr_array;
  signal idx : std_logic_vector(1 downto 0) := "00";

  signal current_addr : sram_addr;
  signal current_we : std_logic;
  signal current_data : std_logic_vector(31 downto 0);

  signal addr_input : sram_addr;
begin
  data <= current_data when
          current_we = '0' else
          (others => 'Z');

  by_clock: process (clk)
  begin
    if rising_edge(clk) then
      case we_buf(to_integer(unsigned(idx))) is
        when '1' =>
          ram_buf(to_integer(unsigned(addr_buf(to_integer(unsigned(idx)))))) <= data;
        when others =>
      end case;

      addr_buf(to_integer((unsigned(idx) + 2))) <= addr_input;
      we_buf(to_integer(unsigned(idx) + 2)) <= we;

      current_addr <= addr_buf(to_integer(unsigned(idx) + 1));
      current_data <= ram_buf(
                        to_integer(unsigned(
                      addr_buf(
                        to_integer(unsigned(idx) + 1)))));
      current_we <= we_buf(to_integer(unsigned(idx) + 1));
      idx <= std_logic_vector(unsigned(idx) + 1);
    end if;
  end process;
  addr_input <= address(sram_length - 1 downto 0);
  debug_data <= ram_buf(to_integer(unsigned(debug_addr(sram_length - 1 downto 0))));
end behave;

