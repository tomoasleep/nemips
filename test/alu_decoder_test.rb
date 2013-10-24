VhdlTestScript.scenario "../src/alu_decoder.vhd" do
  ports :opcode, :funct, :alu_op, :alu_ctl
  dependencies "../src/const/const_alu_ctl.vhd",
    "../src/const/const_mux.vhd", "../src/const/const_opcode.vhd"

  testcases = {
    r_fun_sll:    "alu_ctl_lshift_l",
    r_fun_srl:    "alu_ctl_lshift_r",
    r_fun_sra:    "alu_ctl_ashift_r",
    r_fun_sllv:   "alu_ctl_lshift_l",
    r_fun_srlv:   "alu_ctl_lshift_r",
    r_fun_srav:   "alu_ctl_ashift_r",
    r_fun_mfhi:   "alu_ctl_mfhi",
    r_fun_mthi:   "alu_ctl_mthi",
    r_fun_mflo:   "alu_ctl_mflo",
    r_fun_mtlo:   "alu_ctl_mtlo",
    r_fun_mul:    "alu_ctl_mul",
    r_fun_mulu:   "alu_ctl_mulu",
    r_fun_div:    "alu_ctl_div",
    r_fun_divu:   "alu_ctl_divu",
    r_fun_add:    "alu_ctl_add",
    r_fun_addu:   "alu_ctl_add",
    r_fun_sub:    "alu_ctl_sub",
    r_fun_subu:   "alu_ctl_sub",
    r_fun_and:    "alu_ctl_and",
    r_fun_or:     "alu_ctl_or",
    r_fun_xor:    "alu_ctl_xor",
    r_fun_nor:    "alu_ctl_nor",
    r_fun_slt:    "alu_ctl_slt",
    r_fun_sltu:   "alu_ctl_sltu"
  }

  testcases.each do |k, v|
    step "i_op_r_group", k.to_s, "alu_op_decode", v
  end

  i_op_cases = {
    i_op_beq:     "alu_ctl_seq",
    i_op_bne:     "alu_ctl_sne"
  }

end
