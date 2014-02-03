library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_state.all;
use work.const_opcode.all;
use work.const_pipeline_state.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

entity fsm is
  port(
        opcode: in opcode_type;
        funct: in funct_type;

        state: out state_type
      );
end fsm;

architecture behave of fsm is
  signal state_update: state_type := state_fetch;

  signal state_from_decode: state_type := state_fetch;
  signal state_from_decode_r_op: state_type := state_fetch;
  signal state_from_decode_f_op: state_type := state_fetch;
  signal state_from_decode_io: state_type := state_fetch;
  signal state_from_memadrx: state_type := state_fetch;
  signal state_from_memadr: state_type := state_fetch;
  signal state_from_mem_read_wait: state_type := state_fetch;
  signal state_from_mem_read_wait_r_op: state_type := state_fetch;
  signal state_from_alu: state_type := state_fetch;
  signal state_from_alu_r_op: state_type := state_fetch;
  signal state_from_sub_fpu: state_type := state_fetch;
begin
  with current_state select
    state_update <= state_decode              when state_fetch,
                    state_from_decode         when state_decode,
                    state_from_memadr         when state_memadr,
                    state_from_memadrx        when state_memadrx,
                    state_from_mem_read_wait  when state_mem_read_wait,
                    state_from_alu            when state_alu | state_alu_sft,
                    state_mem_read_wait       when state_mem_read,
                    state_io_wb               when state_io_read_w
                                                 | state_io_read_h
                                                 | state_io_read_b,
                    state_alu_imm_wb          when state_alu_imm | state_alu_zimm,
                    state_fpu_wb              when state_fpu,
                    state_from_sub_fpu        when state_sub_fpu,
                    state_fetch               when others;


  with opcode select
    state_from_decode <= state_from_decode_r_op when i_op_r_group,
                         state_from_decode_f_op when i_op_f_group,
                         state_from_decode_io   when i_op_io,
                         state_branch           when i_op_beq | i_op_bne
                                                   | i_op_bltz | i_op_bgez
                                                   | i_op_blez | i_op_bgtz,
                         state_memadr           when i_op_lw | i_op_sw
                                                   | i_op_sprogram
                                                   | i_op_lwf | i_op_swf,
                         state_jmp              when j_op_j,
                         state_jal              when j_op_jal,
                         state_alu_zimm         when i_op_addiu | i_op_sltiu
                                                   | i_op_andi | i_op_ori
                                                   | i_op_xori,
                         state_alu              when i_op_imvf,
                         state_sub_fpu          when i_op_fmvi,
                         state_break            when i_op_break,
                         state_alu_imm          when others;

  with funct select
    state_from_decode_io <= state_io_read_w when io_fun_iw,
                            state_io_read_b when io_fun_ib,
                            state_io_read_h when io_fun_ih,
                            state_io_write_w when io_fun_ow,
                            state_io_write_b when io_fun_ob,
                            state_io_write_h when io_fun_oh,
                            state_alu_imm when others;

  with funct select
    state_from_decode_r_op <= state_jmpr    when r_fun_jr,
                              state_jalr    when r_fun_jalr,
                              state_alu     when r_fun_mul | r_fun_mulu
                                                | r_fun_div | r_fun_divu,
                              state_memadrx when r_fun_lwx | r_fun_swx,
                              state_alu_sft when r_fun_sll | r_fun_srl
                                                | r_fun_sra,
                              state_alu     when others;

  with funct select
    state_from_decode_f_op <= state_fpu      when f_op_fadd | f_op_finv
                                                | f_op_fmul | f_op_fsqrt,
                              state_sub_fpu  when f_op_fabs | f_op_fneg
                                                | f_op_fcseq
                                                | f_op_fcle | f_op_fclt,
                              state_fetch    when others;

  with funct select
    state_from_memadrx <= state_mem_read when r_fun_lwx,
                          state_mem_writex when r_fun_swx,
                          state_fetch when others;

  with opcode select
    state_from_memadr <= state_mem_read when i_op_lw | i_op_lwf,
                    state_mem_write when i_op_sw | i_op_swf,
                    state_program_write when i_op_sprogram,
                    state_fetch when others;

  with opcode select
    state_from_mem_read_wait <= state_mem_wb when i_op_lw | i_op_lwf,
                                state_from_mem_read_wait_r_op when i_op_r_group,
                                state_fetch when others;

  with funct select
    state_from_mem_read_wait_r_op <= state_mem_wbx when r_fun_lwx,
                                     state_fetch when others;

  with funct select
    state_from_alu_r_op <= state_fetch    when r_fun_mul | r_fun_mulu
                                             | r_fun_div | r_fun_divu,
                           state_alu_wb   when others;

  with opcode select
    state_from_alu <= state_from_alu_r_op when i_op_r_group,
                      state_imvf_wb       when i_op_imvf,
                      state_fetch         when others;

  with opcode select
    state_from_sub_fpu <= state_sub_fpu_wb  when i_op_f_group,
                          state_fmvi_wb     when i_op_fmvi,
                          state_fetch       when others;

  state <= current_state;
end behave;
