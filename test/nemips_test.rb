require_relative "./asm_helper.rb"

VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :ib do
  asm = %q{
.text
  main:
    ib r3
    ob r3
    j main
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd", "../src/sram/sram_mock.vhd",
    "../src/sram/sram_controller.vhd", "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 1
  clock :clk

  context "can byte io" do
    wait_step 20
    step write_length: "io_length_byte", write_data: 0x1
    step write_length: "io_length_none", write_data: 0
    wait_step 400
    step read_length: "io_length_byte", read_data: 0x1, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :io, :ih do
  asm = %q{
.text
  main:
    ih r3
    oh r3
    j main
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd", "../src/sram/sram_mock.vhd",
    "../src/sram/sram_controller.vhd", "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 1
  clock :clk

  context "can halfword io" do
    wait_step 20
    step write_length: "io_length_halfword", write_data: 0x1234
    step write_length: "io_length_none", write_data: 0
    wait_step 400
    step read_length: "io_length_halfword", read_data: 0x1234, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :lui do
  asm = %q{
.text
  main:
    lui r2, 1
    ow r2
    break
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd", "../src/sram/sram_mock.vhd",
    "../src/sram/sram_controller.vhd", "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 1
  clock :clk

  context "can branch" do
    step reset: 1
    step reset: 0
    wait_step 400
    step read_length: "io_length_word", read_data: 0x10000, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :alu do
  asm = %q{
.text
  main:
    li r1, 10
    addi r1, r1, -1
  rtn:
    ow r1
    break
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd", "../src/sram/sram_mock.vhd",
    "../src/sram/sram_controller.vhd", "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 1
  clock :clk

  context "can branch" do
    step reset: 1
    step reset: 0
    wait_step 400
    step read_length: "io_length_word", read_data: 9, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :alu do
  asm = %q{
.data
  minus:
.int -1
.text
  main:
    la r2, minus
    ow r2
    break
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd", "../src/sram/sram_mock.vhd",
    "../src/sram/sram_controller.vhd", "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 1
  clock :clk

  context "can branch" do
    step reset: 1
    step reset: 0
    wait_step 400
    step read_length: "io_length_word", read_data: -1, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

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
  inst_path = InstRam.from_asm(asm).path

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
  inst_path = InstRam.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd", "../src/sram/sram_mock.vhd",
    "../src/sram/sram_controller.vhd", "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 4
  clock :clk

  context "bltz, bgez" do
    step reset: 1
    step reset: 0
    wait_step 1600

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
  inst_path = InstRam.from_asm(asm).path

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
  inst_path = InstRam.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
    "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 1
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
  inst_path = InstRam.from_asm(asm).path

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
  inst_path = InstRam.from_asm(asm).path

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
  inst_path = InstRam.from_asm(asm).path

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
  inst_path = InstRam.from_asm(asm).path

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

VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :io do
  asm = %q{
.text
  ib r2
  ow r2
  break
  halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
    "../src/top/nemips.vhd", inst_path

  generics io_wait: 4
  clock :clk

  context "loopback" do
    step reset: 1; step reset: 0
    wait_step 100
    step write_length: "io_length_byte", write_data: 12
    step write_length: "io_length_none", write_data: 0
    wait_step 7200
    step is_break: 1
    context "ow send 12" do
      step read_length: "io_length_word", read_data:  12, read_ready: 1
    end
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :io, :ib do
  asm = %q{
.text
  ib r2
  break
  halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
    "../src/top/nemips.vhd", inst_path

  generics io_wait: 10
  clock :clk

  context "io receive" do
    step reset: 1; step reset: 0
    wait_step 100
    step write_length: "io_length_byte", write_data: 12
    step write_length: "io_length_none", write_data: 0
    wait_step 1000
    context "goto next inst when data received" do
      step is_break: 1
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end


VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :io, :reset do
  asm = %q{
.text
  ib r2
  ow r2
  break
  halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
    "../src/top/nemips.vhd", inst_path

  generics io_wait: 4
  clock :clk

  context "loopback" do
    wait_step 100
    step write_length: "io_length_byte", write_data: 12
    step write_length: "io_length_none", write_data: 0
    wait_step 2200
    step is_break: 1
    context "ow send 12" do
      step read_length: "io_length_word", read_data:  12, read_ready: 1
    end
    step read_length: "io_length_byte", read_ready: 0
    step read_length: "io_length_none", read_ready: 0

    step reset: 1; step reset: 0

    wait_step 100
    step write_length: "io_length_byte", write_data: 23
    step write_length: "io_length_none", write_data: 0
    wait_step 2200
    step is_break: 1
    context "ow send 12" do
      step read_length: "io_length_word", read_data:  23, read_ready: 1
    end
    step read_length: "io_length_byte", read_ready: 0

  end
end

VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :addi do
  asm = %q{
.text
  li r2, 49
  addi r2, r2, -48
  ow r2
  break
  halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
    "../src/top/nemips.vhd", inst_path

  generics io_wait: 4
  clock :clk

  context "loopback" do
    wait_step 600
    step is_break: 1
    context "addi 49, -48 return 1" do
      step read_length: "io_length_word", read_data:  1, read_ready: 1
    end
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :io, :reset do
  asm = %q{
.text
  ib r2
  ow r2
  break
  halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
    "../src/top/nemips.vhd", inst_path

  generics io_wait: 4
  clock :clk

  context "loopback" do
    wait_step 100
    step write_length: "io_length_byte", write_data: 12
    step write_length: "io_length_none", write_data: 0
    wait_step 2200
    step is_break: 1
    context "ow send 12" do
      step read_length: "io_length_word", read_data:  12, read_ready: 1
    end
    step read_length: "io_length_byte", read_ready: 0
    step read_length: "io_length_none", read_ready: 0

    step reset: 1; step reset: 0

    wait_step 100
    step write_length: "io_length_byte", write_data: 23
    step write_length: "io_length_none", write_data: 0
    wait_step 2200
    step is_break: 1
    context "ow send 12" do
      step read_length: "io_length_word", read_data:  23, read_ready: 1
    end
    step read_length: "io_length_byte", read_ready: 0


  end
end

VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :la do
  asm = %q{
.data
program_start:
.int 0x400
program_eof:
.int -1
jump_op_funct:
.int 0x00000008
jump_funct_mask:
.int -67108802 # 0xfc00003e
.text
bootloader:
  la r10, program_start
  la r9, program_eof
  la r8, program_start
  la r7, jump_funct_mask
  la r6, jump_op_funct
  ow r6
  ow r7
  ow r8
  ow r9
  ow r10
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
    "../src/top/nemips.vhd", inst_path

  generics io_wait: 1
  clock :clk

  context "la" do
    wait_step 2000
    step read_length: "io_length_word", read_data: 0x8, read_ready: 1
    step read_length: "io_length_word", read_data: 0xfc00003e, read_ready: 1
    step read_length: "io_length_word", read_data: 0x400, read_ready: 1
    step read_length: "io_length_word", read_data: 0xffffffff, read_ready: 1
    step read_length: "io_length_word", read_data: 0x400, read_ready: 1
    step read_length: "io_length_none", read_ready: 0

  end
end

VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :boot do
  asm = %q{
.data
jump_code:
.int 0x0800000c
jal_code:
.int 0x0c00000c
jump_op_funct:
.int 0x08000000
jump_funct_mask:
.int -134217728 # 0xf8000000
.text
bootloader:
  la r7, jump_funct_mask
  la r6, jump_op_funct
  la r3, jump_code
load_program:
  xor r4, r3, r6
  and r4, r4, r7
  beq r4, r0, write_program
  break
  halt
write_program:
  ow r3
load_program2:
  la r3, jal_code
  xor r4, r3, r6
  and r4, r4, r7
  beq r4, r0, write_program2
  break
  halt
write_program2:
  ow r3
  break
  halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
    "../src/top/nemips.vhd", inst_path

  generics io_wait: 1
  clock :clk

  wait_step 1200
  context "j" do
    step read_length: "io_length_word", read_data: 0x0800000c, read_ready: 1
  end
  context "jal" do
    step read_length: "io_length_word", read_data: 0x0c00000c, read_ready: 1
    step read_length: "io_length_none", read_ready: 0
  end
end

