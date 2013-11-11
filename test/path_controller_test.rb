require_relative "../utils/state_ctl_helper"

VhdlTestScript.scenario "../src/path_controller.vhd" do
  dependencies "../src/const/const_state.vhd", "../src/const/const_mux.vhd",
    "../src/const/const_sram_cmd.vhd", "../src/const/const_io.vhd",
    "../src/const/const_alu_ctl.vhd", "../src/const/record_state_ctl.vhd"

  states = []
  states << state_fetch = NemipsState.new("state_fetch",
    alu_op: "alu_op_add", wd_src: "wd_src_pc", inst_or_data: "iord_inst",
    pc_src: "pc_src_alu", inst_write: 1, pc_write: 1)

  states << state_decode = NemipsState.new("state_decode",
    alu_op: "alu_op_add", alu_srcA: "alu_srcA_pc", alu_srcB: "alu_srcB_imm_sft2")

  states << state_memadr = NemipsState.new("state_memadr",
    alu_op: "alu_op_add", alu_srcA: "alu_srcA_rd1", alu_srcB: "alu_srcB_imm")

  states << state_memadrx = NemipsState.new("state_memadrx",
    alu_op: "alu_op_add", alu_srcA: "alu_srcA_rd1", alu_srcB: "alu_srcB_rd2",
    a2_src_rd: 1)

  states << state_mem_read = NemipsState.new("state_mem_read",
    inst_or_data: "iord_data", sram_cmd: "sram_cmd_read")

  states << state_mem_write = NemipsState.new("state_mem_write",
    inst_or_data: "iord_data", mem_write: 1, sram_cmd: "sram_cmd_write")

  states << state_mem_writex = NemipsState.new("state_mem_writex",
    inst_or_data: "iord_data", mem_write: 1, sram_cmd: "sram_cmd_write")

  states << state_mem_wb = NemipsState.new("state_mem_wb",
    regdist: "regdist_rt", wd_src: "wd_src_mem",
    ireg_write: 1)

  states << state_mem_wbx = NemipsState.new("state_mem_wbx",
    regdist: "regdist_rd", wd_src: "wd_src_mem",
    ireg_write: 1)

  states << state_io_read = NemipsState.new("state_io_read_w",
    io_read_cmd: "io_length_word", go_src: "go_src_io_read")

  states << state_io_wb = NemipsState.new("state_io_wb",
    regdist: "regdist_rd", wd_src: "wd_src_io", ireg_write: 1)

  states << state_io_write = NemipsState.new("state_io_write_w",
    io_write_cmd: "io_length_word", go_src: "go_src_io_write")

  states << state_alu = NemipsState.new("state_alu",
    alu_srcA: "alu_srcA_rd1",
    alu_srcB: "alu_srcB_rd2",
    alu_op: "alu_op_decode")

  states << state_alu_wb = NemipsState.new("state_alu_wb",
    wd_src: "wd_src_alu_past", regdist: "regdist_rd", ireg_write: 1)

  states << state_alu_imm = NemipsState.new("state_alu_imm",
    alu_srcA: "alu_srcA_rd1",
    alu_srcB: "alu_srcB_imm",
    alu_op: "alu_op_decode")

  states << state_alu_zimm = NemipsState.new("state_alu_zimm",
    alu_srcA: "alu_srcA_rd1",
    alu_srcB: "alu_srcB_zimm",
    alu_op: "alu_op_decode")

  states << state_alu_imm_wb = NemipsState.new("state_alu_imm_wb",
    wd_src: "wd_src_alu_past", regdist: "regdist_rt", ireg_write: 1)

  states << state_branch = NemipsState.new("state_branch",
    alu_srcA: "alu_srcA_rd1",
    alu_srcB: "alu_srcB_rd2",
    alu_op: "alu_op_decode",
    pc_branch: 1)

  states << state_jal = NemipsState.new("state_jal",
    wd_src: "wd_src_pc", regdist: "regdist_ra",
    pc_src: "pc_src_jta",
    ireg_write: 1, pc_write: 1)

  states << state_jal = NemipsState.new("state_jalr",
    wd_src: "wd_src_pc", regdist: "regdist_ra",
    pc_src: "pc_src_alu",
    ireg_write: 1, pc_write: 1)

  states << state_jmp = NemipsState.new("state_jmp",
    pc_src: "pc_src_jta",
    pc_write: 1)

  states << state_jmpr = NemipsState.new("state_jmpr",
    pc_src: "pc_src_alu",
    pc_write: 1)

  states.each {|state| step state.to_hash}

end
