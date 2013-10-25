library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_state.all;
use work.const_mux.all;

entity path_controller is
  port(
        opcode: in std_logic_vector(5 downto 0);
        funct : in std_logic_vector(5 downto 0);
        state : in state_type;

        alu_op:  out alu_op_type;
        wd_src:  out wd_src_type;
        regdist: out regdist_type;
        inst_or_data: out iord_type;
        pc_src:   out pc_src_type;
        alu_srcA: out alu_srcA_type;
        alu_srcB: out alu_srcB_type;
        mem_write: out std_logic;
        pc_write: out std_logic;
        pc_branch: out std_logic;
        ireg_write: out std_logic;
        freg_write: out std_logic;
        inst_write: out std_logic;
        a2_src_rd: out std_logic;
        io_write: out std_logic;
        io_read: out std_logic
      );
end path_controller;

architecture behave of path_controller is
begin
  main: process(state) begin
    case state is
      when state_fetch =>
        alu_srcA <= alu_srcA_pc;
        alu_srcB <= alu_srcB_const4;
        alu_op <= alu_op_add;
        pc_src <= pc_src_alu;
        inst_or_data <= iord_inst;
        wd_src <= wd_src_pc;
      when state_decode =>
        alu_srcA <= alu_srcA_pc;
        alu_srcB <= alu_srcB_imm_sft2;
        alu_op <= alu_op_add;
      when state_memadr =>
        alu_srcA <= alu_srcA_rd1;
        alu_srcB <= alu_srcB_imm;
        alu_op <= alu_op_add;
      when state_mem_read =>
        inst_or_data <= iord_data;
      when state_mem_write =>
        inst_or_data <= iord_data;
      when state_mem_wb =>
        wd_src <= wd_src_mem;
        regdist <= regdist_rt;
      when state_mem_wbf =>
        wd_src <= wd_src_mem;
      when state_alu =>
        alu_srcA <= alu_srcA_rd1;
        alu_srcB <= alu_srcB_rd2;
        alu_op <= alu_op_decode;
      when state_alu_imm =>
        alu_srcA <= alu_srcA_rd1;
        alu_srcB <= alu_srcB_imm;
        alu_op <= alu_op_decode;
      when state_alu_wb =>
        wd_src <= wd_src_alu_past;
        regdist <= regdist_rd;
      when state_alu_imm_wb =>
        wd_src <= wd_src_alu_past;
        regdist <= regdist_rt;
      when state_branch =>
        alu_srcA <= alu_srcA_rd1;
        alu_srcB <= alu_srcB_rd2;
        alu_op <= alu_op_decode;
        pc_src <= pc_src_bta;
      when state_jmp =>
        pc_src <= pc_src_jta;
      when state_jal =>
        pc_src <= pc_src_jta;
        regdist <= regdist_ra;
        wd_src <= wd_src_pc;
      when state_jmpr =>
        pc_src <= pc_src_alu;
      when state_jalr =>
        pc_src <= pc_src_alu;

        regdist <= regdist_ra;
        wd_src <= wd_src_pc;
      when others =>
    end case;

    -- memory and register write flag
    case state is
      when state_alu_wb | state_alu_imm_wb
      | state_mem_wb =>
        mem_write <= '0';
        ireg_write <= '1';
        freg_write <= '0';
      when state_mem_write =>
        mem_write <= '1';
        ireg_write <= '0';
        freg_write <= '0';
      when state_mem_wbf =>
        mem_write <= '0';
        ireg_write <= '0';
        freg_write <= '1';
      when state_jal | state_jalr =>
        mem_write <= '0';
        ireg_write <= '1';
        freg_write <= '0';
      when others =>
        mem_write <= '0';
        ireg_write <= '0';
        freg_write <= '0';
    end case;

    -- pc write flag
    case state is
      when state_fetch
      | state_jmp | state_jmpr
      | state_jal | state_jalr =>
        pc_write <= '1';
        pc_branch <= '0';
      when state_branch =>
        pc_branch <= '1';
        pc_write <= '0';
      when others =>
        pc_write <= '0';
        pc_branch <= '0';
    end case;

    -- pc write flag
    case state is
      when state_fetch =>
        inst_write <= '1';
      when others =>
        inst_write <= '0';
    end case;
  end process;
end behave;



