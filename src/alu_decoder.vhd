library ieee;
use ieee.std_logic_1164.all;

library work;
use work.const_alu_ctl.all;
use work.const_alusrc.all;
use work.const_opcode.all;

-- DOCTEST DEPENDENCIES: const/const_opcode.vhd, const/const_alu_ctl.vhd, const/const_alusrc.vhd

entity alu_decoder is
  port(
        opcode: in std_logic_vector(5 downto 0);
        funct : in std_logic_vector(5 downto 0);
        alu_op : in std_logic_vector(1 downto 0);

        alu_ctl : out std_logic_vector(5 downto 0)
      );
end alu_decoder;

architecture behave of alu_decoder is
begin
  process(opcode, funct, alu_op) begin
    case alu_op is
      when alu_op_decode =>
        case opcode is
          when i_op_r_group =>
            case funct is
              when r_fun_sll | r_fun_sllv =>
                alu_ctl <= alu_ctl_lshift_l;
              when r_fun_srl | r_fun_srlv =>
                alu_ctl <= alu_ctl_lshift_r;
              when r_fun_sra | r_fun_srav =>
                alu_ctl <= alu_ctl_ashift_r;
              when r_fun_add | r_fun_addu =>
                alu_ctl <= alu_ctl_add;
              when r_fun_sub | r_fun_subu =>
                alu_ctl <= alu_ctl_sub;
              when r_fun_mul =>
                alu_ctl <= alu_ctl_mul;
              when r_fun_mulu =>
                alu_ctl <= alu_ctl_mulu;
              when r_fun_div =>
                alu_ctl <= alu_ctl_div;
              when r_fun_divu =>
                alu_ctl <= alu_ctl_divu;
              when r_fun_and =>
                alu_ctl <= alu_ctl_and;
              when r_fun_or =>
                alu_ctl <= alu_ctl_or;
              when r_fun_xor =>
                alu_ctl <= alu_ctl_xor;
              when r_fun_nor =>
                alu_ctl <= alu_ctl_nor;
              when r_fun_slt =>
                alu_ctl <= alu_ctl_slt;
              when r_fun_sltu =>
                alu_ctl <= alu_ctl_sltu;
              when r_fun_jr | r_fun_jalr =>
                alu_ctl <= alu_ctl_select_a;
              when r_fun_mthi =>
                alu_ctl <= alu_ctl_mthi;
              when r_fun_mtlo =>
                alu_ctl <= alu_ctl_mtlo;
              when r_fun_mfhi =>
                alu_ctl <= alu_ctl_mfhi;
              when r_fun_mflo =>
                alu_ctl <= alu_ctl_mflo;
              when others =>
            end case;

          when i_op_beq =>
            alu_ctl <= alu_ctl_seq;
          when i_op_bne =>
            alu_ctl <= alu_ctl_sne;
          when i_op_blez => -- i_op_bgtz 
            alu_ctl <= alu_ctl_cmpz_legt;
          when i_op_bltz => -- i_op_bgez 
            alu_ctl <= alu_ctl_cmpz_ltge;
          when i_op_slti =>
            alu_ctl <= alu_ctl_slt;
          when i_op_sltiu =>
            alu_ctl <= alu_ctl_sltu;
          when i_op_andi =>
            alu_ctl <= alu_ctl_and;
          when i_op_ori =>
            alu_ctl <= alu_ctl_or;
          when i_op_xori =>
            alu_ctl <= alu_ctl_xor;
          when i_op_io =>
            alu_ctl <= alu_ctl_select_a;
          when others =>
        end case;
      when alu_op_add =>
        alu_ctl <= alu_ctl_add;
      when others =>
    end case;
  end process;
end behave;

