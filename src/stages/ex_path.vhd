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

entity ex_path is
  port(
        opcode: in opcode_type;
        funct : in funct_type;

        imm  : in immediate_type;
        shamt : in shift_amount_type;

        int_rd1: in word_data_type;
        int_rd2: in word_data_type;

        float_rd1: in word_data_type;
        float_rd2: in word_data_type;

        pc: in pc_data_type;
        tagdata: in request_tag_type;

        result: out word_data_type;
        go: out std_logic;
        pc_bta: out pc_data_type;

        clk : in std_logic
      );
end ex_path;

architecture behave of ex_path is
  constant zero : word_data_type := (others => '0');

  signal ex_pc_increment: pc_data_type;

  signal calc_input1, calc_input2: word_data_type;
  signal fpu_A, fpu_B: word_data_type;
  signal alu_ctl: alu_ctl_type;
  signal fpu_ctl: fpu_ctl_type;
  signal alu_result, signex_imm: word_data_type;
  signal fpu_result, sub_fpu_result: word_data_type;

  signal fpu_tag_in: request_tag_type;
  signal fpu_tag_out: request_tag_type;
  signal sub_fpu_tag_in: request_tag_type;
  signal sub_fpu_tag_out: request_tag_type;

  signal ex_state: exec_state_type;
  signal ex_result_src: ex_result_src_type;
  signal ex_go_src: ex_go_src_type;
  signal ex_calc_srcB: calc_srcB_type;

  signal branch, branch_go: std_logic;
  signal pc_rs_write, pc_jta_write: std_logic;

  component decoder
    port(
          instr: in order_type;

          rs_reg : out register_addr_type;
          rt_reg : out register_addr_type;
          rd_reg : out register_addr_type;
          address : out addr_type;
          imm    : out immediate_type;

          opcode : out opcode_type;
          funct  : out funct_type;
          shamt  : out shift_amount_type
        );
  end component;

  component exec_state_decoder
    port(
          opcode: in opcode_type;
          funct : in funct_type;
          state : out exec_state_type
        );
  end component;

  component exec_ctl
    port(
          state : in exec_state_type;
          calc_srcB: out  calc_srcB_type;
          go_src: out  ex_go_src_type;
          result_src: out  ex_result_src_type;
          pc_rs_write: out  std_logic;
          pc_jta_write: out  std_logic;
          branch: out  std_logic
        );
  end component;

 component sign_extender
    port(
          imm    : in immediate_type;
          ex_imm : out word_data_type
        );
  end component;

  component alu
    port(
          a : in word_data_type;
          b : in word_data_type;
          alu_ctl: in alu_ctl_type;

          result : out word_data_type;
          clk : in std_logic
        );
  end component;

  component alu_decoder
    port(
          opcode: in opcode_type;
          funct : in funct_type;
          alu_ctl : out alu_ctl_type
        );
  end component;

  component fpu_controller
    port(
          a: in word_data_type;
          b: in word_data_type;
          fpu_ctl: in fpu_ctl_type;

          tag_in: in request_tag_type;
          tag_out: out request_tag_type;

          result: out word_data_type;
          clk : in std_logic
        );
  end component;

  component sub_fpu
    port(
          a: in word_data_type;
          b: in word_data_type;
          fpu_ctl: in fpu_ctl_type;

          tag_in: in request_tag_type;
          tag_out: out request_tag_type;

          result: out word_data_type;
          clk : in std_logic
        );
  end component;

  component fpu_decoder is
    port(
          opcode: in opcode_type;
          funct: in funct_type;

          fpu_ctl: out fpu_ctl_type
        );
  end component;

  component branch_condition_checker is
    port(
          rs: in word_data_type;
          rt: in word_data_type;
          i_op: in opcode_type;
          enable: in std_logic;
          branch_go: out std_logic
        );
  end component;
begin
  ex_pc_increment <= std_logic_vector(unsigned(pc) + 1);
  pc_bta <= std_logic_vector(unsigned(ex_pc_increment) + unsigned(signex_imm));

  fpu_A <= float_rd1;
  fpu_B <= float_rd2;

  calc_input1 <= int_rd1;

  with ex_calc_srcB select
    calc_input2 <= int_rd1 when calc_srcB_rd2,
                   signex_imm when calc_srcB_imm,
                   x"0000" & imm when calc_srcB_zimm,
                   x"000000" & "000" & shamt when others;

  signex_imm(31 downto 16) <= (others => imm(15));
  signex_imm(15 downto  0) <= imm;

  with ex_result_src select
    result <= alu_result when ex_result_src_alu,
              fpu_result when ex_result_src_fpu,
              sub_fpu_result when ex_result_src_sub_fpu,
              zero when others;


  ex_path_ctl: exec_ctl port map(
    state => ex_state,
    calc_srcB => ex_calc_srcB,
    go_src => ex_go_src,
    result_src => ex_result_src,
    pc_rs_write => pc_rs_write,
    pc_jta_write => pc_jta_write,
    branch => branch
  );

  branch_ctl: branch_condition_checker port map(
        rs => int_rd1,
        rt => int_rd2,
        i_op => opcode,
        enable => branch,
        branch_go => branch_go);

  ex_decoder: exec_state_decoder port map(
    opcode => opcode,
    funct => funct,
    state => ex_state);

  palu_decoder: alu_decoder port map(
    opcode=>opcode,
    funct=>funct,
    alu_ctl=>alu_ctl);

  pfpu_decoder: fpu_decoder port map(
    opcode => opcode,
    funct => funct,
    fpu_ctl => fpu_ctl
  );

  palu: alu port map (
    a=>calc_input1,
    b=>calc_input2,
    alu_ctl=>alu_ctl,
    result=>alu_result,
    clk=>clk);

  pfpu: fpu_controller port map(
    a=>calc_input1,
    b=>calc_input2,
    fpu_ctl=>fpu_ctl,
    result=>fpu_result,
    tag_in=>fpu_tag_in,
    tag_out=>fpu_tag_out,
    clk=>clk);

  psub_fpu: sub_fpu port map(
    a=>calc_input1,
    b=>calc_input2,
    fpu_ctl=>fpu_ctl,
    result=>sub_fpu_result,
    tag_in=>sub_fpu_tag_in,
    tag_out=>sub_fpu_tag_out,
    clk=>clk);
end behave;

