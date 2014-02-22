library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_sram_cmd.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

entity sram_controller is
  port(
        read_data    : out word_data_type;
        write_data   : in  word_data_type;
        addr         : in  mem_addr_type;
        command      : in  sram_cmd_type;

        sram_data         : inout  word_data_type;
        sram_addr         : out std_logic_vector(19 downto 0);
        sram_write_disable : out std_logic;
        read_ready : out std_logic;
        clk : in std_logic
      );
end sram_controller;

architecture behave of sram_controller is
  subtype data_unit is std_logic_vector(31 downto 0);
  type data_array is array(0 to 3) of data_unit;
  type cmd_array is array(0 to 3) of sram_cmd_type;

  constant ZERO : std_logic_vector(31 downto 0) := (others => '0');
  signal data_buffer : data_array; -- := (others => ZERO);
  signal cmd_buffer : cmd_array; -- := (others => ZERO);
  signal idx : std_logic_vector(1 downto 0) := (others => '0');

  signal sram_write_data : std_logic_vector(31 downto 0);
  signal sram_data_send : std_logic;
begin
  process(clk) begin
    if rising_edge(clk) then
      -- save cmd and data
      data_buffer(to_integer(unsigned(idx) + 2)) <= write_data;
      cmd_buffer(to_integer(unsigned(idx) + 2)) <= command;

      -- receive data (2 clock rising edge after address received)
      if cmd_buffer(to_integer(unsigned(idx) - 1)) = sram_cmd_read then
        read_data <= sram_data;
        read_ready <= '1';
      else
        read_ready <= '0';
      end if;

      -- send data (2 clock after address)
      if cmd_buffer(to_integer(unsigned(idx))) = sram_cmd_write then
        sram_write_data <= data_buffer(to_integer(unsigned(idx)));
        sram_data_send <= '1';
      else
        sram_data_send <= '0';
      end if;

      case command is
        when sram_cmd_write =>
          sram_write_disable <= '0';
        when others =>
          sram_write_disable <= '1';
      end case;

      sram_addr <= addr;
      idx <= std_logic_vector(unsigned(idx) + 1);
    end if;
  end process;

  sram_data <= sram_write_data when sram_data_send = '1' else (others => 'Z');
end behave;


