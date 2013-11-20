library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_state.all;
use work.const_mux.all;
use work.const_sram_cmd.all;
use work.const_io.all;

use work.record_state_ctl.all;

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
        go_src:   out go_src_type;
        alu_srcA: out alu_srcA_type;
        alu_srcB: out alu_srcB_type;
        sram_cmd: out sram_cmd_type;
        io_write_cmd: out io_length_type;
        io_read_cmd: out io_length_type;
        mem_write: out std_logic;
        pc_write: out std_logic;
        pc_branch: out std_logic;
        ireg_write: out std_logic;
        freg_write: out std_logic;
        inst_write: out std_logic;
        a2_src_rd: out std_logic;
        is_break: out std_logic
      );
end path_controller;

architecture behave of path_controller is
  signal state_ctl : record_state_ctl := state_fetch_ctl;
begin

  with state select
    state_ctl <= state_fetch_ctl when state_fetch,
                 state_decode_ctl when state_decode,
                 state_memadr_ctl when state_memadr,
                 state_memadrx_ctl when state_memadrx,
                 state_mem_read_ctl when state_mem_read,
                 state_mem_read_wait_ctl when state_mem_read_wait,
                 state_mem_write_ctl when state_mem_write,
                 state_mem_writex_ctl when state_mem_writex,
                 state_mem_wb_ctl when state_mem_wb,
                 state_mem_wbx_ctl when state_mem_wbx,
                 state_io_read_w_ctl when state_io_read_w,
                 state_io_wb_ctl when state_io_wb,
                 state_io_write_w_ctl when state_io_write_w,
                 state_alu_ctl when state_alu,
                 state_alu_wb_ctl when state_alu_wb,
                 state_alu_imm_ctl when state_alu_imm,
                 state_alu_zimm_ctl when state_alu_zimm,
                 state_alu_imm_wb_ctl when state_alu_imm_wb,
                 state_branch_ctl when state_branch,
                 state_jal_ctl when state_jal,
                 state_jalr_ctl when state_jalr,
                 state_jmp_ctl when state_jmp,
                 state_jmpr_ctl when state_jmpr,
                 state_break_ctl when state_break,
                 state_alu_sft_ctl when state_alu_sft,
                 state_io_read_b_ctl when state_io_read_b,
                 state_io_read_h_ctl when state_io_read_h,
                 state_io_write_b_ctl when state_io_write_b,
                 state_io_write_h_ctl when state_io_write_h,
                 state_fetch_ctl when others;

  alu_op <= state_ctl.alu_op;
  wd_src <= state_ctl.wd_src;
  regdist <= state_ctl.regdist;
  inst_or_data <= state_ctl.inst_or_data;
  sram_cmd <= state_ctl.sram_cmd;
  pc_src <= state_ctl.pc_src;
  alu_srcA <= state_ctl.alu_srcA;
  alu_srcB <= state_ctl.alu_srcB;
  go_src <= state_ctl.go_src;
  inst_write <= state_ctl.inst_write;
  pc_write <= state_ctl.pc_write;
  mem_write <= state_ctl.mem_write;
  ireg_write <= state_ctl.ireg_write;
  pc_branch <= state_ctl.pc_branch;
  mem_write <= state_ctl.mem_write;
  ireg_write <= state_ctl.ireg_write;
  pc_branch <= state_ctl.pc_branch;
  a2_src_rd <= state_ctl.a2_src_rd;
  is_break <= state_ctl.is_break;
  io_read_cmd <= state_ctl.io_read_cmd;
  io_write_cmd <= state_ctl.io_write_cmd;
end behave;
