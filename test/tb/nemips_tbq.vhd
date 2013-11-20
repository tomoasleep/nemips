library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_sram_cmd.all;
use work.const_io.all;

entity nemips_tbq is
  generic(io_wait: std_logic_vector(15 downto 0) := x"1ADB");
  port(
        read_length: in io_length_type;
        write_data : in std_logic_vector(31 downto 0);
        write_length: in io_length_type;

        read_data: out std_logic_vector(31 downto 0);
        read_ready  : out std_logic;
        write_ready : out std_logic;

        sram_debug_addr : in std_logic_vector(7 downto 0);
        sram_debug_data : out std_logic_vector(31 downto 0);

        reset : in std_logic;
        is_break: out std_logic;
        continue: in std_logic;
        clk : in std_logic
      );
end nemips_tbq;

architecture behave of nemips_tbq is
  component nemips
  generic(io_wait: std_logic_vector(15 downto 0) := x"1ADB");
  port(
        rs232c_in : in std_logic;
        rs232c_out: out std_logic;
        sram_inout : inout std_logic_vector(31 downto 0);
        sram_addr : out std_logic_vector(19 downto 0);
        sram_write_disable : out std_logic;

        reset : in std_logic;
        is_break: out std_logic;
        continue: in std_logic;
        clk : in std_logic
      );
  end component;

  component io_controller
  generic(wtime: std_logic_vector(15 downto 0) := x"1ADB");
    port (
        write_data : in std_logic_vector(31 downto 0);
        write_length: in io_length_type;
        read_length: in io_length_type;

        read_data: out std_logic_vector(31 downto 0);
        read_data_ready  : out std_logic;
        write_data_ready : out std_logic;

        rs232c_in : in std_logic;
        rs232c_out: out std_logic;
        clk : in std_logic
         );
  end component;

  component sram_mock
  port(
        data: inout std_logic_vector(31 downto 0);
        address : in std_logic_vector(7 downto 0);
        we : in std_logic;

        debug_addr : in std_logic_vector(7 downto 0);
        debug_data : out std_logic_vector(31 downto 0);
        clk : in std_logic
      );
  end component;

  signal sram_inout : std_logic_vector(31 downto 0);
  signal sram_addr : std_logic_vector(19 downto 0);
  signal sram_write_disable : std_logic;
  signal sram_write_enable : std_logic;

  signal  rs232c_in, rs232c_out: std_logic;
begin
  nemips_dut: nemips generic map(io_wait => io_wait)
  port map(
  rs232c_in => rs232c_in,
  rs232c_out => rs232c_out,
  sram_inout => sram_inout,
  sram_addr => sram_addr,
  sram_write_disable => sram_write_disable,
  reset => reset,
  is_break => is_break,
  continue => continue,
  clk => clk);

  debug_buffer: io_controller generic map(wtime => io_wait)
  port map(
  rs232c_in => rs232c_out,
  rs232c_out => rs232c_in,
  write_data => write_data,
  write_length => write_length,
  write_data_ready => write_ready,
  read_length => read_length,
  read_data => read_data,
  read_data_ready => read_ready,
  clk => clk);

  sram_mck: sram_mock
  port map(
        data => sram_inout,
        address => sram_addr(7 downto 0),
        we => sram_write_enable,
        debug_data => sram_debug_data,
        debug_addr => sram_debug_addr,
        clk => clk
      );
  sram_write_enable <= not sram_write_disable;
end behave;

