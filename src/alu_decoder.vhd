library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_alu_ctl.all;
use work.const_mux.all;
use work.const_opcode.all;

entity alu_decoder is
  port(
        opcode: in std_logic_vector(5 downto 0);
        funct : in std_logic_vector(5 downto 0);
        alu_op : in alu_op_type;

        alu_ctl : out alu_ctl_type
      );
end alu_decoder;

architecture behave of alu_decoder is
  signal r_fun_alu_ctl : alu_ctl_type;
  signal i_op_alu_ctl : alu_ctl_type;
begin
  with funct select
    r_fun_alu_ctl <= alu_ctl_lshift_l when r_fun_sll | r_fun_sllv,
               alu_ctl_lshift_r when r_fun_srl | r_fun_srlv,
               alu_ctl_ashift_r when r_fun_sra | r_fun_srav,
               alu_ctl_add when r_fun_add | r_fun_addu,
               alu_ctl_sub when r_fun_sub | r_fun_subu,
               alu_ctl_mul when r_fun_mul,
               alu_ctl_mulu when r_fun_mulu,
               alu_ctl_div when r_fun_div,
               alu_ctl_divu when r_fun_divu,
               alu_ctl_and when r_fun_and,
               alu_ctl_or when r_fun_or,
               alu_ctl_xor when r_fun_xor,
               alu_ctl_nor when r_fun_nor,
               alu_ctl_slt when r_fun_slt,
               alu_ctl_sltu when r_fun_sltu,
               alu_ctl_select_a when r_fun_jr | r_fun_jalr,
               alu_ctl_mthi when r_fun_mthi,
               alu_ctl_mtlo when r_fun_mtlo,
               alu_ctl_mfhi when r_fun_mfhi,
               alu_ctl_mflo when r_fun_mflo,
               alu_ctl_lshift_l when others;

  with opcode select
    i_op_alu_ctl <= r_fun_alu_ctl when i_op_r_group,
               alu_ctl_seq when i_op_beq,
               alu_ctl_sne when i_op_bne,
               alu_ctl_cmpz_le when i_op_blez,
               alu_ctl_cmpz_lt when i_op_bltz,
               alu_ctl_cmpz_gt when i_op_bgtz,
               alu_ctl_cmpz_ge when i_op_bgez, -- i_op_bgez,
               alu_ctl_add when i_op_addi | i_op_addiu,
               alu_ctl_slt when i_op_slti,
               alu_ctl_sltu when i_op_sltiu,
               alu_ctl_and when i_op_andi,
               alu_ctl_or when i_op_ori,
               alu_ctl_xor when i_op_xori,
               alu_ctl_select_a when i_op_io,
               alu_ctl_lshift_l when others;
  
  with alu_op select
    alu_ctl <= alu_ctl_add when alu_op_add,
               i_op_alu_ctl when others;
end behave;

