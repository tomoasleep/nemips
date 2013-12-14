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
        rs: in register_addr_type;
        rt: in register_addr_type;
        rd: in register_addr_type;

        opcode: in opcode_type;
        funct: in opcode_type;

        shamt: in shift_amount_type;
        imm: in immediate_type;
        addr: in addr_type;

        int_rd1: in word_data_type;
        int_rd2: in word_data_type;

        float_rd1: in word_data_type;
        float_rd2: in word_data_type;

        pc: in pc_data_type;
        write_enable: in std_logic;
        reset: in std_logic;

        is_break: out std_logic;
        result: out word_data_type;
        go: out std_logic;

        clk : in std_logic
      );
end ex_path;

architecture behave of ex_path is
  constant zero : word_data_type := (others => '0');

  signal ex_pc_increment: pc_data_type;
  signal pc_bta: pc_data_type;

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

  signal to_ex_reset: std_logic;
  signal to_ex_rs, to_ex_rt, to_ex_rd: register_addr_type;
  signal to_ex_imm  : immediate_type;
  signal to_ex_addr : addr_type;
  signal to_ex_funct: funct_type;
  signal to_ex_opcode: opcode_type;
  signal to_ex_pc: pc_data_type;
  signal to_ex_shamt: shift_amount_type;
  signal to_ex_int_rd1, to_ex_int_rd2: word_data_type;
  signal to_ex_float_rd1, to_ex_float_rd2: word_data_type;

  signal ex_state: exec_state_type;
  signal ex_result_src: ex_result_src_type;
  signal ex_go_src: ex_go_src_type;
  signal ex_calc_srcB: calc_srcB_type;


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
          result_src: out  ex_result_src_type
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
begin
  phase_decode_to_ex: process(clk) begin
    if rising_edge(clk) then
      if reset = '1' then
        to_ex_rs <= (others => '0');
        to_ex_rt <= (others => '0');
        to_ex_rd <= (others => '0');

        to_ex_imm <= (others => '0');
        to_ex_addr <= (others => '0');

        to_ex_opcode <= (others => '0');
        to_ex_shamt <= (others => '0');
        to_ex_shamt <= (others => '0');

        to_ex_pc <= (others => '0');
      elsif write_enable = '1' then
        to_ex_rs <= rs;
        to_ex_rt <= rt;
        to_ex_rd <= rd;

        to_ex_imm <= imm;
        to_ex_addr <= addr;

        to_ex_opcode <=opcode;
        to_ex_funct <= funct;
        to_ex_shamt <= shamt;

        to_ex_pc <= pc;

        to_ex_int_rd1 <= int_rd1;
        to_ex_int_rd2 <= int_rd2;

        to_ex_float_rd1 <= float_rd1;
        to_ex_float_rd2 <= float_rd2;
      end if;
    end if;
  end process;

  ex_pc_increment <= std_logic_vector(unsigned(to_ex_pc) + 1);
  pc_bta <= std_logic_vector(unsigned(ex_pc_increment) + unsigned(signex_imm));

  fpu_A <= to_ex_float_rd1;
  fpu_B <= to_ex_float_rd2;

  calc_input1 <= to_ex_int_rd1;

  with ex_calc_srcB select
    calc_input2 <= to_ex_int_rd1 when calc_srcB_rd2,
                   signex_imm when calc_srcB_imm,
                   x"0000" & to_ex_imm when calc_srcB_zimm,
                   x"000000" & "000" & to_ex_shamt when others;

  with ex_result_src select
    result <= alu_result when ex_result_src_alu,
                       fpu_result when ex_result_src_fpu,
                       sub_fpu_result when ex_result_src_sub_fpu,
                       zero when others;

  ex_path_ctl: exec_ctl port map(
    state => ex_state,
    calc_srcB => ex_calc_srcB,
    go_src => ex_go_src,
    result_src => ex_result_src);

  ex_decoder: exec_state_decoder port map(
    opcode => to_ex_opcode,
    funct => to_ex_funct,
    state => ex_state);

  palu_decoder: alu_decoder port map(
    opcode=>to_ex_opcode,
    funct=>to_ex_funct,
    alu_ctl=>alu_ctl);

  pfpu_decoder: fpu_decoder port map(
    opcode => to_ex_opcode,
    funct => to_ex_funct,
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

