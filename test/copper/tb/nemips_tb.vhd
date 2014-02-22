library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_sram_cmd.all;
use work.const_io.all;

-- <%- require_relative 'src/project_helper' -%>

-- <%- project_components %w(nemips io_controller sram_mock) -%>
-- <%- project_define_component_mappings(as: { 'nemips.rs232c_in' => 'rs232c_in', 'nemips.rs232c_out' => 'rs232c_out', 'io_controller.rs232c_in' => 'rs232c_out', 'io_controller.rs232c_out' => 'rs232c_in', sram_inout: 'sram_inout', debug_addr: 'sram_debug_addr', debug_data: 'sram_debug_data', read_length: 'read_length', read_data: 'read_data', read_data_ready: 'read_ready', write_data_ready: 'write_ready', read_addr: 'read_addr', write_data: 'write_data', write_length: 'write_length', sram_addr: 'sram_addr', address: 'sram_addr', is_break: 'is_break', continue: 'continue', reset: 'reset', io_wait: 'io_wait', wtime: 'io_wait'}) -%>

entity nemips_tb is
  generic(
    -- io_wait: std_logic_vector(15 downto 0) := x"0001";
    sram_length : std_logic_vector(4 downto 0) := "00100"
  );
  port(
        read_length: in io_length_type;
        read_addr: in std_logic_vector(10 downto 0);
        write_data : in std_logic_vector(31 downto 0);
        write_length: in io_length_type;

        read_data: out std_logic_vector(31 downto 0);
        read_ready  : out std_logic;
        write_ready : out std_logic;

        sram_debug_addr : in std_logic_vector(19 downto 0);
        sram_debug_data : out std_logic_vector(31 downto 0);

        reset : in std_logic;
        is_break: out std_logic;
        continue: in std_logic;
        clk : in std_logic
      );
end nemips_tb;

architecture behave of nemips_tb is
  constant io_wait: std_logic_vector(15 downto 0) := x"0001";
-- COMPONENT DEFINITION BLOCK BEGIN {{{
component nemips

  generic(
      io_wait : std_logic_vector(15 downto 0) := x"1ADB"
         );


  port(
      rs232c_in : in std_logic;
rs232c_out : out std_logic;
sram_inout : inout std_logic_vector(31 downto 0);
sram_addr : out std_logic_vector(19 downto 0);
sram_write_disable : out std_logic;
reset : in std_logic;
is_break : out std_logic;
continue : in std_logic;
clk : in std_logic
       );

end component;


component io_controller

  generic(
      wtime : std_logic_vector(15 downto 0) := x"1ADB";
buffer_max : integer := 4
         );


  port(
      write_data : in std_logic_vector(31 downto 0);
write_length : in io_length_type;
read_length : in io_length_type;
read_data : out std_logic_vector(31 downto 0);
read_data_ready : out std_logic;
write_data_ready : out std_logic;
rs232c_in : in std_logic;
rs232c_out : out std_logic;
clk : in std_logic
       );

end component;


component sram_mock

  generic(
      sram_length : integer := 13
         );


  port(
      data : inout std_logic_vector(31 downto 0);
address : in std_logic_vector(19 downto 0);
we : in std_logic;
debug_addr : in std_logic_vector(19 downto 0);
debug_data : out std_logic_vector(31 downto 0);
clk : in std_logic
       );

end component;


-- COMPONENT DEFINITION BLOCK END }}}
-- SIGNAL BLOCK BEGIN {{{
  signal nemips_rs232c_in : std_logic;
signal nemips_rs232c_out : std_logic;
signal nemips_sram_inout : std_logic_vector(31 downto 0);
signal nemips_sram_addr : std_logic_vector(19 downto 0);
signal nemips_sram_write_disable : std_logic;
signal nemips_reset : std_logic;
signal nemips_is_break : std_logic;
signal nemips_continue : std_logic;
signal nemips_clk : std_logic;

  signal io_controller_write_data : std_logic_vector(31 downto 0);
signal io_controller_write_length : io_length_type;
signal io_controller_read_length : io_length_type;
signal io_controller_read_data : std_logic_vector(31 downto 0);
signal io_controller_read_data_ready : std_logic;
signal io_controller_write_data_ready : std_logic;
signal io_controller_rs232c_in : std_logic;
signal io_controller_rs232c_out : std_logic;
signal io_controller_clk : std_logic;

  signal sram_mock_data : std_logic_vector(31 downto 0);
signal sram_mock_address : std_logic_vector(19 downto 0);
signal sram_mock_we : std_logic;
signal sram_mock_debug_addr : std_logic_vector(19 downto 0);
signal sram_mock_debug_data : std_logic_vector(31 downto 0);
signal sram_mock_clk : std_logic;

-- SIGNAL BLOCK END }}}
  signal sram_inout : std_logic_vector(31 downto 0);
  signal sram_addr : std_logic_vector(19 downto 0);
  signal sram_write_enable, sram_write_disable : std_logic;

  signal  rs232c_in, rs232c_out: std_logic;

  constant sram_mock_sram_length : integer := to_integer(unsigned(sram_length));
begin
-- COMPONENT MAPPING BLOCK BEGIN {{{
nemips_comp: nemips
  generic map(
      io_wait => io_wait
         )
  port map(
      rs232c_in => rs232c_in,
rs232c_out => rs232c_out,
sram_inout => sram_inout,
sram_addr => sram_addr,
sram_write_disable => nemips_sram_write_disable,
reset => reset,
is_break => is_break,
continue => continue,
clk => clk
       )
;

io_controller_comp: io_controller
  generic map(
      wtime => io_wait,
buffer_max => 4
         )
  port map(
      write_data => write_data,
write_length => write_length,
read_length => read_length,
read_data => read_data,
read_data_ready => read_ready,
write_data_ready => write_ready,
rs232c_in => rs232c_out,
rs232c_out => rs232c_in,
clk => clk
       )
;

sram_mock_comp: sram_mock
  generic map(
      sram_length => 13
         )
  port map(
      data => sram_mock_data,
address => sram_addr,
we => sram_mock_we,
debug_addr => sram_debug_addr,
debug_data => sram_debug_data,
clk => clk
       )
;

-- COMPONENT MAPPING BLOCK END }}}

  sram_mock_we <= not nemips_sram_write_disable;
end behave;

