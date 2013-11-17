require_relative "./asm_helper.rb"

VhdlTestScript.scenario "./tb/nemips_tb.vhd", :branch, :bne do
  asm = %q{
.text
  main:
    li r1, 12
    bne r1, r0, bne.1
    li r2, 0
    j rtn
  bne.1:
    li r2, 1
  rtn:
    ow r2
    break
    halt
  }
  inst_path = InstRom.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd", "../src/sram/sram_mock.vhd",
    "../src/sram/sram_controller.vhd", "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 4
  clock :clk

  context "can branch" do
    step reset: 1
    step reset: 0
    wait_step 400
    step read_length: "io_length_word", read_addr: 0, read_data: 1, read_ready: 1
    step read_length: "io_length_byte", read_addr: 4, read_ready: 0
  end
end

VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :branch, :bltz, :bgez do
  asm = %q{
.text
    li r4, 12
    li r5, 0
    li r5, -1
  main:
    bltz r4, blt.1
    li r2, 0
    j next.1
  blt.1:
    li r2, 1
  next.1:
    ow r2

    bltz r5, blt.2
    li r2, 0
    j next.2
  blt.2:
    li r2, 1
  next.2:
    ow r2

    bgez r4, bge.1
    li r3, 0
    j next.3
  bge.1:
    li r3, 1
  next.3:
    ow r3

    bgez r5, bge.2
    li r3, 0
    j rtn
  bge.2:
    li r3, 1
  rtn:
    ow r3

    break
    halt
  }
  inst_path = InstRom.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd", "../src/sram/sram_mock.vhd",
    "../src/sram/sram_controller.vhd", "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 4
  clock :clk

  context "bltz, bgez" do
    step reset: 1
    step reset: 0
    wait_step 800
    context "bltz doesn't jump when src(= 12)" do
      step read_length: "io_length_word", read_data: 0, read_ready: 1
    end
    context "bltz doesn't jumps when src(= 0)" do
      step read_length: "io_length_word", read_data: 0, read_ready: 1
    end
    context "bgez jumps when src(= 12)" do
      step read_length: "io_length_word", read_data: 1, read_ready: 1
    end
    context "bgez jump when src(= 0)" do
      step read_length: "io_length_word", read_data: 1, read_ready: 1
    end
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :branch, :blez, :bgtz do
  asm = %q{
.text
    li r4, 12
    li r5, 0
  main:
    blez r4, ble.1
    li r2, 0
    j next.1
  ble.1:
    li r2, 1
  next.1:
    ow r2

    blez r5, ble.2
    li r2, 0
    j next.2
  ble.2:
    li r2, 1
  next.2:
    ow r2

    bgtz r4, bgt.1
    li r3, 0
    j next.3
  bgt.1:
    li r3, 1
  next.3:
    ow r3

    bgtz r5, bgt.2
    li r3, 0
    j rtn
  bgt.2:
    li r3, 1
  rtn:
    ow r3

    break
    halt
  }
  inst_path = InstRom.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd", "../src/sram/sram_mock.vhd",
    "../src/sram/sram_controller.vhd", "../src/top/nemips.vhd", inst_path

  generics io_wait: 4
  clock :clk

  context "blez, bgtz" do
    step reset: 1
    step reset: 0
    wait_step 1600
    step is_break: 1
    context "blez doesn't jump when src(= 12)" do
      step read_length: "io_length_word", read_data: 0, read_ready: 1
    end
    context "blez jumps when src(= 0)" do
      step read_length: "io_length_word", read_data: 1, read_ready: 1
    end
    context "bgtz jumps when src(= 12)" do
      step read_length: "io_length_word", read_data: 1, read_ready: 1
    end
    context "bgtz doesn't jump when src(= 0)" do
      step read_length: "io_length_word", read_data: 0, read_ready: 1
    end
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "./tb/nemips_tb.vhd", :memory, :sw, :ow do
  asm = %q{
.text
  main:
    li r1, 12
    sw r1, 20(r0)
    li r1, 8
    lw r1, 12(r1)
    ow r1
    break
    halt
  }
  inst_path = InstRom.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
    "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 4
  clock :clk

  context "can memory load" do
    step reset: 1
    step reset: 0
    wait_step 300
    step sram_debug_addr: 20, sram_debug_data: 12
    step read_length: "io_length_word", read_addr: 0, read_data: 12, read_ready: 1
    step read_length: "io_length_byte", read_addr: 4, read_ready: 0
  end
end

VhdlTestScript.scenario "./tb/nemips_tb.vhd", :jal do
  asm = %q{
.text
  j main
L1:
  ow r31
  break
  jr r31
main:
  jal L1
  li r1, 111
  ow r1
  break
  halt
  }
  inst_path = InstRom.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
    "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 4
  clock :clk

  context "can jal" do
    step reset: 1
    step reset: 0
    wait_step 300
    step is_break: 1
    step read_length: "io_length_word", read_addr: 0, read_data: (PreInstructionLength + 5) * 4, read_ready: 1
    step continue: 1; step continue: 0
    wait_step 300
    step read_length: "io_length_word", read_addr: 4, read_data: 111, read_ready: 1
    step read_length: "io_length_byte", read_addr: 8, read_ready: 0
  end
end

VhdlTestScript.scenario "./tb/nemips_tb.vhd", :stack do
  asm = %q{
.text
  li r31, 2
  sw	r31, 0(r29)
  ow  r31
  ow  r29
  break
  halt
  }
  inst_path = InstRom.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
    "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 4
  clock :clk

  context "stack pointer" do
    step reset: 1
    step reset: 0
    wait_step 800
    step is_break: 1
    step sram_debug_addr: (1 << 20) - 1, sram_debug_data: 2
    step read_length: "io_length_word", read_addr: 0, read_data: 2, read_ready: 1
    context("is 2^20 - 1") {
      step read_length: "io_length_word", read_addr: 4, read_data: (1 << 20) - 1, read_ready: 1
    }
    step read_length: "io_length_byte", read_addr: 8, read_ready: 0
  end
end

VhdlTestScript.scenario "./tb/nemips_tb.vhd", :heap do
  asm = %q{
.text
  ow  r30
  break
  halt
  }
  inst_path = InstRom.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
    "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 4
  clock :clk

  context "heap pointer" do
    step reset: 1; step reset: 0
    wait_step 400
    step is_break: 1
    context("is 2^10") {
      step read_length: "io_length_word", read_addr: 0, read_data: (1 << 10), read_ready: 1
    }
    step read_length: "io_length_byte", read_addr: 4, read_ready: 0
  end
end

VhdlTestScript.scenario "./tb/nemips_tb.vhd", :sll do
  asm = %q{
.text
  li r2, 1
  sll r3, r2, 2
  sll r4, r2, 10
  ow r4
  ow r3
  break
  halt
  }
  inst_path = InstRom.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
    "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 4
  clock :clk

  context "shift left" do
    step reset: 1; step reset: 0
    wait_step 800
    step is_break: 1
    step read_length: "io_length_word", read_addr: 0, read_data: 1 << 10, read_ready: 1
    step read_length: "io_length_word", read_addr: 4, read_data: 1 << 2, read_ready: 1
    step read_length: "io_length_byte", read_addr: 8, read_ready: 0
  end
end

