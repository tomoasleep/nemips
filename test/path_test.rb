require_relative "test_helper"

VhdlTestScript.scenario "../src/path.vhd" do |dut|
  dependencies "../src/const/*.vhd"

  pc, memf, decode, regfile, alu, fsm, pctl, signe, aluctl = use_mocks :program_counter, :memory_interface,
    :decoder, :register_file, :alu, :fsm, :path_controller, :sign_extender, :alu_decoder

  clock dut.clk

  step pctl.pc_write => 1, pc.pc_write => 1, alu.result => 0
  step pctl.pc_write => 0, pctl.pc_branch => 1, pc.pc_write => 0
  step pctl.pc_write => 0, pctl.pc_branch => 1, pc.pc_write => 1, alu.result => 1

  step alu.result => 123, pctl.wd_src => "wd_src_alu_past", regfile.wd3 => 123

end

#VhdlTestScript.scenario "../src/path.vhd" do |dut|
#  dependencies "../src/const/*.vhd", "../src/*.vhd"
#end

#VhdlTestScript.scenario "../src/path.vhd" do |dut|
#  dependencies exclude_filename_match("../src/const/*.vhd", ""), "../src/*.vhd",
#
#  clock dut.clk
#end
VhdlTestScript.scenario "../src/path.vhd" do |dut|
  dependencies "../src/const/*.vhd",
    *exclude_filename_match("../src/*.vhd", "program_counter.vhd", "path.vhd", "fsm.vhd", "register_file.vhd", "memory_interface.vhd")

  pc, mem, reg, fsm, alu = use_mocks :program_counter, :memory_interface, :register_file, :fsm, :alu

  clock dut.clk

  # alu
  step fsm.state => "state_fetch", mem.read_data => instruction_r("i_op_r_group", 1, 2, 3, 0, "r_fun_add"),
    mem.write_enable => 0

  step fsm.state => "state_decode", fsm.opcode => "i_op_r_group", fsm.funct => "r_fun_add",
    reg.a1 => 1, reg.a2 => 2, reg.rd1 => 45, reg.rd2 => 52

  step fsm.state => "state_alu", fsm.alu_bool_result => 1, alu.a => 45, alu.b => 52,
    alu.alu_ctl => "alu_ctl_add", alu.result => 97

  step fsm.state => "state_alu_wb", reg.a3 => 3, reg.wd3 => 97

  # memory load
  step fsm.state => "state_fetch", mem.read_data => instruction_i("i_op_lw", 5, 4, 0x5)
  step fsm.state => "state_decode", fsm.opcode => "i_op_lw", reg.a1 => 5, reg.rd1 => 0x3
  step fsm.state => "state_memadr", alu.a => 0x3, alu.b => 0x5, alu.result => 0x8

  step fsm.state => "state_mem_read", mem.address_in => 0x8
  step fsm.state => "state_mem_wb", reg.a3 => 4, mem.read_data => 0x3333,
    reg.wd3 => 0x3333

  # memory store
  step fsm.state => "state_fetch", mem.read_data => instruction_i("i_op_sw", 2, 3, 0x9)
  step fsm.state => "state_decode", fsm.opcode => "i_op_sw", reg.a1 => 2, reg.a2 => 3, reg.rd1 => 0x1,
    reg.rd2 => 0xaaaf
  step fsm.state => "state_memadr", alu.a => 0x1, alu.b => 0x9, alu.result => 0xa

  step fsm.state => "state_mem_write", mem.write_enable => 1,
    mem.address_in => 0xa, mem.write_data => 0xaaaf

  # memory load x
  step fsm.state => "state_fetch",
    mem.read_data => instruction_r("i_op_r_group", 1, 2, 3, 0, "r_fun_lwx")
  step fsm.state => "state_decode", fsm.opcode => "i_op_r_group", fsm.funct => "r_fun_lwx",
    reg.a1 => 1, reg.a2 => 2, reg.rd1 => 0x1, reg.rd2 => 0xffff
  step fsm.state => "state_memadrx", alu.a => 0x1, alu.b => 0xffff, alu.result => 0x10000

  step fsm.state => "state_mem_read", mem.address_in => 0x10000
  step fsm.state => "state_mem_wbx", reg.a3 => 3, mem.read_data => 0x2222,
    reg.wd3 => 0x2222

  # branch
  step fsm.state => "state_fetch", mem.read_data => instruction_i("i_op_beq", 5, 4, 0x100),
    pc.pc => 0x10, alu.a => 0x40, alu.b => 0x4, alu.result => 0x44, alu.alu_ctl => "alu_ctl_add",
    pc.write_data => 0x11, pc.pc_write => 1

  step fsm.state => "state_decode", fsm.opcode => "i_op_beq", reg.a1 => 5, reg.a2 => 4,
    reg.rd1 => 0x3, reg.rd2 =>0x3, pc.pc => 0x11, alu.a => 0x44, alu.b => 0x400, alu.result => 0x444,
    pc.write_data => 0x111
  step fsm.state => "state_branch", alu.a => 0x3, alu.b => 0x3, alu.alu_ctl => "alu_ctl_seq",
    alu.result => 1, pc.pc_write =>1

  # alu imm
  step fsm.state => "state_fetch", mem.read_data => instruction_i("i_op_addi", 1, 2, 0xffff),
    mem.write_enable => 0

  step fsm.state => "state_decode", fsm.opcode => "i_op_addi",
    reg.a1 => 1, reg.rd1 => 45

  step fsm.state => "state_alu_imm", fsm.alu_bool_result => 0, alu.a => 45, alu.b => 0xffffffff,
    alu.alu_ctl => "alu_ctl_add", alu.result => 44

  step fsm.state => "state_alu_imm_wb", reg.a3 => 2, reg.wd3 => 44

  # alu zimm
  step fsm.state => "state_fetch", mem.read_data => instruction_i("i_op_addiu", 3, 7, 0xffff),
    mem.write_enable => 0

  step fsm.state => "state_decode", fsm.opcode => "i_op_addiu",
    reg.a1 => 3, reg.rd1 => 1

  step fsm.state => "state_alu_zimm", fsm.alu_bool_result => 0, alu.a => 1, alu.b => 0xffff,
    alu.result => 0x10000

  step fsm.state => "state_alu_imm_wb", reg.a3 => 7, reg.wd3 => 0x10000
end

