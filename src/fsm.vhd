library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_state.all;
use work.const_opcode.all;

-- DOCTEST DEPENDENCIES: const/const_state.vhd, const/const_opcode.vhd
-- TEST
-- /TEST

entity fsm is
  port(
        opcode: in std_logic_vector(5 downto 0);
        funct: in std_logic_vector(5 downto 0);
        alu_bool_result: in std_logic;
        reset: in std_logic;

        state: out state_type;
        clk : in std_logic
      );
end fsm;

architecture behave of fsm is
  signal opcode_r: std_logic_vector(5 downto 0) := "000000";
  signal funct_r:  std_logic_vector(5 downto 0) := "000000";
  signal current_state: state_type;
begin
  main: process(clk) begin
    if rising_edge(clk) then
      case reset is
        when '1' =>
          current_state <= state_fetch;
          opcode_r <= "000000";
          funct_r <= "000000";
        when others =>

          case current_state is
            when state_fetch =>
              current_state <= state_decode;

            when state_decode =>
              opcode_r <= opcode;
              funct_r  <= funct;

              case opcode is
                when i_op_r_group =>
                  case funct is
                    when r_fun_jr =>
                      current_state <= state_jmpr;
                    when r_fun_jalr =>
                      current_state <= state_jalr;
                    when r_fun_mul | r_fun_mulu
                    | r_fun_div | r_fun_divu =>
                      current_state <= state_alu;
                    when others =>
                      current_state <= state_alu;
                  end case;
                when i_op_beq | i_op_bne | i_op_bltz -- i_op_bgez, i_op_blez
                | i_op_bgtz =>
                  current_state <= state_branch;
                when i_op_lb | i_op_lh | i_op_lw
                | i_op_sb | i_op_sh | i_op_sw
                | i_op_lwf | i_op_swf =>
                  current_state <= state_memadr;
                when j_op_j =>
                  current_state <= state_jmp;
                when j_op_jal =>
                  current_state <= state_jal;
                when others =>
                  current_state <= state_alu_imm;
              end case;

            when state_memadr =>
              case opcode_r is
                when i_op_lb | i_op_lh | i_op_lw
                | i_op_lwf =>
                  current_state <= state_mem_read;
                when i_op_sb | i_op_sh | i_op_sw
                | i_op_swf =>
                  current_state <= state_mem_write;
                when others =>
                  current_state <= state_fetch;
              end case;

            when state_mem_read =>
              case opcode_r is
                when i_op_lb | i_op_lh | i_op_lw =>
                  current_state <= state_mem_wb;
                when i_op_lwf =>
                  current_state <= state_mem_wbf;
                when others =>
                  current_state <= state_fetch;
              end case;

            when state_alu =>
              case funct_r is
                when r_fun_mul | r_fun_mulu
                | r_fun_div | r_fun_divu =>
                  current_state <= state_fetch;
                when others =>
                  current_state <= state_alu_wb;
              end case;

            when state_alu_imm =>
              current_state <= state_alu_imm_wb;

            when others =>
              current_state <= state_fetch;

          end case;
      end case;
    end if;
  end process;

  state <= current_state;
end behave;

