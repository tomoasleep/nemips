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
-- <%- project_components :register_file, as: :i_register -%>
-- <%- project_components :register_file_float, as: :f_register -%>

entity path is
  port(
        io_read_data : in word_data_type;
        io_read_ready: in std_logic;
        io_write_ready: in std_logic;

        mem_read_data: in word_data_type;
        mem_read_ready : in std_logic;
        reset : in std_logic;
        inst_ram_read_data : in order_type;

        io_write_data: out word_data_type;
        io_write_cmd: out io_length_type;
        io_read_cmd: out io_length_type;
        inst_ram_write_addr : out pc_data_type;
        inst_ram_read_addr : out pc_data_type;

        inst_ram_write_enable : out std_logic;
        inst_ram_write_data : out order_type;
        mem_write_data : out word_data_type;
        mem_addr: out word_data_type;
        sram_cmd: out sram_cmd_type;

        sram_tag: in request_tag_type;
        io_tag: in request_tag_type;

        is_break: out std_logic;
        continue: in std_logic;
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
       )

;
end component;


component ex_path


  port(
      order : in order_type;
pc : in pc_data_type;
rd1 : in word_data_type;
rd2 : in word_data_type;
pc_jump : out pc_data_type;
result_data : out word_data_type;
result_order : out word_data_type;
address : out addr_type;
exec_pipe_buffer : out exec_pipe_buffer_type;
jump_enable_enable : out std_logic;
clk : in std_logic
       )

;
end component;


component memory_path


  port(
      order : in order_type;
addr : in addr_type;
pc_jump : in pc_data_type;
exec_addr : in addr_type;
exec_data : in word_data_type;
result_data : out word_data_type;
result_order : out order_type;
sram_write_data : out word_data_type;
sram_read_data : in word_data_type;
io_write_data : out word_data_type;
io_read_data : in word_data_type;
sram_addr : out addr_type;
sram_cmd : out sram_cmd_type;
io_write_cmd : out io_length_type;
io_read_cmd : out io_length_type;
io_read_success : in std_logic;
io_write_success : in std_logic;
io_success : out std_logic;
memory_pipe_buffer : out memory_pipe_buffer_type;
clk : in std_logic
       )

;
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
       )

;
end component;


component register_file


  port(
      a1 : in register_addr_type;
a2 : in register_addr_type;
a3 : in register_addr_type;
rd1 : out word_data_type;
rd2 : out word_data_type;
wd3 : in word_data_type;
we3 : in std_logic;
clk : in std_logic
       )

;
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
       )

;
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
signal ex_path_rd1 : word_data_type;
signal ex_path_rd2 : word_data_type;
signal ex_path_pc_jump : pc_data_type;
signal ex_path_result_data : word_data_type;
signal ex_path_result_order : word_data_type;
signal ex_path_address : addr_type;
signal ex_path_exec_pipe_buffer : exec_pipe_buffer_type;
signal ex_path_jump_enable_enable : std_logic;
signal ex_path_clk : std_logic;

  signal memory_path_order : order_type;
signal memory_path_addr : addr_type;
signal memory_path_pc_jump : pc_data_type;
signal memory_path_exec_addr : addr_type;
signal memory_path_exec_data : word_data_type;
signal memory_path_result_data : word_data_type;
signal memory_path_result_order : order_type;
signal memory_path_sram_write_data : word_data_type;
signal memory_path_sram_read_data : word_data_type;
signal memory_path_io_write_data : word_data_type;
signal memory_path_io_read_data : word_data_type;
signal memory_path_sram_addr : addr_type;
signal memory_path_sram_cmd : sram_cmd_type;
signal memory_path_io_write_cmd : io_length_type;
signal memory_path_io_read_cmd : io_length_type;
signal memory_path_io_read_success : std_logic;
signal memory_path_io_write_success : std_logic;
signal memory_path_io_success : std_logic;
signal memory_path_memory_pipe_buffer : memory_pipe_buffer_type;
signal memory_path_clk : std_logic;

  signal write_back_path_order : order_type;
signal write_back_path_memory_data : word_data_type;
signal write_back_path_reg_write_data : word_data_type;
signal write_back_path_reg_write_addr : register_addr_type;
signal write_back_path_io_success : std_logic;
signal write_back_path_ireg_write_enable : std_logic;
signal write_back_path_freg_write_enable : std_logic;
signal write_back_path_clk : std_logic;

  signal i_register_a1 : register_addr_type;
signal i_register_a2 : register_addr_type;
signal i_register_a3 : register_addr_type;
signal i_register_rd1 : word_data_type;
signal i_register_rd2 : word_data_type;
signal i_register_wd3 : word_data_type;
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

-- SIGNAL BLOCK END }}}
  signal pc: pc_data_type;

  signal mem_write, ctl_pc_write, ireg_write_enable, freg_write_enable: std_logic;
  signal alu_bool_result, inst_write, pc_branch: std_logic;
  signal fpu_done, sub_fpu_done: std_logic;
  signal a2_src_rd: std_logic;
  signal fsm_go : std_logic;
  signal pctl_inst_ram_write_enable : std_logic;

  signal past_alu_result : word_data_type := (others => '0');
  signal past_fpu_result : word_data_type := (others => '0');
  signal past_sub_fpu_result : word_data_type := (others => '0');
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
  signal mem_state: mem_state_type;
  signal write_back_state: write_back_state_type;

  signal to_decode_reset, to_ex_reset, to_mem_reset, to_write_back_reset: std_logic;
  signal to_decode_write_enable, to_ex_write_enable: std_logic;
  signal to_mem_write_enable, to_write_back_write_enable: std_logic;

  signal to_decode_pc: pc_data_type;
  signal to_decode_order: word_data_type;

  signal to_ex_pc: pc_data_type;
  signal to_ex_order, from_ex_order: order_type;
  signal to_ex_int_rd1, to_ex_int_rd2: word_data_type;
  signal to_ex_float_rd1, to_ex_float_rd2: word_data_type;
  signal tag_data, tag_ok: request_tag_type;

  signal to_mem_order: order_type;
  signal to_mem_rs, to_mem_rt, to_mem_rd: register_addr_type;
  signal to_mem_imm  : immediate_type; signal to_mem_addr : addr_type;
  signal to_mem_funct: funct_type; signal to_mem_opcode: opcode_type;
  signal to_mem_pc: pc_data_type; signal to_mem_shamt: shift_amount_type;
  signal to_mem_result: word_data_type;
  signal phase_ex_result: word_data_type;

  signal to_write_back_rs, to_write_back_rt, to_write_back_rd: register_addr_type;
  signal to_write_back_imm  : immediate_type; signal to_write_back_addr : addr_type;
  signal to_write_back_funct: funct_type; signal to_write_back_opcode: opcode_type;
  signal to_write_back_pc: pc_data_type; signal to_write_back_shamt: shift_amount_type;
  signal to_write_back_result: word_data_type;
  signal phase_mem_result: word_data_type;

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
rd1 => ex_path_rd1,
rd2 => ex_path_rd2,
pc_jump => ex_path_pc_jump,
result_data => ex_path_result_data,
result_order => ex_path_result_order,
address => ex_path_address,
exec_pipe_buffer => ex_path_exec_pipe_buffer,
jump_enable_enable => ex_path_jump_enable_enable,
clk => clk
       )
;

memory_path_comp: memory_path
  port map(
      order => memory_path_order,
addr => memory_path_addr,
pc_jump => memory_path_pc_jump,
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
io_read_success => memory_path_io_read_success,
io_write_success => memory_path_io_write_success,
io_success => memory_path_io_success,
memory_pipe_buffer => memory_path_memory_pipe_buffer,
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

i_register: register_file
  port map(
      a1 => i_register_a1,
a2 => i_register_a2,
a3 => i_register_a3,
rd1 => i_register_rd1,
rd2 => i_register_rd2,
wd3 => i_register_wd3,
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

-- COMPONENT MAPPING BLOCK END }}}
  -------------------
  -- fetch
  -------------------
  with pc_src select
    program_counter_write_data <= pc_bta when pc_src_bta,
                                  pc_jta when pc_src_jta,
                                  pc_increment when others; -- pc_src_increment

  pc_increment <= std_logic_vector(unsigned(program_counter_pc) + 1);
  program_counter_reset <= reset;

  inst_ram_read_addr <= program_counter_pc;

  phase_fetch_to_decode: process(clk) begin
    if rising_edge(clk) then
      if to_decode_reset = '1' then
        to_decode_order <= (others => '0');
        to_decode_pc <= (others => '0');
      elsif to_decode_write_enable = '1' then
        to_decode_order <= inst_ram_read_data;
        to_decode_pc <= pc_increment;
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

  phase_decode_to_ex: process(clk) begin
    if rising_edge(clk) then
      if reset = '1' then
        to_ex_order <= (others => '0');
        to_ex_pc <= (others => '0');

        to_ex_int_rd1 <= (others => '0');
        to_ex_int_rd2 <= (others => '0');

        to_ex_float_rd1 <= (others => '0');
        to_ex_float_rd2 <= (others => '0');

        tag_data <= std_logic_vector(unsigned(tag_data) + 1);
      elsif to_ex_write_enable = '1' then
        to_ex_order <= to_decode_order;
        to_ex_pc <= to_decode_pc;

        to_ex_int_rd1 <= i_register_rd1;
        to_ex_int_rd2 <= i_register_rd2;

        to_ex_float_rd1 <= f_register_rd1;
        to_ex_float_rd2 <= f_register_rd2;

        tag_data <= std_logic_vector(unsigned(tag_data) + 1);
      end if;
    end if;
  end process;

  -------------------
  -- execute
  -------------------

  io_write_cmd <= io_length_none when ex_path_go = '1' else
                  ex_path_io_write_command;

  io_read_cmd <= io_length_none when ex_path_go = '1' else
                 ex_path_io_read_command;

  sram_cmd <= ex_path_sram_command;

  inst_ram_write_addr <= ex_path_mem_addr(31 downto 2);
  mem_addr <= ex_path_mem_addr;

  mem_write_data <= to_exec_int_rd2;
  inst_ram_write_data <= to_exec_int_rd2;
  io_write_data <=  to_exec_int_rd1;

  inst_ram_write_enable <= ex_path_inst_ram_write_enable;

  with ex_path_ex_result_src select
    tag_check <= ex_path_tag_out when ex_result_src_alu | 
                                      ex_result_src_fpu |
                                      ex_result_src_sub_fpu,
                 sram_tag_in when ex_result_src_mem,
                 io_tag_in when ex_result_src_io,
                 tag_data when others;

  tag_ok <= '1' when tag_check = tag_data else '0';

  phase_ex_to_mem: process(clk) begin
    if rising_edge(clk) then
      if to_mem_reset = '1' then
        to_write_back_order <= (others => '0');
        to_write_back_pc <= (others => '0');

        to_write_back_result <= (others => '0');
      elsif to_mem_write_enable = '1' then
        write_back_decoder_order <= to_exec_order;
        to_write_back_pc <= to_exec_pc;

        to_write_back_result <= ex_path_result;
      end if;
    end if;
  end process;

  -------------------
  -- write back
  -------------------

  program_counter_pc_write <= '1' when ctl_pc_write = '1' else '0';

  reg_a2 <= decoder_d when a2_src_rd = '1' else
            decoder_t;

  with regdist select
    reg_a3 <= to_write_back_rt when regdist_rt,
              to_write_back_rd when regdist_rd,
              reg_ra when others; --- when regdist = regdist_ra;

  with write_back_ctl_wd_src select
    ireg_wdata <= to_write_back_result when write_back_wd_src_result,
                  to_write_back_pc     when others;
  freg_wdata <= to_write_back_result;

  ireg_write_enable <= write_back_int_we;
  freg_write_enable <= write_back_float_we;

end behave;

