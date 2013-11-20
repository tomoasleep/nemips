library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_sram_cmd.all;

entity sram_tb is
  port(
        read_data    : out std_logic_vector(31 downto 0);
        write_data   : in  std_logic_vector(31 downto 0);
        addr         : in  std_logic_vector(19 downto 0);
        command      : in  sram_cmd_type;
        read_ready : out std_logic;
        debug_addr : in std_logic_vector(7 downto 0);
        debug_data : out std_logic_vector(31 downto 0);
        clk : in std_logic
      );
end sram_tb;

architecture behave of sram_tb is
  component sram_controller
    port(
          read_data    : out std_logic_vector(31 downto 0);
          write_data   : in  std_logic_vector(31 downto 0);
          addr         : in  std_logic_vector(19 downto 0);
          command      : in  sram_cmd_type;
          read_ready : out std_logic;

          sram_data         : inout std_logic_vector(31 downto 0);
          sram_addr         : out std_logic_vector(19 downto 0);
          sram_write_disable : out std_logic;
          clk : in std_logic
        );
  end component;

  component sram_mock
    port(
          data    : inout std_logic_vector(31 downto 0);

          address : in std_logic_vector(7 downto 0);
          we: in std_logic;
          debug_addr : in std_logic_vector(7 downto 0);
          debug_data : out std_logic_vector(31 downto 0);
          clk : in std_logic
        );
  end component;
  signal sram_data    : std_logic_vector(31 downto 0);
  signal sram_addr         : std_logic_vector(19 downto 0);
  signal sram_write_enable : std_logic;
  signal sram_write_disable : std_logic;
begin
  ctl: sram_controller
  port map(
            read_data => read_data,
            write_data => write_data,
            addr => addr,
            command => command,
            read_ready => read_ready,
            sram_data => sram_data,
            sram_addr => sram_addr,
            sram_write_disable => sram_write_disable,
            clk => clk
          );
  mock: sram_mock
  port map(
        data => sram_data,
        address => sram_addr(7 downto 0),
        we => sram_write_enable,
        debug_data => debug_data,
        debug_addr => debug_addr,
        clk => clk
      );
  sram_write_enable <= not sram_write_disable;
end behave;

