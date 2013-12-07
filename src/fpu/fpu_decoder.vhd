library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_state.all;
use work.const_opcode.all;
use work.const_fpu_ctl.all;

entity fpu_decoder is
  port(
        opcode: in std_logic_vector(5 downto 0);
        funct: in std_logic_vector(5 downto 0);

        fpu_ctl: out fpu_ctl_type
      );
end fpu_decoder;

architecture behave of fpu_decoder is
  signal fpu_ctl_f_group : fpu_ctl_type;
begin
  with opcode select
    fpu_ctl <= fpu_ctl_f_group when i_op_f_group,
               fpu_ctl_none when i_op_fmvi,
               fpu_ctl_none when others;

  with funct select
    fpu_ctl_f_group <= fpu_ctl_fadd when f_op_fadd,
                       fpu_ctl_fmul when f_op_fmul,
                       fpu_ctl_finv when f_op_finv,
                       fpu_ctl_fsqrt when f_op_fsqrt,
                       fpu_ctl_fabs when f_op_fabs,
                       fpu_ctl_fneg when f_op_fneg,
                       fpu_ctl_fcseq when f_op_fcseq,
                       fpu_ctl_fclt when f_op_fclt,
                       fpu_ctl_fcle when f_op_fcle,
                       fpu_ctl_none when others;

end behave;
