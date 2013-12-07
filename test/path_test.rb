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
    pathes = exclude_filename_match(
      "../src/*.vhd", "program_counter.vhd", "path.vhd", "alu.vhd",
      "fsm.vhd", "register_file.vhd", "register_file_float.vhd", "memory_interface.vhd")
    pathes += exclude_filename_match(
      "../src/fpu/*.vhd", "fpu_controller.vhd", "sub_fpu.vhd")

  dependencies "../src/const/const_*.vhd",
    "../src/const/record_state_ctl.vhd", *pathes

  pc, reg, fsm, alu, fpu, freg = use_mocks :program_counter,
    :register_file, :fsm, :alu, :fpu_controller, :register_file_float

  clock dut.clk

  context "memory load" do
    step fsm.state => "state_fetch", dut.inst_ram_read_data => instruction_i("i_op_lw", 5, 4, 0x5),
      dut.sram_cmd => "sram_cmd_none"
    step fsm.state => "state_decode", fsm.opcode => "i_op_lw", reg.a1 => 5, reg.rd1 => 0x3
    step fsm.state => "state_memadr", alu.a => 0x3, alu.b => 0x5, alu.result => 0x8

    step {
      assign fsm.state => "state_mem_read"
      assert_before dut.mem_addr => 0x8, dut.sram_cmd => "sram_cmd_read"
    }
    step fsm.state => "state_mem_read_wait", dut.sram_cmd => "sram_cmd_none", dut.mem_read_ready => 0,
      fsm.go => 0
    step fsm.state => "state_mem_read_wait", dut.sram_cmd => "sram_cmd_none", dut.mem_read_ready => 1,
      fsm.go => 1

    step fsm.state => "state_mem_wb", reg.a3 => 4, dut.mem_read_data => 0x3333,
      reg.wd3 => 0x3333
  end

  context "memory store" do
    step fsm.state => "state_fetch", dut.inst_ram_read_data => instruction_i("i_op_sw", 2, 3, 0x9)
    step fsm.state => "state_decode", fsm.opcode => "i_op_sw", reg.a1 => 2, reg.a2 => 3, reg.rd1 => 0x1,
      reg.rd2 => 0xaaaf
    step fsm.state => "state_memadr", alu.a => 0x1, alu.b => 0x9, alu.result => 0xa

    step {
      assign fsm.state => "state_mem_write"
      assert_before dut.sram_cmd => "sram_cmd_write", dut.mem_addr => 0xa, dut.mem_write_data => 0xaaaf
    }
  end

  context "program write" do
    step fsm.state => "state_fetch", dut.inst_ram_read_data => instruction_i("i_op_sprogram", 2, 3, 0x9)
    step fsm.state => "state_decode", fsm.opcode => "i_op_sprogram", reg.a1 => 2, reg.a2 => 3, reg.rd1 => 0x1,
      reg.rd2 => 0xaaaf
    step fsm.state => "state_memadr", alu.a => 0x1, alu.b => 0x9, alu.result => 0xa

    step {
      assign fsm.state => "state_program_write"
      assert_before dut.inst_ram_write_enable => 1, dut.inst_ram_addr => 0x2, dut.inst_ram_write_data => 0xaaaf
    }
  end

  context "memory load x" do
    step fsm.state => "state_fetch",
      dut.inst_ram_read_data => instruction_r("i_op_r_group", 1, 2, 3, 0, "r_fun_lwx")
    step fsm.state => "state_decode", fsm.opcode => "i_op_r_group", fsm.funct => "r_fun_lwx",
      reg.a1 => 1, reg.a2 => 2, reg.rd1 => 0x1, reg.rd2 => 0xffff
    step fsm.state => "state_memadrx", alu.a => 0x1, alu.b => 0xffff, alu.result => 0x10000

    step fsm.state => "state_mem_read", dut.mem_addr => 0x10000, dut.sram_cmd => "sram_cmd_read"

    step fsm.state => "state_mem_wbx", reg.a3 => 3, dut.mem_read_data => 0x2222,
      reg.wd3 => 0x2222
  end

  context "memory write x" do
    step fsm.state => "state_fetch",
      dut.inst_ram_read_data => instruction_r("i_op_r_group", 4, 5, 6, 0, "r_fun_swx")
    step fsm.state => "state_decode", fsm.opcode => "i_op_r_group", fsm.funct => "r_fun_swx",
      reg.a1 => 4, reg.a2 => 5, reg.rd1 => 0x8, reg.rd2 => 0x1, reg.we3 => 0

    step {
      assign fsm.state => "state_memadrx", reg.rd2 => 0xf, alu.result => 0x9
      assert_before reg.a2 => 6, alu.a => 0x8, alu.b => 0x1
    }

    step {
      assign fsm.state => "state_mem_writex"
      assert_before dut.sram_cmd => "sram_cmd_write", dut.mem_addr => 0x9,
        dut.mem_write_data => 0xf
    }
  end

  context "io word read" do
    step fsm.state => "state_fetch",
      dut.inst_ram_read_data => instruction_r("i_op_io", 4, 5, 6, 0, "io_fun_iw")
    step fsm.state => "state_decode", fsm.opcode => "i_op_io", fsm.funct => "io_fun_iw",
      reg.a1 => 4, reg.a2 => 5, reg.rd1 => 0x8, reg.rd2 => 0x1, reg.we3 => 0

    step fsm.state => "state_io_read_w", dut.io_read_cmd => "io_length_word", dut.io_read_ready => 0,
      fsm.go => 0
    step fsm.state => "state_io_read_w", dut.io_read_cmd => "io_length_none", dut.io_read_ready => 1,
      fsm.go => 1, dut.io_read_data => 1234

    step fsm.state => "state_io_wb", reg.a3 => 6, reg.we3 => 1, reg.wd3 => 1234
  end

  context "io halfword read" do
    step fsm.state => "state_fetch",
      dut.inst_ram_read_data => instruction_r("i_op_io", 1, 2, 3, 0, "io_fun_ih")
    step fsm.state => "state_decode", fsm.opcode => "i_op_io", fsm.funct => "io_fun_ih",
      reg.a1 => 1, reg.a2 => 2, reg.rd1 => 0xa, reg.rd2 => 0xb, reg.we3 => 0

    step fsm.state => "state_io_read_h", dut.io_read_cmd => "io_length_halfword", dut.io_read_ready => 0,
      fsm.go => 0
    step fsm.state => "state_io_read_h", dut.io_read_cmd => "io_length_none", dut.io_read_ready => 1,
      fsm.go => 1, dut.io_read_data => 4123

    step fsm.state => "state_io_wb", reg.a3 => 3, reg.we3 => 1, reg.wd3 => 4123
  end

  context "io write" do
    step fsm.state => "state_fetch",
      dut.inst_ram_read_data => instruction_r("i_op_io", 4, 5, 6, 0, "io_fun_iw")
    step fsm.state => "state_decode", fsm.opcode => "i_op_io", fsm.funct => "io_fun_iw",
      reg.a1 => 4, reg.a2 => 5, reg.rd1 => 0x8, reg.rd2 => 0x1, reg.we3 => 0

    step fsm.state => "state_io_write_w", dut.io_write_cmd => "io_length_word", dut.io_write_ready => 0,
      fsm.go => 0, dut.io_write_data => 0x8
    step fsm.state => "state_io_write_w", dut.io_write_cmd => "io_length_word", dut.io_write_ready => 0,
      fsm.go => 0, dut.io_write_data => 0x8
    step fsm.state => "state_io_write_w", dut.io_write_cmd => "io_length_none", dut.io_write_ready => 1,
      fsm.go => 1
  end


  context "alu" do
    step fsm.state => "state_fetch", dut.inst_ram_read_data => instruction_r("i_op_r_group", 1, 2, 3, 0, "r_fun_add"),
      dut.sram_cmd => "sram_cmd_none", reg.we3 => 0

    step fsm.state => "state_decode", fsm.opcode => "i_op_r_group", fsm.funct => "r_fun_add",
      reg.a1 => 1, reg.a2 => 2, reg.rd1 => 45, reg.rd2 => 52

    step fsm.state => "state_alu", alu.a => 45, alu.b => 52,
      alu.alu_ctl => "alu_ctl_add", alu.result => 97

    step fsm.state => "state_alu_wb", reg.a3 => 3, reg.wd3 => 97
  end

  context "alu imm" do
    step fsm.state => "state_fetch", dut.inst_ram_read_data => instruction_i("i_op_addi", 1, 2, 0xffff),
      dut.sram_cmd => "sram_cmd_none"

    step fsm.state => "state_decode", fsm.opcode => "i_op_addi",
      reg.a1 => 1, reg.rd1 => 45

    step fsm.state => "state_alu_imm", alu.a => 45, alu.b => 0xffffffff,
      alu.alu_ctl => "alu_ctl_add", alu.result => 44

    step {
      assign fsm.state => "state_alu_imm_wb"
      assert_before reg.a3 => 2, reg.wd3 => 44, reg.we3 => 1
    }
  end

  context "alu zimm" do
    step fsm.state => "state_fetch", dut.inst_ram_read_data => instruction_i("i_op_addiu", 3, 7, 0xffff),
      dut.sram_cmd => "sram_cmd_none"

    step fsm.state => "state_decode", fsm.opcode => "i_op_addiu",
      reg.a1 => 3, reg.rd1 => 1

    step fsm.state => "state_alu_zimm", alu.a => 1, alu.b => 0xffff,
      alu.result => 0x10000

    step {
      assign fsm.state => "state_alu_imm_wb"
      assert_before reg.a3 => 7, reg.wd3 => 0x10000, reg.we3 => 1
    }
  end

  context "alu shift" do
    step fsm.state => "state_fetch",
      dut.inst_ram_read_data => instruction_r("i_op_r_group", 1, 2, 3, 10, "r_fun_sll"),
      dut.sram_cmd => "sram_cmd_none", reg.we3 => 0

    step fsm.state => "state_decode", fsm.opcode => "i_op_r_group", fsm.funct => "r_fun_sll",
      reg.a1 => 1, reg.a2 => 2, reg.rd1 => 5, reg.rd2 => 6

    step {
      assign alu.result => 5 << 10,  fsm.state => "state_alu_sft"
      assert_before alu.a => 5, alu.b => 10
    }

    step {
      assign fsm.state => "state_alu_wb"
      assert_before reg.a3 => 3, reg.wd3 => 5 << 10, reg.we3 => 1
    }
  end

  context "fpu" do
    step fsm.state => "state_fetch",
      dut.inst_ram_read_data => instruction_r("i_op_f_group", 1, 2, 3, 0, "f_op_fadd"),
      pc.pc => 0x10, alu.a => 0x40, alu.b => 0x4, alu.result => 0x44,
      alu.alu_ctl => "alu_ctl_add",
      pc.write_data => 0x11, pc.pc_write => 1

    context "decode" do
      step fsm.state => "state_decode",
        fsm.opcode => "i_op_f_group",
        freg.a1 => 1, freg.a2 => 2, freg.rd1 => 3, freg.rd2 => 4,
        fpu.a => 3, fpu.b => 4, freg.we3 => 0
    end

    context "wait for fpu done" do
      2.times do
        step {
          assign fsm.state => "state_fpu", fpu.done => 0,
            fpu.result => 8

          assert_before fpu.a => 3, fpu.b => 4,
            fpu.fpu_ctl => "fpu_ctl_fadd",
            reg.we3 => 0, freg.we3 => 0,
            fsm.go => 0
        }
      end
    end

    context "done" do
      step {
          assign fsm.state => "state_fpu", fpu.done => 1,
            fpu.result => 5

          assert_before fpu.a => 3, fpu.b => 4,
            fpu.fpu_ctl => "fpu_ctl_fadd",
            reg.we3 => 0, freg.we3 => 0,
            fsm.go => 1
      }
    end

    context "write back" do
      step fsm.state => "state_fpu_wb",
        freg.a3 => 3, freg.wd3 => 5,
        reg.we3 => 0, freg.we3 => 1
    end
  end

  context "branch" do
  step fsm.state => "state_fetch", dut.inst_ram_read_data => instruction_i("i_op_beq", 5, 4, 0x100),
    pc.pc => 0x10, alu.a => 0x40, alu.b => 0x4, alu.result => 0x44, alu.alu_ctl => "alu_ctl_add",
    pc.write_data => 0x11, pc.pc_write => 1

  step fsm.state => "state_decode", fsm.opcode => "i_op_beq", reg.a1 => 5, reg.a2 => 4,
    reg.rd1 => 0x3, reg.rd2 =>0x3, pc.pc => 0x11, alu.a => 0x44, alu.b => 0x400, alu.result => 0x444,
    pc.write_data => 0x111, reg.we3 => 0

  step {
    assign fsm.state => "state_branch", alu.result => 0x1
    assert_before alu.alu_ctl => "alu_ctl_seq",
      pc.pc_write => 1, pc.write_data => 0x111, alu.a => 0x3, alu.b => 0x3
  }
  end

  context "jmp" do
    step fsm.state => "state_fetch", dut.inst_ram_read_data => instruction_j("j_op_j", 0x100),
      pc.pc => 0x10000010, alu.a => 0x40000040, alu.b => 0x4,
      alu.result => 0x40000044, alu.alu_ctl => "alu_ctl_add",
      pc.write_data => 0x10000011, pc.pc_write => 1
    step fsm.state => "state_decode", fsm.opcode => "j_op_j", pc.pc => 0x10000011
    step fsm.state => "state_jmp", pc.pc_write => 1, pc.write_data => 0x10000100
  end

  context "jal" do
    step fsm.state => "state_fetch", dut.inst_ram_read_data => instruction_j("j_op_jal", 0x200),
      pc.pc => 0x10000010, alu.a => 0x40000040, alu.b => 0x4,
      alu.result => 0x40000044, alu.alu_ctl => "alu_ctl_add",
      pc.write_data => 0x10000011, pc.pc_write => 1
    step fsm.state => "state_decode", fsm.opcode => "j_op_jal", pc.pc => 0x10000011
    step fsm.state => "state_jal", pc.pc_write => 1, pc.write_data => 0x10000200,
      reg.a3 => 31, reg.wd3 => 0x40000044, reg.we3 => 1
  end

  context "jmpr" do
    step fsm.state => "state_fetch",
      dut.inst_ram_read_data => instruction_r("i_op_r_group", 5, 9, 3, 0, "r_fun_jr"),
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
      dut.inst_ram_read_data => instruction_r("i_op_r_group", 1, 2, 3, 0, "r_fun_jalr"),
      pc.pc => 0x10, alu.a => 0x40, alu.b => 0x4,
      alu.result => 0x44, alu.alu_ctl => "alu_ctl_add",
      pc.write_data => 0x11, pc.pc_write => 1
    step fsm.state => "state_decode", reg.a1 => 1, reg.a2 => 2, reg.rd1 => 0x100,
      reg.rd2 => 0x1000, fsm.funct => "r_fun_jalr", pc.pc => 0x11
    step fsm.state => "state_jalr", alu.alu_ctl => "alu_ctl_select_a",
      alu.result => 0x100, pc.pc_write => 1, pc.write_data => 0x40,
      reg.a3 => 31, reg.wd3 => 0x44, reg.we3 => 1
  end

  context "break" do
    step fsm.state => "state_fetch",
      dut.inst_ram_read_data => instruction_i("i_op_break", 0, 0, 0)
    step fsm.state => "state_decode", fsm.opcode => "i_op_break"

    step {
      assign fsm.state => "state_break", dut.continue => 0
      assert_before fsm.go => 0, dut.is_break => 1
      assert_after dut.is_break => 1
    }
    step {
      assign fsm.state => "state_break", dut.continue => 1
      assert_before fsm.go => 1, dut.is_break => 1
    }
  end
end

VhdlTestScript.scenario "../src/path.vhd", :cmd do |dut|
  dependencies "../src/const/const_*.vhd", "../src/const/record_state_ctl.vhd",
    *exclude_filename_match("../src/*.vhd", "register_file.vhd")

  reg, pctl = use_mocks :register_file, :path_controller
  clock dut.clk

  context("lui") {
    step {
      assign dut.inst_ram_read_data => instruction_i("i_op_lui", 2, 3, 0x8)
      assert_after pctl.state => "state_decode"
    }
    step {
      assign reg.rd1 => 12, reg.rd2 => 23
      assert_after pctl.state => "state_alu_imm"
    }
    step {
      assert_after pctl.state => "state_alu_imm_wb"
    }
    step {
      assert_before reg.a3 => 3, reg.wd3 => 0x80000, reg.we3 => 1
      assert_after pctl.state => "state_fetch"
    }
  }

  context("sprogram") {
    step dut.reset => 1
    step {
      assign dut.reset => 0, dut.inst_ram_read_data => instruction_i("i_op_sprogram", 2, 3, 0xc)
      assert_after pctl.state => "state_decode"
    }
    step {
      assign reg.rd1 => 0x8, reg.rd2 => 0x4
      assert_after pctl.state => "state_memadr"
    }
    step {
      assert_after pctl.state => "state_program_write"
    }
    step {
      assert_before dut.inst_ram_write_enable => 1,
        dut.inst_ram_write_data => 0x4, dut.inst_ram_addr => 0x5
      assert_after pctl.state => "state_fetch"
    }
  }
end

