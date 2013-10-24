VhdlTestScript.scenario "../src/fsm.vhd" do
  ports :opcode, :funct, :alu_bool_result, :reset, :state
  clock :clk
  dependencies "../src/const/const_state.vhd",
    "../src/const/const_opcode.vhd"

  testcases = {
    i_op_lw:   ["state_memadr", "state_mem_read", "state_mem_wb"],
    i_op_sw:   ["state_memadr", "state_mem_write"],
    i_op_beq:  ["state_branch"],
    i_op_addi: ["state_alu_imm", "state_alu_imm_wb"],
    j_op_j:    ["state_jmp"],
    j_op_jal:  ["state_jal"]
  }

  testcases.each do |k, v|
    step 0, 0, 0, 1, "state_fetch"
    step 0, 0, 0, 0, "state_decode"
    step k.to_s, 0, 0, 0, v[0]
    step k.to_s, 0, 0, 0, v[1] if v.size > 1
    step k.to_s, 0, 0, 0, v[2] if v.size > 2
    step k.to_s, 0, 0, 0, "state_fetch"
  end

  r_fun_tests = {
    r_fun_add:  ["state_alu", "state_alu_wb"],
    r_fun_mul:  ["state_alu"],
    r_fun_jr:   ["state_jmpr"],
    r_fun_jalr: ["state_jalr"]
  }

  r_fun_tests.each do |k, v|
    step 0, 0, 0, 1, "state_fetch"
    step 0, 0, 0, 0, "state_decode"
    step "i_op_r_group", k.to_s, 0, 0, v[0]
    step "i_op_r_group", k.to_s, 0, 0, v[1] if v.size > 1
    step "i_op_r_group", k.to_s, 0, 0, v[2] if v.size > 2
    step "i_op_r_group", k.to_s, 0, 0, "state_fetch"
  end
end

