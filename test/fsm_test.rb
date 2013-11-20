VhdlTestScript.scenario "../src/fsm.vhd" do
  ports :opcode, :funct, :reset, :go, :state
  clock :clk
  dependencies "../src/const/const_state.vhd",
    "../src/const/const_opcode.vhd"

  testcases = {
    i_op_lw:   ["state_memadr", "state_mem_read", "state_mem_read_wait", "state_mem_wb"],
    i_op_sw:   ["state_memadr", "state_mem_write"],
    i_op_beq:  ["state_branch"],
    i_op_bltz:  ["state_branch"],
    i_op_bgtz:  ["state_branch"],
    i_op_blez:  ["state_branch"],
    i_op_bgez:  ["state_branch"],
    i_op_addi: ["state_alu_imm", "state_alu_imm_wb"],
    i_op_addiu: ["state_alu_zimm", "state_alu_imm_wb"],
    i_op_break: ["state_break"],
    j_op_j:    ["state_jmp"],
    j_op_jal:  ["state_jal"]
  }

  testcases.each do |k, v|
    step 0, 0, 1, 1, "state_fetch"
    step 0, 0, 0, 1, "state_decode"
    step k.to_s, 0, 0, 0, 1, v[0]
    step k.to_s, 0, 0, 0, 1, v[1] if v.size > 1
    step k.to_s, 0, 0, 0, 1, v[2] if v.size > 2
    step k.to_s, 0, 0, 0, 1, v[3] if v.size > 3
    step k.to_s, 0, 0, 0, 1, "state_fetch"
  end

  r_fun_tests = {
    r_fun_add:  ["state_alu", "state_alu_wb"],
    r_fun_sll:  ["state_alu_sft", "state_alu_wb"],
    r_fun_mul:  ["state_alu"],
    r_fun_jr:   ["state_jmpr"],
    r_fun_jalr: ["state_jalr"],
    r_fun_lwx:  ["state_memadrx", "state_mem_read", "state_mem_read_wait", "state_mem_wbx"],
    r_fun_swx:  ["state_memadrx", "state_mem_writex"],
  }

  r_fun_tests.each do |k, v|
    step 0, 0, 1, 1, "state_fetch"
    step 0, 0, 0, 1, "state_decode"
    step "i_op_r_group", k.to_s, 0, 1, v[0]
    step "i_op_r_group", k.to_s, 0, 1, v[1] if v.size > 1
    step "i_op_r_group", k.to_s, 0, 1, v[2] if v.size > 2
    step "i_op_r_group", k.to_s, 0, 1, v[3] if v.size > 3
    step "i_op_r_group", k.to_s, 0, 1, "state_fetch"
  end

  io_fun_tests = {
    io_fun_iw:   ["state_io_read_w", "state_io_wb"],
    io_fun_ibu:  ["state_io_read_b", "state_io_wb"],
    io_fun_ihu:  ["state_io_read_h", "state_io_wb"],
    io_fun_ow:   ["state_io_write_w"],
    io_fun_obu:   ["state_io_write_b"],
    io_fun_ohu:   ["state_io_write_h"]
  }

  io_fun_tests.each do |k, v|
    step 0, 0, 1, 1, "state_fetch"
    step 0, 0, 0, 1, "state_decode"
    step "i_op_io", k.to_s, 0, 1, v[0]
    step "i_op_io", k.to_s, 0, 1, v[1] if v.size > 1
    step "i_op_io", k.to_s, 0, 1, v[2] if v.size > 2
    step "i_op_io", k.to_s, 0, 1, "state_fetch"
  end
end

