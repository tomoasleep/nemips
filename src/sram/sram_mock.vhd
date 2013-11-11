library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sram_mock is
  port(
        data: inout std_logic_vector(31 downto 0);
        address : in std_logic_vector(7 downto 0);
        we : in std_logic;

        debug_addr : in std_logic_vector(7 downto 0);
        debug_data : out std_logic_vector(31 downto 0);
        clk : in std_logic
      );
end sram_mock;

architecture behave of sram_mock is
  subtype sram_data is std_logic_vector(31 downto 0);
  type data_array is array (0 to 255) of sram_data;

  subtype sram_add is std_logic_vector(7 downto 0);
  type add_array is array (0 to 3) of sram_add;
  type wr_array is array (0 to 3) of std_logic;

  signal ram_buf: data_array;
  signal add_buf: add_array;
  signal we_buf: wr_array;
  signal idx : std_logic_vector(1 downto 0) := "00";

  signal current_addr :std_logic_vector(7 downto 0);
  signal current_we : std_logic;
  signal current_data : std_logic_vector(31 downto 0);
begin
  data <= current_data when
          current_we = '0' else
          (others => 'Z');

  by_clock: process (clk)
  begin
    if rising_edge(clk) then
      case we_buf(to_integer(unsigned(idx))) is
        when '1' =>
          ram_buf(to_integer(unsigned(add_buf(to_integer(unsigned(idx)))))) <= data;
        when others =>
      end case;

      add_buf(to_integer((unsigned(idx) + 2))) <= address;
      we_buf(to_integer(unsigned(idx) + 2)) <= we;

      current_addr <= add_buf(to_integer(unsigned(idx) + 1));
      current_data <= ram_buf(
                        to_integer(unsigned(
                      add_buf(
                        to_integer(unsigned(idx) + 1)))));
      current_we <= we_buf(to_integer(unsigned(idx) + 1));
      idx <= std_logic_vector(unsigned(idx) + 1);
    end if;
  end process;

  debug_data <= ram_buf(to_integer(unsigned(debug_addr)));
end behave;

