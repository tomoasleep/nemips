VhdlTestScript.scenario "../src/alu.vhd" do
  dependencies "../src/const/const_alu_ctl.vhd"
  ports :alu_ctl, :a, :b, :result
  clock :clk

  MAX = 0xffffffff

  step "alu_ctl_add",  1, 2, 3
  step "alu_ctl_add",  0xfffffffe, 1, 0xffffffff
  step "alu_ctl_add",  MAX, 1, 0
  step "alu_ctl_sub",  3, 5, -2
  step "alu_ctl_sub",  8, 5,  3

  step "alu_ctl_mul",  8, 5,  _
  step "alu_ctl_mflo", 0, 0, 40

  step "alu_ctl_lshift_r", 0b10, 1, 0b1
  step "alu_ctl_lshift_l", 0b10, 1, 0b100
  step "alu_ctl_lshift_l", 0b10, 10, 0b10 << 10
  step "alu_ctl_lshift_r", MAX, 1, 0x7fffffff
  step "alu_ctl_lshift_r", MAX, 4, 0x0fffffff
  step "alu_ctl_ashift_r", MAX, 1, 0xffffffff
  step "alu_ctl_and",  0b0111, 0b1010, 0b0010
  step "alu_ctl_or",   0b0111, 0b1010, 0b1111
  step "alu_ctl_xor",  0b0111, 0b1010, 0b1101
  step "alu_ctl_nor",  0b0111, 0b1010, 0xfffffff0
  step "alu_ctl_nor",  0b0111, 0b1010, 0xfffffff0

  step "alu_ctl_slt",   7, 9, 1
  step "alu_ctl_slt",  15, 9, 0
  step "alu_ctl_slt",  -1, 1, 1
  step "alu_ctl_slt",  -1, -99, 0
  step "alu_ctl_sltu",   7, 9, 1
  step "alu_ctl_sltu",  15, 9, 0
  step "alu_ctl_sltu",  MAX, 0, 0
  step "alu_ctl_sltu",  0xf0000000, MAX, 1

  step "alu_ctl_seq", 32, 32, 1
  step "alu_ctl_seq", 32, 12, 0
  step "alu_ctl_sne", 32, 32, 0
  step "alu_ctl_sne", 32, 12, 1

  step "alu_ctl_cmpz_le",  0, 0, 1
  step "alu_ctl_cmpz_le",  3, 0, 0
  step "alu_ctl_cmpz_le", -1, 0, 1
  step "alu_ctl_cmpz_gt",  0, 1, 0
  step "alu_ctl_cmpz_gt",  3, 1, 1
  step "alu_ctl_cmpz_gt", -1, 1, 0

  step "alu_ctl_cmpz_lt",  0, 0, 0
  step "alu_ctl_cmpz_lt",  3, 0, 0
  step "alu_ctl_cmpz_lt", -1, 0, 1
  step "alu_ctl_cmpz_ge",  0, 1, 1
  step "alu_ctl_cmpz_ge",  3, 1, 1
  step "alu_ctl_cmpz_ge", -1, 1, 0

  step "alu_ctl_select_a", 3, 9, 3
  step "alu_ctl_select_b", 3, 9, 9

  step "alu_ctl_mthi", 3, _, _
  step "alu_ctl_mtlo", 8, _, _
  step "alu_ctl_mflo", 0, 0,  8
  step "alu_ctl_mfhi", 0, 0,  3

  step "alu_ctl_lui", 0, 0x0000ffff, 0xffff0000
end
