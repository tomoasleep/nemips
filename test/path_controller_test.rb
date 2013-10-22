VhdlTestScript.scenario "../src/path_controller.vhd" do
  ports :state, :alu_op, :wd_src, :regdist, :inst_or_data, :pc_src, :alu_srcA, :alu_srcB
  dependencies "../src/const/const_state.vhd",
    "../src/const/const_alusrc.vhd"

  step "state_fetch", "alu_op_add", "wd_src_pc", _, "iord_inst", "pc_src_alu", _, _

  step "state_decode", "alu_op_add", _, _, _, _, "alu_srcA_pc", "alu_srcB_imm_sft2"
  step "state_memadr", "alu_op_add", _, _, _, _, "alu_srcA_rd1", "alu_srcB_imm"

  step state: "state_mem_read",
    inst_or_data: "iord_data"

  step state: "state_mem_wb",
    regdist: "regdist_rt",
    wd_src: "wd_src_mem"

  step state: "state_mem_write",
    inst_or_data: "iord_data"

  step state: "state_alu",
    alu_srcA: "alu_srcA_rd1",
    alu_srcB: "alu_srcB_rd2",
    alu_op: "alu_op_decode"

  step state: "state_alu_wb",
    wd_src: "wd_src_alu_past"

  step state: "state_branch",
    alu_srcA: "alu_srcA_rd1",
    alu_srcB: "alu_srcB_rd2",
    alu_op: "alu_op_decode"

  step state: "state_alu_imm",
    alu_srcA: "alu_srcA_rd1",
    alu_srcB: "alu_srcB_imm",
    alu_op: "alu_op_decode"

  step state: "state_alu_imm_wb",
    wd_src: "wd_src_alu_past"

  step state: "state_jmp",
    pc_src: "pc_src_jta"


  enable_flag_map = {
    state_fetch: ["inst_write", "pc_write"],
    state_decode: [],
    state_memadr: [],
    state_mem_read: [],
    state_mem_write: ["mem_write"],
    state_alu: [],
    state_alu_wb: ["ireg_write"],
    state_alu_imm: [],
    state_alu_imm_wb: ["ireg_write"],
    state_branch: ["pc_branch"],
    state_jmp: ["pc_write"]
  }

  flags = "inst_write", "pc_write", "mem_write", "ireg_write", "pc_branch"

  enable_flag_map.each do |k, v|
    stepd = Hash[flags.zip(Array.new(5, 0))]
    stepd[:state] = k.to_s
    v.each do |name|
      stepd[name] = 1
    end
    step stepd
  end


end
