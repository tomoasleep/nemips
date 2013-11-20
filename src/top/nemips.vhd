library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_sram_cmd.all;
use work.const_io.all;

entity nemips is
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
end nemips;

architecture behave of nemips is
  component path
    port (
        io_read_data : in std_logic_vector(31 downto 0);
        io_read_ready: in std_logic;
        io_write_ready: in std_logic;

        mem_read_data: in std_logic_vector(31 downto 0);
        mem_read_ready : in std_logic;
        reset : in std_logic;
        inst_rom_data : in std_logic_vector(31 downto 0);

        io_write_data: out std_logic_vector(31 downto 0);
        io_write_cmd: out io_length_type;
        io_read_cmd: out io_length_type;
        inst_rom_addr : out std_logic_vector(29 downto 0);

        mem_write_data : out std_logic_vector(31 downto 0);
        mem_addr: out std_logic_vector(31 downto 0);
        sram_cmd: out sram_cmd_type;

        is_break: out std_logic;
        continue: in std_logic;
        clk : in std_logic
      );
  end component;

  component inst_rom
    port(
          addr: in std_logic_vector(29 downto 0);
          data: out std_logic_vector(31 downto 0)
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

  component sram_controller
    port (
        read_data    : out std_logic_vector(31 downto 0);
        write_data   : in  std_logic_vector(31 downto 0);
        addr         : in  std_logic_vector(19 downto 0);
        command      : in  sram_cmd_type;

        sram_data         : inout  std_logic_vector(31 downto 0);
        sram_addr         : out std_logic_vector(19 downto 0);
        sram_write_disable : out std_logic;
        read_ready : out std_logic;
        clk : in std_logic
         );
  end component;

  signal io_read_data, io_write_data, mem_read_data, mem_write_data : std_logic_vector(31 downto 0);
  signal inst_rom_data : std_logic_vector(31 downto 0);

  signal mem_addr : std_logic_vector(31 downto 0);
  signal inst_rom_addr : std_logic_vector(29 downto 0);

  signal io_read_ready, io_write_ready, mem_read_ready : std_logic;

  signal io_write_length, io_read_length : io_length_type;
  signal mem_cmd : sram_cmd_type;
begin
  datapath: path port map(
   io_read_data => io_read_data,
   io_read_ready => io_read_ready,
   io_write_ready => io_write_ready,
   mem_read_data => mem_read_data,
   mem_read_ready => mem_read_ready,
   reset => reset,
   is_break => is_break,
   continue => continue,
   inst_rom_data => inst_rom_data,
   io_write_data => io_write_data,

   io_write_cmd => io_write_length,
   io_read_cmd => io_read_length,

   inst_rom_addr => inst_rom_addr,
   mem_write_data => mem_write_data,
   mem_addr => mem_addr,
   sram_cmd => mem_cmd,
   clk => clk);

  inst: inst_rom port map(
   addr => inst_rom_addr,
   data => inst_rom_data);

  ioc: io_controller generic map(wtime => io_wait)
  port map(
   write_data => io_write_data,
   write_length => io_write_length,
   read_length => io_read_length,

   read_data => io_read_data,
   read_data_ready => io_read_ready,
   write_data_ready => io_write_ready,

   rs232c_in => rs232c_in,
   rs232c_out => rs232c_out,
   clk => clk);

  memc: sram_controller port map(
   read_data => mem_read_data,
   write_data => mem_write_data,
   addr => mem_addr(19 downto 0),
   command => mem_cmd,
   read_ready => mem_read_ready,

   sram_data => sram_inout,
   sram_addr => sram_addr,
   sram_write_disable => sram_write_disable,
   clk => clk);

end behave;
