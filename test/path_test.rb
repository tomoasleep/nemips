require_relative "test_helper"

VhdlTestScript.scenario "../src/path.vhd" do |dut|
  dependencies "../src/const/const_*.vhd", "../src/const/record_state_ctl.vhd"

  pc, decode, regfile, alu, fsm, pctl, signe, aluctl, gos =
    use_mocks :program_counter, :decoder, :register_file, :alu,
    :fsm, :path_controller, :sign_extender, :alu_decoder, :state_go_selector

  clock dut.clk

  step pctl.pc_write => 1, pc.pc_write => 1, alu.result => 0
  step pctl.pc_write => 0, pctl.pc_branch => 1, pc.pc_write => 0
  step pctl.pc_write => 0, pctl.pc_branch => 1, pc.pc_write => 1, alu.result => 1

  step alu.result => 123, pctl.wd_src => "wd_src_alu_past", regfile.wd3 => 123

end

VhdlTestScript.scenario "../src/path.vhd" do |dut|
  dependencies "../src/const/const_*.vhd", "../src/const/record_state_ctl.vhd",
    *exclude_filename_match(
      "../src/*.vhd", "program_counter.vhd", "path.vhd",
      "fsm.vhd", "register_file.vhd", "memory_interface.vhd")

  pc, reg, fsm, alu = use_mocks :program_counter, :register_file, :fsm, :alu

  clock dut.clk

  context "memory load" do
    step fsm.state => "state_fetch", dut.mem_read_data => instruction_i("i_op_lw", 5, 4, 0x5),
      dut.sram_cmd => "sram_cmd_none"
    step fsm.state => "state_decode", fsm.opcode => "i_op_lw", reg.a1 => 5, reg.rd1 => 0x3
    step fsm.state => "state_memadr", alu.a => 0x3, alu.b => 0x5, alu.result => 0x8

    step fsm.state => "state_mem_read", dut.mem_addr => 0x8, dut.sram_cmd => "sram_cmd_read"
    step fsm.state => "state_mem_read_wait", dut.sram_cmd => "sram_cmd_none", dut.mem_read_ready => 0,
      fsm.go => 0
    step fsm.state => "state_mem_read_wait", dut.sram_cmd => "sram_cmd_none", dut.mem_read_ready => 1,
      fsm.go => 1

    step fsm.state => "state_mem_wb", reg.a3 => 4, dut.mem_read_data => 0x3333,
      reg.wd3 => 0x3333
  end

  context "memory store" do
    step fsm.state => "state_fetch", dut.mem_read_data => instruction_i("i_op_sw", 2, 3, 0x9)
    step fsm.state => "state_decode", fsm.opcode => "i_op_sw", reg.a1 => 2, reg.a2 => 3, reg.rd1 => 0x1,
      reg.rd2 => 0xaaaf
    step fsm.state => "state_memadr", alu.a => 0x1, alu.b => 0x9, alu.result => 0xa

    step fsm.state => "state_mem_write", dut.sram_cmd => "sram_cmd_write",
      dut.mem_addr => 0xa, dut.mem_write_data => 0xaaaf
  end

  context "memory load x" do
    step fsm.state => "state_fetch",
      dut.mem_read_data => instruction_r("i_op_r_group", 1, 2, 3, 0, "r_fun_lwx")
    step fsm.state => "state_decode", fsm.opcode => "i_op_r_group", fsm.funct => "r_fun_lwx",
      reg.a1 => 1, reg.a2 => 2, reg.rd1 => 0x1, reg.rd2 => 0xffff
    step fsm.state => "state_memadrx", alu.a => 0x1, alu.b => 0xffff, alu.result => 0x10000

    step fsm.state => "state_mem_read", dut.mem_addr => 0x10000, dut.sram_cmd => "sram_cmd_read"

    step fsm.state => "state_mem_wbx", reg.a3 => 3, dut.mem_read_data => 0x2222,
      reg.wd3 => 0x2222
  end

  context "memory write x" do
    step fsm.state => "state_fetch",
      dut.mem_read_data => instruction_r("i_op_r_group", 4, 5, 6, 0, "r_fun_swx")
    step fsm.state => "state_decode", fsm.opcode => "i_op_r_group", fsm.funct => "r_fun_swx",
      reg.a1 => 4, reg.a2 => 5, reg.rd1 => 0x8, reg.rd2 => 0x1, reg.we3 => 0

    step {
      assign fsm.state => "state_memadrx", reg.rd2 => 0xf
      assert_before reg.a2 => 6, alu.a => 0x8, alu.b => 0x1
    }

    step fsm.state => "state_mem_writex", dut.sram_cmd => "sram_cmd_write", dut.mem_addr => 0x999,
      dut.mem_write_data => 0xf, alu.result => 0x999
  end

  context "io read" do
    step fsm.state => "state_fetch",
      dut.mem_read_data => instruction_r("i_op_io", 4, 5, 6, 0, "io_fun_iw")
    step fsm.state => "state_decode", fsm.opcode => "i_op_io", fsm.funct => "io_fun_iw",
      reg.a1 => 4, reg.a2 => 5, reg.rd1 => 0x8, reg.rd2 => 0x1, reg.we3 => 0

    step fsm.state => "state_io_read", dut.io_read_cmd => "io_length_word", dut.io_read_ready => 0,
      fsm.go => 0
    step fsm.state => "state_io_read", dut.io_read_cmd => "io_length_none", dut.io_read_ready => 1,
      fsm.go => 1, dut.io_read_data => 1234

    step fsm.state => "state_io_wb", reg.a3 => 6, reg.we3 => 1, reg.wd3 => 1234
  end

  context "io write" do
    step fsm.state => "state_fetch",
      dut.mem_read_data => instruction_r("i_op_io", 4, 5, 6, 0, "io_fun_iw")
    step fsm.state => "state_decode", fsm.opcode => "i_op_io", fsm.funct => "io_fun_iw",
      reg.a1 => 4, reg.a2 => 5, reg.rd1 => 0x8, reg.rd2 => 0x1, reg.we3 => 0

    step fsm.state => "state_io_write", dut.io_write_cmd => "io_length_word", dut.io_write_ready => 0,
      fsm.go => 0, dut.io_write_data => 0x8
    step fsm.state => "state_io_write", dut.io_write_cmd => "io_length_word", dut.io_write_ready => 0,
      fsm.go => 0, dut.io_write_data => 0x8
    step fsm.state => "state_io_write", dut.io_write_cmd => "io_length_none", dut.io_write_ready => 1,
      fsm.go => 1
  end


  context "alu" do
    step fsm.state => "state_fetch", dut.mem_read_data => instruction_r("i_op_r_group", 1, 2, 3, 0, "r_fun_add"),
      dut.sram_cmd => "sram_cmd_none", reg.we3 => 0

    step fsm.state => "state_decode", fsm.opcode => "i_op_r_group", fsm.funct => "r_fun_add",
      reg.a1 => 1, reg.a2 => 2, reg.rd1 => 45, reg.rd2 => 52

    step fsm.state => "state_alu", fsm.alu_bool_result => 1, alu.a => 45, alu.b => 52,
      alu.alu_ctl => "alu_ctl_add", alu.result => 97

    step fsm.state => "state_alu_wb", reg.a3 => 3, reg.wd3 => 97
  end

  context "alu imm" do
    step fsm.state => "state_fetch", dut.mem_read_data => instruction_i("i_op_addi", 1, 2, 0xffff),
      dut.sram_cmd => "sram_cmd_none"

    step fsm.state => "state_decode", fsm.opcode => "i_op_addi",
      reg.a1 => 1, reg.rd1 => 45

    step fsm.state => "state_alu_imm", fsm.alu_bool_result => 0, alu.a => 45, alu.b => 0xffffffff,
      alu.alu_ctl => "alu_ctl_add", alu.result => 44

    step fsm.state => "state_alu_imm_wb", reg.a3 => 2, reg.wd3 => 44, reg.we3 => 1
  end

  context "alu zimm" do
    step fsm.state => "state_fetch", dut.mem_read_data => instruction_i("i_op_addiu", 3, 7, 0xffff),
      dut.sram_cmd => "sram_cmd_none"

    step fsm.state => "state_decode", fsm.opcode => "i_op_addiu",
      reg.a1 => 3, reg.rd1 => 1

    step fsm.state => "state_alu_zimm", fsm.alu_bool_result => 0, alu.a => 1, alu.b => 0xffff,
      alu.result => 0x10000

    step fsm.state => "state_alu_imm_wb", reg.a3 => 7, reg.wd3 => 0x10000, reg.we3 => 1
  end

  context "branch" do
  step fsm.state => "state_fetch", dut.mem_read_data => instruction_i("i_op_beq", 5, 4, 0x100),
    pc.pc => 0x10, alu.a => 0x40, alu.b => 0x4, alu.result => 0x44, alu.alu_ctl => "alu_ctl_add",
    pc.write_data => 0x11, pc.pc_write => 1

  step fsm.state => "state_decode", fsm.opcode => "i_op_beq", reg.a1 => 5, reg.a2 => 4,
    reg.rd1 => 0x3, reg.rd2 =>0x3, pc.pc => 0x11, alu.a => 0x44, alu.b => 0x400, alu.result => 0x444,
    pc.write_data => 0x111, reg.we3 => 0
  step fsm.state => "state_branch", alu.a => 0x3, alu.b => 0x3, alu.alu_ctl => "alu_ctl_seq",
    alu.result => 1, pc.pc_write =>1
  end

  context "jmp" do
    step fsm.state => "state_fetch", dut.mem_read_data => instruction_j("j_op_j", 0x100),
      pc.pc => 0x10000010, alu.a => 0x40000040, alu.b => 0x4,
      alu.result => 0x40000044, alu.alu_ctl => "alu_ctl_add",
      pc.write_data => 0x10000011, pc.pc_write => 1
    step fsm.state => "state_decode", fsm.opcode => "j_op_j", pc.pc => 0x10000011
    step fsm.state => "state_jmp", pc.pc_write => 1, pc.write_data => 0x10000100
  end

  context "jal" do
    step fsm.state => "state_fetch", dut.mem_read_data => instruction_j("j_op_jal", 0x200),
      pc.pc => 0x10000010, alu.a => 0x40000040, alu.b => 0x4,
      alu.result => 0x40000044, alu.alu_ctl => "alu_ctl_add",
      pc.write_data => 0x10000011, pc.pc_write => 1
    step fsm.state => "state_decode", fsm.opcode => "j_op_jal", pc.pc => 0x10000011
    step fsm.state => "state_jal", pc.pc_write => 1, pc.write_data => 0x10000200,
      reg.a3 => 31, reg.wd3 => 0x40000044, reg.we3 => 1
  end

  context "jmpr" do
    step fsm.state => "state_fetch",
      dut.mem_read_data => instruction_r("i_op_r_group", 5, 9, 3, 0, "r_fun_jr"),
      pc.pc => 0x100, alu.a => 0x400, alu.b => 0x4,
      alu.result => 0x404, alu.alu_ctl => "alu_ctl_add",
      pc.write_data => 0x101, pc.pc_write => 1
    step fsm.state => "state_decode", reg.a1 => 5, reg.a2 => 9, reg.rd1 => 0x10000,
      reg.rd2 => 0x1000, fsm.funct => "r_fun_jr", pc.pc => 0x101
    step fsm.state => "state_jalr", alu.alu_ctl => "alu_ctl_select_a",
      alu.result => 0x10000, pc.pc_write => 1, pc.write_data => 0x4000
  end

  context "jalr" do
    step fsm.state => "state_fetch",
      dut.mem_read_data => instruction_r("i_op_r_group", 1, 2, 3, 0, "r_fun_jalr"),
      pc.pc => 0x10, alu.a => 0x40, alu.b => 0x4,
      alu.result => 0x44, alu.alu_ctl => "alu_ctl_add",
      pc.write_data => 0x11, pc.pc_write => 1
    step fsm.state => "state_decode", reg.a1 => 1, reg.a2 => 2, reg.rd1 => 0x100,
      reg.rd2 => 0x1000, fsm.funct => "r_fun_jalr", pc.pc => 0x11
    step fsm.state => "state_jalr", alu.alu_ctl => "alu_ctl_select_a",
      alu.result => 0x100, pc.pc_write => 1, pc.write_data => 0x40,
      reg.a3 => 31, reg.wd3 => 0x44, reg.we3 => 1
  end
end
