library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_opcode.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

entity branch_condition_checker is
  port(
      rs: in word_data_type;
      rt: in word_data_type;
      i_op: in opcode_type;
      branch_go: out std_logic
      );
end branch_condition_checker;

architecture behave of branch_condition_checker is
  signal is_eq: std_logic;
  signal is_ltz: std_logic;
  signal is_lez: std_logic;

  signal branch_check: std_logic;
begin
  is_eq <= '1' when rs = rt else '0';
  is_ltz <= '1' when signed(rs) < 0 else '0';
  is_lez <= '1' when signed(rs) <= 0 else '0';

  with i_op select
    branch_check <= is_eq      when i_op_beq,
                    not is_eq  when i_op_bne,
                    is_ltz     when i_op_bltz,
                    not is_ltz when i_op_bgez,
                    is_lez     when i_op_blez,
                    not is_lez when i_op_bgtz,
                    '0'        when others;

  branch_go <= branch_check;
end behave;

