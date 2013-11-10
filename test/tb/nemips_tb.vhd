library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_sram_cmd.all;
use work.const_io.all;

entity nemips_tb is
  generic(io_wait: std_logic_vector(15 downto 0) := x"1ADB");
  port(
        rs232c_in : in std_logic;
        rs232c_out: out std_logic;
        sram_inout : inout std_logic_vector(31 downto 0);
        sram_addr : out std_logic_vector(19 downto 0);
        sram_write_enable : out std_logic;
        read_length: in io_length_type;
        read_addr: in std_logic_vector(10 downto 0);

        read_data: out std_logic_vector(31 downto 0);
        read_ready  : out std_logic;
        reset : in std_logic;
        clk : in std_logic
      );
end nemips_tb;

architecture behave of nemips_tb is
  component nemips
  generic(io_wait: std_logic_vector(15 downto 0) := x"1ADB");
  port(
        rs232c_in : in std_logic;
        rs232c_out: out std_logic;
        sram_inout : inout std_logic_vector(31 downto 0);
        sram_addr : out std_logic_vector(19 downto 0);
        sram_write_enable : out std_logic;
        reset : in std_logic;
        clk : in std_logic
      );
  end component;

  component debug_io_receiver
  generic(wtime: std_logic_vector(15 downto 0) := x"1ADB");
    port (
        -- write_data : in std_logic_vector(31 downto 0);
        -- write_length: in io_length_type;
        read_length: in io_length_type;
        read_addr: in std_logic_vector(10 downto 0);

        read_data: out std_logic_vector(31 downto 0);
        read_data_ready  : out std_logic;
        -- write_data_ready : out std_logic;

        rs232c_in : in std_logic;
        -- rs232c_out: out std_logic;
        clk : in std_logic
         );
  end component;
  signal  sig_rs232c_in, sig_rs232c_out: std_logic;
begin
  nemips_dut: nemips generic map(io_wait => io_wait)
  port map(
  rs232c_in => rs232c_in,
  rs232c_out => sig_rs232c_out,
  sram_inout => sram_inout,
  sram_addr => sram_addr,
  sram_write_enable => sram_write_enable,
  reset => reset,
  clk => clk);

  debug_buffer: debug_io_receiver generic map(wtime => io_wait)
  port map(
  rs232c_in => sig_rs232c_out,
  read_length => read_length,
  read_addr => read_addr,
  read_data => read_data,
  read_data_ready => read_ready,
  clk => clk);
end behave;

