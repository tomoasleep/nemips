library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_alu_ctl.all;
use work.const_opcode.all;

use work.typedef_opcode.all;
use work.typedef_data.all;
use work.pipeline_types.all;

entity cache is
  port(
        write_address : in mem_addr_type;
        write_data : in word_data_type;
        write_enable : in boolean;

        read_address : in mem_addr_type;
        read_data : out word_data_type;
        hit : out boolean;
        clk : in std_logic
      );
end cache;

architecture behave of cache is

  type cache_data_array is array(0 to 2 ** 10 - 1) of word_data_type;
  type cache_tag_array is array(0 to 2 ** 10 - 1) of std_logic_vector(9 downto 0);
  signal cache_data_ram : cache_data_array;
  signal cache_tag_ram : cache_tag_array;

  signal read_cell_data : word_data_type;
  signal read_cell_tag : std_logic_vector(9 downto 0);

  alias read_tag : std_logic_vector(9 downto 0) is read_address(19 downto 10);
  alias read_idx : std_logic_vector(9 downto 0) is read_address(9 downto 0);

  alias write_tag : std_logic_vector(9 downto 0) is write_address(19 downto 10);
  alias write_idx : std_logic_vector(9 downto 0) is write_address(9 downto 0);
begin
  read_cell_data <= cache_data_ram(to_integer(unsigned(read_idx)));
  read_cell_tag <= cache_tag_ram(to_integer(unsigned(read_idx)));
  read_data <= read_cell_data;
  hit <= read_cell_tag = read_tag;

  process(clk) begin
    if rising_edge(clk) and write_enable then
      cache_data_ram(to_integer(unsigned(write_idx))) <= write_data;
      cache_tag_ram(to_integer(unsigned(write_idx))) <= write_tag;
    end if;
  end process;
end behave;
