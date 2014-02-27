library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_state.all;
use work.const_mux.all;
use work.const_alu_ctl.all;
use work.const_fpu_ctl.all;
use work.const_io.all;
use work.const_opcode.all;
use work.const_sram_cmd.all;
use work.const_pipeline_state.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

use work.decode_order_functions.all;
use work.order_utils.all;
use work.pipeline_types.all;

-- <%- require_relative 'src/project_helper' -%>

-- <%- project_components %w(exec_state_decoder) -%>
-- <%- project_components %w(alu alu_decoder) -%>
-- <%- project_components %w(fpu_controller sub_fpu fpu_decoder) -%>
-- <%- project_components %w(branch_condition_checker) -%>

entity ex_path is
  port(
        order: in order_type;
        pc: in pc_data_type;

        flash_flag : in boolean;

        int_rd1: in word_data_type;
        int_rd2: in word_data_type;
        float_rd1: in word_data_type;
        float_rd2: in word_data_type;

        pc_jump: out pc_data_type;
        result_data: out word_data_type;
        result_order: out word_data_type;
        address: out mem_addr_type;

        exec_orders: out exec_orders_type;
        jump_enable: out boolean;

        clk : in std_logic
      );
end ex_path;

architecture behave of ex_path is
-- COMPONENT DEFINITION BLOCK BEGIN {{{
component exec_state_decoder


  port(
      opcode : in opcode_type;
funct : in funct_type;
state : out exec_state_type
       );

end component;


component alu


  port(
      a : in word_data_type;
b : in word_data_type;
alu_ctl : in alu_ctl_type;
result : out word_data_type;
clk : in std_logic
       );

end component;


component alu_decoder


  port(
      opcode : in opcode_type;
funct : in funct_type;
alu_op : in alu_op_type;
alu_ctl : out alu_ctl_type
       );

end component;


component fpu_controller


  port(
      a : in std_logic_vector(31 downto 0);
b : in std_logic_vector(31 downto 0);
fpu_ctl : in fpu_ctl_type;
result : out std_logic_vector(31 downto 0);
clk : in std_logic
       );

end component;


component sub_fpu


  port(
      a : in std_logic_vector(31 downto 0);
b : in std_logic_vector(31 downto 0);
fpu_ctl : in fpu_ctl_type;
result : out std_logic_vector(31 downto 0);
done : out std_logic;
clk : in std_logic
       );

end component;


component fpu_decoder


  port(
      opcode : in std_logic_vector(5 downto 0);
funct : in std_logic_vector(5 downto 0);
fpu_ctl : out fpu_ctl_type
       );

end component;


component branch_condition_checker


  port(
      rs : in word_data_type;
rt : in word_data_type;
i_op : in opcode_type;
branch_go : out std_logic
       );

end component;


-- COMPONENT DEFINITION BLOCK END }}}
-- SIGNAL BLOCK BEGIN {{{
  signal exec_state_decoder_opcode : opcode_type;
signal exec_state_decoder_funct : funct_type;
signal exec_state_decoder_state : exec_state_type;

  signal alu_a : word_data_type;
signal alu_b : word_data_type;
signal alu_alu_ctl : alu_ctl_type;
signal alu_result : word_data_type;
signal alu_clk : std_logic;

  signal alu_decoder_opcode : opcode_type;
signal alu_decoder_funct : funct_type;
signal alu_decoder_alu_op : alu_op_type;
signal alu_decoder_alu_ctl : alu_ctl_type;

  signal fpu_controller_a : std_logic_vector(31 downto 0);
signal fpu_controller_b : std_logic_vector(31 downto 0);
signal fpu_controller_fpu_ctl : fpu_ctl_type;
signal fpu_controller_result : std_logic_vector(31 downto 0);
signal fpu_controller_clk : std_logic;

  signal sub_fpu_a : std_logic_vector(31 downto 0);
signal sub_fpu_b : std_logic_vector(31 downto 0);
signal sub_fpu_fpu_ctl : fpu_ctl_type;
signal sub_fpu_result : std_logic_vector(31 downto 0);
signal sub_fpu_done : std_logic;
signal sub_fpu_clk : std_logic;

  signal fpu_decoder_opcode : std_logic_vector(5 downto 0);
signal fpu_decoder_funct : std_logic_vector(5 downto 0);
signal fpu_decoder_fpu_ctl : fpu_ctl_type;

  signal branch_condition_checker_rs : word_data_type;
signal branch_condition_checker_rt : word_data_type;
signal branch_condition_checker_i_op : opcode_type;
signal branch_condition_checker_branch_go : std_logic;

-- SIGNAL BLOCK END }}}
  constant zero : word_data_type := (others => '0');

  signal fst_result_data: word_data_type;
  signal fst_result_order: order_type;

  signal pc_increment: pc_data_type;
  signal pc_bta, pc_jta: pc_data_type;

  signal calc_input1, calc_input2: word_data_type;

  signal fpu_A, fpu_B: word_data_type;
  signal alu_ctl: alu_ctl_type;
  signal fpu_ctl: fpu_ctl_type;
  signal signex_imm: word_data_type;

  signal word_of_address : word_data_type;
  signal pc_of_signex_imm: pc_data_type;

  signal opcode : opcode_type;
  signal funct : funct_type;
  signal shamt : shift_amount_type;
  signal imm : immediate_type;

  signal fpu_tag_in: request_tag_type;
  signal fpu_tag_out: request_tag_type;
  signal sub_fpu_tag_in: request_tag_type;
  signal sub_fpu_tag_out: request_tag_type;

  signal ex_state: exec_state_type;
  signal ex_go_src: ex_go_src_type;
  signal ex_calc_srcB: calc_srcB_type;

  signal branch, branch_go: std_logic;
  signal pc_rs_write, pc_jta_write: std_logic;

  signal pipe_buffer: exec_pipe_buffer_type := (others => init_exec_record);

  signal exec_orders_fpu, exec_orders_fst, exec_orders_normal : exec_orders_type;
begin
--  <% project_define_component_mappings(as: { opcode: 'opcode', funct: 'funct', alu_ctl: 'alu_ctl', fpu_ctl: 'fpu_ctl', i_op: 'opcode' }) %>

-- COMPONENT MAPPING BLOCK BEGIN {{{
exec_state_decoder_comp: exec_state_decoder
  port map(
      opcode => opcode,
funct => funct,
state => exec_state_decoder_state
       )
;

alu_comp: alu
  port map(
      a => alu_a,
b => alu_b,
alu_ctl => alu_ctl,
result => alu_result,
clk => clk
       )
;

alu_decoder_comp: alu_decoder
  port map(
      opcode => opcode,
funct => funct,
alu_op => alu_decoder_alu_op,
alu_ctl => alu_ctl
       )
;

fpu_controller_comp: fpu_controller
  port map(
      a => fpu_controller_a,
b => fpu_controller_b,
fpu_ctl => fpu_ctl,
result => fpu_controller_result,
clk => clk
       )
;

sub_fpu_comp: sub_fpu
  port map(
      a => sub_fpu_a,
b => sub_fpu_b,
fpu_ctl => fpu_ctl,
result => sub_fpu_result,
done => sub_fpu_done,
clk => clk
       )
;

fpu_decoder_comp: fpu_decoder
  port map(
      opcode => opcode,
funct => funct,
fpu_ctl => fpu_ctl
       )
;

branch_condition_checker_comp: branch_condition_checker
  port map(
      rs => branch_condition_checker_rs,
rt => branch_condition_checker_rt,
i_op => opcode,
branch_go => branch_condition_checker_branch_go
       )
;

-- COMPONENT MAPPING BLOCK END }}}

  opcode <= opcode_of_order(order);
  funct <= funct_of_order(order);
  imm <= imm_of_order(order);
  shamt <= shamt_of_order(order);

  pc_of_signex_imm <= signex_imm(29 downto 0);
  pc_increment <= std_logic_vector(unsigned(pc) + 1);

  pc_bta <= std_logic_vector(unsigned(pc_increment) + unsigned(pc_of_signex_imm));
  pc_jta(29 downto 26) <= pc(29 downto 26);
  pc_jta(25 downto  0) <= address_of_order(order);
  word_of_address <= std_logic_vector(unsigned(signex_imm) + unsigned(int_rd1));
  address <= word_of_address(19 downto 0);

  branch_condition_checker_rs <= int_rd1;
  branch_condition_checker_rt <= int_rd2;

  fpu_controller_a <= float_rd1;
  fpu_controller_b <= float_rd2;
  sub_fpu_a <= float_rd1;
  sub_fpu_b <= float_rd2;

  alu_a <= int_rd1;

  with exec_state_decoder_state select
    pc_jump <= pc_bta when exec_state_branch,
               pc_jta when exec_state_jmp,
               int_rd1(29 downto 0) when exec_state_jmpr,
               pc when others;

  with exec_state_decoder_state select
    jump_enable <= (branch_condition_checker_branch_go = '1') when exec_state_branch,
                   true when exec_state_jmp | exec_state_jmpr,
                   false when others;

  with exec_state_decoder_state select
    alu_b <= int_rd2 when exec_state_alu | exec_state_branch,
             signex_imm when exec_state_alu_imm,
             x"0000" & imm when exec_state_alu_zimm,
             x"000000" & "000" & shamt when exec_state_alu_shift,
             (others => '0') when others;

  signex_imm(31 downto 16) <= (others => imm(15));
  signex_imm(15 downto  0) <= imm;

  process(clk) begin
    if rising_edge(clk) then
      if flash_flag then
        -- flash pipeline
        for i in 0 to (pipe_buffer'length - 1) loop
          pipe_buffer(i) <= init_exec_record;
        end loop;
      else
        -- save pipeline
        case exec_state_decoder_state is
          when exec_state_fpu =>
            pipe_buffer(0).order <= order;
            pipe_buffer(0).state <= exec_state_decoder_state;
            pipe_buffer(0).pc <= pc;
          when others =>
            pipe_buffer(0) <= init_exec_record;
        end case;

        for i in 1 to (pipe_buffer'length - 1) loop
          pipe_buffer(i) <= pipe_buffer(i - 1);
        end loop;
      end if;
    end if;
  end process;

  with exec_state_decoder_state select
    fst_result_data <= alu_result when exec_state_alu | exec_state_alu_shift |
                                       exec_state_alu_imm | exec_state_alu_zimm,
                       int_rd1    when exec_state_io_wait,
                       float_rd1  when exec_state_io_wait_f,
                       int_rd2    when exec_state_mem_addr,
                       float_rd2  when exec_state_mem_addr_f,
                       sub_fpu_result when exec_state_sub_fpu,
                       "00" & pc_increment when exec_state_jmp | exec_state_jmpr,
                       zero when others;

  with exec_state_decoder_state select
    fst_result_order <= (others => '0') when exec_state_fpu,
                        order when others;

  with pipe_buffer(pipe_buffer'length - 1).state select
    result_order <= pipe_buffer(pipe_buffer'length - 1).order when exec_state_fpu,
                    fst_result_order when others;

  with pipe_buffer(pipe_buffer'length - 1).state select
    result_data <= fpu_controller_result when exec_state_fpu,
                   fst_result_data when others;

  with exec_state_decoder_state select
    exec_orders <= exec_orders_fpu when exec_state_fpu,
                   exec_orders_fst when others;

  with pipe_buffer(pipe_buffer'length - 1).state select
    exec_orders_fst <= exec_orders_fpu when exec_state_fpu,
                       exec_orders_normal when others;

  process(pipe_buffer, order) begin
    exec_orders_fpu(0) <= order;
    for i in 0 to (pipe_buffer'length - 1) loop
      exec_orders_fpu(i + 1) <= pipe_buffer(i).order;
    end loop;

    for i in 0 to (pipe_buffer'length - 1) loop
      exec_orders_normal(i) <= pipe_buffer(i).order;
    end loop;
    exec_orders_normal(2) <= order;
  end process;
end behave;

