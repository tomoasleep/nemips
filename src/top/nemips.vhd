library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_sram_cmd.all;
use work.const_io.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

-- <%- require_relative 'src/project_helper' -%>
-- <%- project_define_component_mappings as: { sram_data: 'sram_inout',sram_addr: 'sram_addr' , wtime: 'io_wait', rs232c_in: 'rs232c_in', rs232c_out: 'rs232c_out' } -%>
-- <%- project_components %w(path inst_ram io_controller sram_controller ) -%>

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
-- COMPONENT DEFINITION BLOCK BEGIN {{{
component path


  port(
      io_read_data : in word_data_type;
io_write_data : out word_data_type;
io_write_cmd : out io_length_type;
io_read_cmd : out io_length_type;
io_read_success : in std_logic;
io_write_success : in std_logic;
sram_write_data : out word_data_type;
sram_read_data : in word_data_type;
sram_addr : out mem_addr_type;
sram_cmd : out sram_cmd_type;
inst_ram_read_data : in order_type;
inst_ram_read_addr : out pc_data_type;
inst_ram_write_data : out order_type;
inst_ram_write_addr : out pc_data_type;
inst_ram_write_enable : out std_logic;
is_break : out std_logic;
continue : in std_logic;
reset : in std_logic;
clk : in std_logic
       );

end component;


component inst_ram


  port(
      addr : in std_logic_vector(29 downto 0);
write_data : in std_logic_vector(31 downto 0);
write_enable : in std_logic;
read_data : out std_logic_vector(31 downto 0);
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


component sram_controller


  port(
      read_data : out word_data_type;
write_data : in word_data_type;
addr : in mem_addr_type;
command : in sram_cmd_type;
sram_data : inout word_data_type;
sram_addr : out std_logic_vector(19 downto 0);
clk : in std_logic
       );

end component;


-- COMPONENT DEFINITION BLOCK END }}}
-- SIGNAL BLOCK BEGIN {{{
  signal path_io_read_data : word_data_type;
signal path_io_write_data : word_data_type;
signal path_io_write_cmd : io_length_type;
signal path_io_read_cmd : io_length_type;
signal path_io_read_success : std_logic;
signal path_io_write_success : std_logic;
signal path_sram_write_data : word_data_type;
signal path_sram_read_data : word_data_type;
signal path_sram_addr : mem_addr_type;
signal path_sram_cmd : sram_cmd_type;
signal path_inst_ram_read_data : order_type;
signal path_inst_ram_read_addr : pc_data_type;
signal path_inst_ram_write_data : order_type;
signal path_inst_ram_write_addr : pc_data_type;
signal path_inst_ram_write_enable : std_logic;
signal path_is_break : std_logic;
signal path_continue : std_logic;
signal path_reset : std_logic;
signal path_clk : std_logic;

  signal inst_ram_addr : std_logic_vector(29 downto 0);
signal inst_ram_write_data : std_logic_vector(31 downto 0);
signal inst_ram_write_enable : std_logic;
signal inst_ram_read_data : std_logic_vector(31 downto 0);
signal inst_ram_clk : std_logic;

  signal io_controller_write_data : std_logic_vector(31 downto 0);
signal io_controller_write_length : io_length_type;
signal io_controller_read_length : io_length_type;
signal io_controller_read_data : std_logic_vector(31 downto 0);
signal io_controller_read_data_ready : std_logic;
signal io_controller_write_data_ready : std_logic;
signal io_controller_rs232c_in : std_logic;
signal io_controller_rs232c_out : std_logic;
signal io_controller_clk : std_logic;

  signal sram_controller_read_data : word_data_type;
signal sram_controller_write_data : word_data_type;
signal sram_controller_addr : mem_addr_type;
signal sram_controller_command : sram_cmd_type;
signal sram_controller_sram_data : word_data_type;
signal sram_controller_sram_addr : std_logic_vector(19 downto 0);
signal sram_controller_clk : std_logic;

-- SIGNAL BLOCK END }}}
  
begin
-- COMPONENT MAPPING BLOCK BEGIN {{{
path_comp: path
  port map(
      io_read_data => path_io_read_data,
io_write_data => path_io_write_data,
io_write_cmd => path_io_write_cmd,
io_read_cmd => path_io_read_cmd,
io_read_success => path_io_read_success,
io_write_success => path_io_write_success,
sram_write_data => path_sram_write_data,
sram_read_data => path_sram_read_data,
sram_addr => sram_addr,
sram_cmd => path_sram_cmd,
inst_ram_read_data => path_inst_ram_read_data,
inst_ram_read_addr => path_inst_ram_read_addr,
inst_ram_write_data => path_inst_ram_write_data,
inst_ram_write_addr => path_inst_ram_write_addr,
inst_ram_write_enable => path_inst_ram_write_enable,
is_break => path_is_break,
continue => path_continue,
reset => path_reset,
clk => clk
       )
;

inst_ram_comp: inst_ram
  port map(
      addr => inst_ram_addr,
write_data => inst_ram_write_data,
write_enable => inst_ram_write_enable,
read_data => inst_ram_read_data,
clk => clk
       )
;

io_controller_comp: io_controller
  generic map(
      wtime => io_wait,
buffer_max => 4
         )
  port map(
      write_data => io_controller_write_data,
write_length => io_controller_write_length,
read_length => io_controller_read_length,
read_data => io_controller_read_data,
read_data_ready => io_controller_read_data_ready,
write_data_ready => io_controller_write_data_ready,
rs232c_in => rs232c_in,
rs232c_out => rs232c_out,
clk => clk
       )
;

sram_controller_comp: sram_controller
  port map(
      read_data => sram_controller_read_data,
write_data => sram_controller_write_data,
addr => sram_controller_addr,
command => sram_controller_command,
sram_data => sram_inout,
sram_addr => sram_addr,
clk => clk
       )
;

-- COMPONENT MAPPING BLOCK END }}}

  io_controller_write_data <= path_io_write_data;
  path_io_read_data <= inst_ram_read_data;

  io_controller_write_length <= path_io_write_cmd;
  io_controller_read_length <= path_io_read_cmd;

  path_io_write_success <= io_controller_write_data_ready;
  path_io_read_success <= io_controller_read_data_ready;

  path_sram_read_data <= sram_controller_read_data;
  sram_controller_write_data <= path_sram_write_data;

  sram_controller_addr <= path_sram_addr;
  sram_controller_command <= path_sram_cmd;

  -- inst_ram_write_addr <= path_inst_ram_read_addr;
  inst_ram_addr <= path_inst_ram_read_addr;
  inst_ram_write_data <= path_inst_ram_write_data;
  path_inst_ram_read_data <= inst_ram_read_data;

  inst_ram_write_enable <= path_inst_ram_write_enable;

end behave;
