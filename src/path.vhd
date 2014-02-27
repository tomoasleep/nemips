library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_state.all;
use work.const_mux.all;
use work.const_alu_ctl.all;
use work.const_fpu_ctl.all;
use work.const_io.all;
use work.const_sram_cmd.all;
use work.const_pipeline_state.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

use work.order_utils.all;
use work.pipeline_types.all;

-- <%- require_relative 'src/project_helper' -%>

-- <%- project_components %w(program_counter) -%>
-- <%- project_components %w(ex_path memory_path write_back_path) -%>
-- <%- project_components %w(pipeline_controller) -%>
-- <%- project_components :trap_handler, as: :ex_handler -%>
-- <%- project_components :register_file, as: :i_register -%>
-- <%- project_components :register_file_float, as: :f_register -%>
-- <%- project_components :structual_hazards_controller, as: :st_controller -%>

entity path is
  port(
        io_read_data : in word_data_type;
        io_write_data: out word_data_type;

        io_write_cmd: out io_length_type;
        io_read_cmd: out io_length_type;

        io_write_success : in std_logic;
        io_read_success : in std_logic;

        sram_write_data : out word_data_type;
        sram_read_data: in word_data_type;
        sram_addr: out mem_addr_type;
        sram_cmd: out sram_cmd_type;

        inst_ram_read_data : in order_type;
        inst_ram_read_addr : out pc_data_type;

        inst_ram_write_data : out order_type;
        inst_ram_write_addr : out pc_data_type;

        inst_ram_write_enable : out std_logic;

        is_break: out std_logic;
        continue: in std_logic;
        reset : in std_logic;
        clk : in std_logic
      );
end path;

architecture behave of path is
-- COMPONENT DEFINITION BLOCK BEGIN {{{
component program_counter


  port(
      write_data : in pc_data_type;
pc : out pc_data_type;
pc_write : in std_logic;
reset : in std_logic;
clk : in std_logic
       );

end component;


component ex_path


  port(
      order : in order_type;
pc : in pc_data_type;
flash_flag : in boolean;
int_rd1 : in word_data_type;
int_rd2 : in word_data_type;
float_rd1 : in word_data_type;
float_rd2 : in word_data_type;
pc_jump : out pc_data_type;
result_data : out word_data_type;
result_order : out word_data_type;
address : out mem_addr_type;
exec_orders : out exec_orders_type;
jump_enable : out boolean;
clk : in std_logic
       );

end component;


component memory_path


  port(
      order : in order_type;
exec_addr : in mem_addr_type;
exec_data : in word_data_type;
result_data : out word_data_type;
result_order : out order_type;
sram_write_data : out word_data_type;
sram_read_data : in word_data_type;
io_write_data : out word_data_type;
io_read_data : in word_data_type;
sram_addr : out mem_addr_type;
sram_cmd : out sram_cmd_type;
io_write_cmd : out io_length_type;
io_read_cmd : out io_length_type;
io_write_success : in std_logic;
io_read_success : in std_logic;
io_read_fault : out boolean;
io_write_fault : out boolean;
inst_ram_write_data : out order_type;
inst_ram_write_addr : out pc_data_type;
inst_ram_write_enable : out std_logic;
memory_orders : out memory_orders_type;
flash_flag : in boolean;
clk : in std_logic
       );

end component;


component write_back_path


  port(
      order : in order_type;
memory_data : in word_data_type;
reg_write_data : out word_data_type;
reg_write_addr : out register_addr_type;
io_success : in std_logic;
ireg_write_enable : out std_logic;
freg_write_enable : out std_logic;
clk : in std_logic
       );

end component;


component pipeline_controller


  port(
      decode_order : in order_type;
exec_pipe : in exec_orders_type;
memory_pipe : in memory_orders_type;
write_back_order : in order_type;
input_forwardings_mem : out input_forwardings_record;
input_forwardings_wb : out input_forwardings_record;
is_data_hazard : out boolean
       );

end component;


component trap_handler


  port(
      is_io_read_inst_excepiton : in boolean;
is_io_write_inst_excepiton : in boolean;
is_device_trap : in boolean;
exec_pc : in pc_data_type;
memory_pc : in pc_data_type;
wb_pc : in pc_data_type;
is_exception : out boolean;
trap_jump_pc : out pc_data_type;
save_pc : out pc_data_type;
flash_decode : out boolean;
flash_to_exec : out boolean;
flash_to_memory : out boolean;
flash_wb : out boolean
       );

end component;


component register_file


  port(
      a1 : in register_addr_type;
a2 : in register_addr_type;
a3 : in register_addr_type;
rd1 : out word_data_type;
rd2 : out word_data_type;
wd3 : in word_data_type;
trap_pc_we : in boolean;
trap_pc_data : in word_data_type;
we3 : in std_logic;
clk : in std_logic
       );

end component;


component register_file_float


  port(
      a1 : in register_addr_type;
a2 : in register_addr_type;
a3 : in register_addr_type;
rd1 : out word_data_type;
rd2 : out word_data_type;
wd3 : in word_data_type;
we3 : in std_logic;
clk : in std_logic
       );

end component;


component structual_hazards_controller


  port(
      decode_order : in order_type;
is_data_hazard : in boolean;
pipeline_rest_length : in pipeline_length_type;
ex_pipeline_rest_length : in pipeline_length_type;
is_hazard : out boolean;
next_pipeline_rest_length : out pipeline_length_type;
next_ex_pipeline_rest_length : out pipeline_length_type
       );

end component;


-- COMPONENT DEFINITION BLOCK END }}}
-- SIGNAL BLOCK BEGIN {{{
  signal program_counter_write_data : pc_data_type;
signal program_counter_pc : pc_data_type;
signal program_counter_pc_write : std_logic;
signal program_counter_reset : std_logic;
signal program_counter_clk : std_logic;

  signal ex_path_order : order_type;
signal ex_path_pc : pc_data_type;
signal ex_path_flash_flag : boolean;
signal ex_path_int_rd1 : word_data_type;
signal ex_path_int_rd2 : word_data_type;
signal ex_path_float_rd1 : word_data_type;
signal ex_path_float_rd2 : word_data_type;
signal ex_path_pc_jump : pc_data_type;
signal ex_path_result_data : word_data_type;
signal ex_path_result_order : word_data_type;
signal ex_path_address : mem_addr_type;
signal ex_path_exec_orders : exec_orders_type;
signal ex_path_jump_enable : boolean;
signal ex_path_clk : std_logic;

  signal memory_path_order : order_type;
signal memory_path_exec_addr : mem_addr_type;
signal memory_path_exec_data : word_data_type;
signal memory_path_result_data : word_data_type;
signal memory_path_result_order : order_type;
signal memory_path_sram_write_data : word_data_type;
signal memory_path_sram_read_data : word_data_type;
signal memory_path_io_write_data : word_data_type;
signal memory_path_io_read_data : word_data_type;
signal memory_path_sram_addr : mem_addr_type;
signal memory_path_sram_cmd : sram_cmd_type;
signal memory_path_io_write_cmd : io_length_type;
signal memory_path_io_read_cmd : io_length_type;
signal memory_path_io_write_success : std_logic;
signal memory_path_io_read_success : std_logic;
signal memory_path_io_read_fault : boolean;
signal memory_path_io_write_fault : boolean;
signal memory_path_inst_ram_write_data : order_type;
signal memory_path_inst_ram_write_addr : pc_data_type;
signal memory_path_inst_ram_write_enable : std_logic;
signal memory_path_memory_orders : memory_orders_type;
signal memory_path_flash_flag : boolean;
signal memory_path_clk : std_logic;

  signal write_back_path_order : order_type;
signal write_back_path_memory_data : word_data_type;
signal write_back_path_reg_write_data : word_data_type;
signal write_back_path_reg_write_addr : register_addr_type;
signal write_back_path_io_success : std_logic;
signal write_back_path_ireg_write_enable : std_logic;
signal write_back_path_freg_write_enable : std_logic;
signal write_back_path_clk : std_logic;

  signal pipeline_controller_decode_order : order_type;
signal pipeline_controller_exec_pipe : exec_orders_type;
signal pipeline_controller_memory_pipe : memory_orders_type;
signal pipeline_controller_write_back_order : order_type;
signal pipeline_controller_input_forwardings_mem : input_forwardings_record;
signal pipeline_controller_input_forwardings_wb : input_forwardings_record;
signal pipeline_controller_is_data_hazard : boolean;

  signal ex_handler_is_io_read_inst_excepiton : boolean;
signal ex_handler_is_io_write_inst_excepiton : boolean;
signal ex_handler_is_device_trap : boolean;
signal ex_handler_exec_pc : pc_data_type;
signal ex_handler_memory_pc : pc_data_type;
signal ex_handler_wb_pc : pc_data_type;
signal ex_handler_is_exception : boolean;
signal ex_handler_trap_jump_pc : pc_data_type;
signal ex_handler_save_pc : pc_data_type;
signal ex_handler_flash_decode : boolean;
signal ex_handler_flash_to_exec : boolean;
signal ex_handler_flash_to_memory : boolean;
signal ex_handler_flash_wb : boolean;

  signal i_register_a1 : register_addr_type;
signal i_register_a2 : register_addr_type;
signal i_register_a3 : register_addr_type;
signal i_register_rd1 : word_data_type;
signal i_register_rd2 : word_data_type;
signal i_register_wd3 : word_data_type;
signal i_register_trap_pc_we : boolean;
signal i_register_trap_pc_data : word_data_type;
signal i_register_we3 : std_logic;
signal i_register_clk : std_logic;

  signal f_register_a1 : register_addr_type;
signal f_register_a2 : register_addr_type;
signal f_register_a3 : register_addr_type;
signal f_register_rd1 : word_data_type;
signal f_register_rd2 : word_data_type;
signal f_register_wd3 : word_data_type;
signal f_register_we3 : std_logic;
signal f_register_clk : std_logic;

  signal st_controller_decode_order : order_type;
signal st_controller_is_data_hazard : boolean;
signal st_controller_pipeline_rest_length : pipeline_length_type;
signal st_controller_ex_pipeline_rest_length : pipeline_length_type;
signal st_controller_is_hazard : boolean;
signal st_controller_next_pipeline_rest_length : pipeline_length_type;
signal st_controller_next_ex_pipeline_rest_length : pipeline_length_type;

-- SIGNAL BLOCK END }}}
  signal pc: pc_data_type;

  signal ireg_wdata, ireg_rdata1, ireg_rdata2, ireg_rdata1_buf, ireg_rdata2_buf: word_data_type := (others => '0');
  signal freg_wdata, freg_rdata1, freg_rdata2, freg_rdata1_buf, freg_rdata2_buf: word_data_type := (others => '0');
  signal io_read_buf, mem_read_buf: word_data_type := (others => '0');
  signal saddr_fetcher, sdecode_addrr: word_data_type;
  signal mem_write_addr: word_data_type;

  signal fsm_state: state_type;
  signal wd_src: wd_src_type;
  signal fwd_src: fwd_src_type;
  signal regdist: regdist_type;
  signal pc_src: pc_src_type;
  signal io_write_cmd_choice, io_read_cmd_choice : io_length_type;

  constant reg_ra : register_addr_type := "11111";
  constant zero : word_data_type := (others => '0');

  signal pc_bta, pc_jta, pc_increment: pc_data_type;
  signal decode_pc_increment: pc_data_type;

  signal exec_state: exec_state_type;
  signal memory_state: memory_state_type;
  signal write_back_state: write_back_state_type;

  signal to_decode_pc: pc_data_type;
  signal to_decode_order: word_data_type;

  signal decode_int_rd1, decode_int_rd2: word_data_type;
  signal decode_float_rd1, decode_float_rd2: word_data_type;

  signal to_ex_pc: pc_data_type;
  signal to_ex_order: order_type;
  signal to_ex_int_rd1, to_ex_int_rd2: word_data_type;
  signal to_ex_float_rd1, to_ex_float_rd2: word_data_type;

  -- signal exec_pipe_buffer : exec_pipe_buffer_type;

  signal to_memory_order: order_type;
  signal to_memory_imm  : immediate_type; signal to_memory_addr : mem_addr_type;
  signal to_memory_pc: pc_data_type;
  signal to_memory_result: word_data_type;

  signal to_write_back_order : order_type; signal to_write_back_addr : addr_type;
  signal to_write_back_funct: funct_type; signal to_write_back_opcode: opcode_type;
  signal to_write_back_pc: pc_data_type; signal to_write_back_shamt: shift_amount_type;
  signal to_write_back_result: word_data_type;

  signal stall_flag : boolean;
  signal branch_flash_flag : boolean;

  signal decode_flash_flag : boolean;
  signal exec_flash_flag : boolean;
  signal memory_flash_flag : boolean;
  signal write_back_flash_flag : boolean;

  signal is_reset : boolean;
  signal logic_reset : std_logic;
  signal startup_reset : boolean := true;
begin
-- <% project_define_component_mappings %>

-- COMPONENT MAPPING BLOCK BEGIN {{{
program_counter_comp: program_counter
  port map(
      write_data => program_counter_write_data,
pc => program_counter_pc,
pc_write => program_counter_pc_write,
reset => program_counter_reset,
clk => clk
       )
;

ex_path_comp: ex_path
  port map(
      order => ex_path_order,
pc => ex_path_pc,
flash_flag => ex_path_flash_flag,
int_rd1 => ex_path_int_rd1,
int_rd2 => ex_path_int_rd2,
float_rd1 => ex_path_float_rd1,
float_rd2 => ex_path_float_rd2,
pc_jump => ex_path_pc_jump,
result_data => ex_path_result_data,
result_order => ex_path_result_order,
address => ex_path_address,
exec_orders => ex_path_exec_orders,
jump_enable => ex_path_jump_enable,
clk => clk
       )
;

memory_path_comp: memory_path
  port map(
      order => memory_path_order,
exec_addr => memory_path_exec_addr,
exec_data => memory_path_exec_data,
result_data => memory_path_result_data,
result_order => memory_path_result_order,
sram_write_data => memory_path_sram_write_data,
sram_read_data => memory_path_sram_read_data,
io_write_data => memory_path_io_write_data,
io_read_data => memory_path_io_read_data,
sram_addr => memory_path_sram_addr,
sram_cmd => memory_path_sram_cmd,
io_write_cmd => memory_path_io_write_cmd,
io_read_cmd => memory_path_io_read_cmd,
io_write_success => memory_path_io_write_success,
io_read_success => memory_path_io_read_success,
io_read_fault => memory_path_io_read_fault,
io_write_fault => memory_path_io_write_fault,
inst_ram_write_data => memory_path_inst_ram_write_data,
inst_ram_write_addr => memory_path_inst_ram_write_addr,
inst_ram_write_enable => memory_path_inst_ram_write_enable,
memory_orders => memory_path_memory_orders,
flash_flag => memory_path_flash_flag,
clk => clk
       )
;

write_back_path_comp: write_back_path
  port map(
      order => write_back_path_order,
memory_data => write_back_path_memory_data,
reg_write_data => write_back_path_reg_write_data,
reg_write_addr => write_back_path_reg_write_addr,
io_success => write_back_path_io_success,
ireg_write_enable => write_back_path_ireg_write_enable,
freg_write_enable => write_back_path_freg_write_enable,
clk => clk
       )
;

pipeline_controller_comp: pipeline_controller
  port map(
      decode_order => pipeline_controller_decode_order,
exec_pipe => pipeline_controller_exec_pipe,
memory_pipe => pipeline_controller_memory_pipe,
write_back_order => pipeline_controller_write_back_order,
input_forwardings_mem => pipeline_controller_input_forwardings_mem,
input_forwardings_wb => pipeline_controller_input_forwardings_wb,
is_data_hazard => pipeline_controller_is_data_hazard
       )
;

ex_handler: trap_handler
  port map(
      is_io_read_inst_excepiton => ex_handler_is_io_read_inst_excepiton,
is_io_write_inst_excepiton => ex_handler_is_io_write_inst_excepiton,
is_device_trap => ex_handler_is_device_trap,
exec_pc => ex_handler_exec_pc,
memory_pc => ex_handler_memory_pc,
wb_pc => ex_handler_wb_pc,
is_exception => ex_handler_is_exception,
trap_jump_pc => ex_handler_trap_jump_pc,
save_pc => ex_handler_save_pc,
flash_decode => ex_handler_flash_decode,
flash_to_exec => ex_handler_flash_to_exec,
flash_to_memory => ex_handler_flash_to_memory,
flash_wb => ex_handler_flash_wb
       )
;

i_register: register_file
  port map(
      a1 => i_register_a1,
a2 => i_register_a2,
a3 => i_register_a3,
rd1 => i_register_rd1,
rd2 => i_register_rd2,
wd3 => i_register_wd3,
trap_pc_we => i_register_trap_pc_we,
trap_pc_data => i_register_trap_pc_data,
we3 => i_register_we3,
clk => clk
       )
;

f_register: register_file_float
  port map(
      a1 => f_register_a1,
a2 => f_register_a2,
a3 => f_register_a3,
rd1 => f_register_rd1,
rd2 => f_register_rd2,
wd3 => f_register_wd3,
we3 => f_register_we3,
clk => clk
       )
;

st_controller: structual_hazards_controller
  port map(
      decode_order => st_controller_decode_order,
is_data_hazard => st_controller_is_data_hazard,
pipeline_rest_length => st_controller_pipeline_rest_length,
ex_pipeline_rest_length => st_controller_ex_pipeline_rest_length,
is_hazard => st_controller_is_hazard,
next_pipeline_rest_length => st_controller_next_pipeline_rest_length,
next_ex_pipeline_rest_length => st_controller_next_ex_pipeline_rest_length
       )
;

-- COMPONENT MAPPING BLOCK END }}}
  -------------------
  -- fetch
  -------------------
  program_counter_write_data <= ex_handler_trap_jump_pc when ex_handler_is_exception else
                                ex_path_pc_jump when ex_path_jump_enable else
                                pc_increment;

  pc_increment <= std_logic_vector(unsigned(program_counter_pc) + 1);

  stall_flag <= pipeline_controller_is_data_hazard or
                st_controller_is_hazard;

  program_counter_pc_write <= '1' when not stall_flag or ex_handler_is_exception or ex_path_jump_enable
                              else '0';

  logic_reset <= '1' when is_reset else '0';
  program_counter_reset <= reset or logic_reset;

  inst_ram_read_addr <= program_counter_pc;

  phase_fetch_to_decode: process(clk) begin
    if rising_edge(clk) then
      if decode_flash_flag then
        to_decode_order <= (others => '0');
        to_decode_pc <= (others => '0');
      elsif not stall_flag then
        to_decode_order <= inst_ram_read_data;
        to_decode_pc <= program_counter_pc;
      end if;
    end if;
  end process;
  -------------------
  -- decode
  -------------------
  i_register_a1 <= rs_of_order(to_decode_order);
  i_register_a2 <= rt_of_order(to_decode_order);

  f_register_a1 <= rs_of_order(to_decode_order);
  f_register_a2 <= rt_of_order(to_decode_order);

  decode_int_rd1 <= i_register_wd3 when pipeline_controller_input_forwardings_wb.int1 else
                    memory_path_result_data when pipeline_controller_input_forwardings_mem.int1 else
                    i_register_rd1;

  decode_int_rd2 <= i_register_wd3 when pipeline_controller_input_forwardings_wb.int2 else
                    memory_path_result_data when pipeline_controller_input_forwardings_mem.int2 else
                    i_register_rd2;

  decode_float_rd1 <= f_register_wd3 when pipeline_controller_input_forwardings_wb.float1 else
                      memory_path_result_data when pipeline_controller_input_forwardings_mem.float1 else
                      f_register_rd1;

  decode_float_rd2 <= f_register_wd3 when pipeline_controller_input_forwardings_wb.float2 else
                      memory_path_result_data when pipeline_controller_input_forwardings_mem.float2 else
                      f_register_rd2;

  phase_decode_to_ex: process(clk) begin
    if rising_edge(clk) then
      if exec_flash_flag or stall_flag then
        to_ex_order <= (others => '0');
        to_ex_pc <= (others => '0');

        to_ex_int_rd1 <= (others => '0');
        to_ex_int_rd2 <= (others => '0');

        to_ex_float_rd1 <= (others => '0');
        to_ex_float_rd2 <= (others => '0');
      else
        to_ex_order <= to_decode_order;
        to_ex_pc <= to_decode_pc;

        to_ex_int_rd1 <= decode_int_rd1;
        to_ex_int_rd2 <= decode_int_rd2;

        to_ex_float_rd1 <= decode_float_rd1;
        to_ex_float_rd2 <= decode_float_rd2;
      end if;
    end if;
  end process;

  -------------------
  -- execute
  -------------------
  ex_path_flash_flag <= exec_flash_flag;

  ex_path_order <= to_ex_order;
  ex_path_pc <= to_ex_pc;

  ex_path_int_rd1 <= to_ex_int_rd1;
  ex_path_int_rd2 <= to_ex_int_rd2;

  ex_path_float_rd1 <= to_ex_float_rd1;
  ex_path_float_rd2 <= to_ex_float_rd2;

  -- TODO: use branch_hazard_controller
  branch_flash_flag <= ex_path_jump_enable;

  phase_ex_to_mem: process(clk) begin
    if rising_edge(clk) then
      if memory_flash_flag then
        to_memory_order <= (others => '0');
        to_memory_pc <= (others => '0');

        to_memory_result <= (others => '0');
      else
        to_memory_order <= ex_path_result_order;
        to_memory_pc <= ex_path_pc;

        to_memory_result <= ex_path_result_data;
        to_memory_addr <= ex_path_address;
      end if;
    end if;
  end process;

  -------------------
  -- memory
  -------------------
  memory_path_flash_flag <= memory_flash_flag;

  io_write_cmd <= memory_path_io_write_cmd;
  io_write_data <= memory_path_io_write_data;
  io_read_cmd <= memory_path_io_read_cmd;
  memory_path_io_read_data <= io_read_data;

  sram_cmd <= memory_path_sram_cmd;
  sram_addr <= memory_path_sram_addr;
  sram_write_data <= memory_path_sram_write_data;

  memory_path_sram_read_data <= sram_read_data;

  memory_path_order <= to_memory_order;

  memory_path_exec_data <= to_memory_result;
  memory_path_exec_addr <= to_memory_addr;

  memory_path_io_read_success <= io_read_success;
  memory_path_io_write_success <= io_write_success;

  inst_ram_write_data <= memory_path_inst_ram_write_data;
  inst_ram_write_addr <= memory_path_inst_ram_write_addr;
  inst_ram_write_enable <= memory_path_inst_ram_write_enable;

  phase_mem_to_wb: process(clk) begin
    if rising_edge(clk) then
      if write_back_flash_flag then
        -- to_write_back_pc <= (others => '0');
        to_write_back_order <= (others => '0');
        to_write_back_result <= (others => '0');
      else
        to_write_back_order <= memory_path_result_order;
        to_write_back_result <= memory_path_result_data;
      end if;
    end if;
  end process;

  -------------------
  -- write back
  -------------------
  write_back_path_order <= to_write_back_order;
  write_back_path_memory_data <= to_write_back_result;

  i_register_a3 <= write_back_path_reg_write_addr;
  f_register_a3 <= write_back_path_reg_write_addr;

  i_register_wd3 <= write_back_path_reg_write_data;
  f_register_wd3 <= write_back_path_reg_write_data;

  i_register_we3 <= write_back_path_ireg_write_enable;
  f_register_we3 <= write_back_path_freg_write_enable;

  -------------------
  -- controls
  -------------------
  pipeline_controller_decode_order <= to_decode_order;
  pipeline_controller_exec_pipe <= ex_path_exec_orders;
  pipeline_controller_memory_pipe <= memory_path_memory_orders;
  pipeline_controller_write_back_order <= write_back_path_order;

  st_controller_decode_order <= to_decode_order;
  st_controller_is_data_hazard <= pipeline_controller_is_data_hazard;

  is_reset <= (reset = '1') or startup_reset;
  decode_flash_flag <= branch_flash_flag or is_reset or ex_handler_flash_decode;
  exec_flash_flag <= branch_flash_flag or is_reset or ex_handler_flash_to_exec;
  memory_flash_flag <= is_reset or ex_handler_flash_to_memory;
  write_back_flash_flag <= is_reset or ex_handler_flash_wb;

  ex_handler_is_io_read_inst_excepiton <= memory_path_io_read_fault;
  ex_handler_is_io_write_inst_excepiton <= memory_path_io_write_fault;

  ex_handler_exec_pc <= to_ex_pc;
  ex_handler_memory_pc <= to_memory_pc;
  -- ex_handler_wb_pc <= to_write_back_pc;

  i_register_trap_pc_we <= ex_handler_is_exception;
  i_register_trap_pc_data <= "00" & ex_handler_save_pc;

  startup: process(clk) begin
    if rising_edge(clk) then
      startup_reset <= false;
    end if;
  end process;

  hazard_pipe: process(clk) begin
    if rising_edge(clk) then
      st_controller_pipeline_rest_length <=
       st_controller_next_pipeline_rest_length;
      st_controller_ex_pipeline_rest_length <=
       st_controller_next_ex_pipeline_rest_length;
    end if;
  end process;
end behave;

