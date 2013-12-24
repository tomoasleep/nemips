library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_state.all;
use work.const_opcode.all;
use work.const_pipeline_state.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

entity exec_decoder is
  port(
        opcode: in opcode_type;
        funct: in funct_type;

        exec_state: out exec_state_type
      );
end exec_decoder;

architecture behave of exec_decoder is
  signal exec_state_r_op: exec_state_type;
  signal exec_state_f_op: exec_state_type;
begin
  with opcode select
    exec_state <= exec_state_r_op     when i_op_r_group,
                  exec_state_f_op     when i_op_f_group,
                  exec_state_nop      when i_op_io,
                  exec_state_alu      when i_op_beq | i_op_bne
                                       | i_op_bltz | i_op_bgez
                                       | i_op_blez | i_op_bgtz
                                       | i_op_imvf,
                  exec_state_jmp      when j_op_j | j_op_jal,
                  exec_state_alu_zimm when i_op_addiu | i_op_sltiu
                                       | i_op_andi | i_op_ori
                                       | i_op_xori,
                  exec_state_sub_fpu  when i_op_fmvi,
                  exec_state_break    when i_op_break,
                  exec_state_nop      when others;

  with funct select
    state_r_op <= exec_state_jmpr      when r_fun_jr | r_fun_jalr,
                  exec_state_alu       when r_fun_mul | r_fun_mulu
                                          | r_fun_div | r_fun_divu,
                  exec_state_nop       when r_fun_lwx | r_fun_swx,
                  exec_state_alu_shift when r_fun_sll | r_fun_srl
                                          | r_fun_sra,
                  exec_state_alu       when others;

  with funct select
    state_f_op <= exec_state_fpu      when f_op_fadd | f_op_finv
                                         | f_op_fmul | f_op_fsqrt,
                  exec_state_sub_fpu  when f_op_fabs | f_op_fneg
                                         | f_op_fcseq
                                         | f_op_fcle | f_op_fclt,
                  exec_state_fetch    when others;

end behave;
