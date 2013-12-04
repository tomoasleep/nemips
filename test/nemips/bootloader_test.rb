require_relative "../asm_helper.rb"
require_relative "../test_helper.rb"

VhdlTestScript.scenario "../tb/nemips_tbq.vhd" do
  inst_path = InstRam.from_asm_path(pfr("test/asm/bootloader.s")).path

  dependencies pfr("src/const/*.vhd"), pfr("src/*.vhd"), pfr("src/rs232c/*.vhd"),
    pfr("src/sram/sram_mock.vhd"), pfr("src/sram/sram_controller.vhd"),
    pfr("src/debug/*.vhd"), pfr("src/top/nemips.vhd"), inst_path

  asm = %q{
.text
  main:
    li r2, 12
    ow r2
    jr r31
  }
  instructions = InstRam.from_asm(asm).instructions

  generics io_wait: 1
  clock :clk

  context "bootloader parse" do
    context "li, ow, jr" do
      [*instructions, -1].each do |i|
        step write_length: "io_length_word", write_data: i
      end
      step write_length: "io_length_none"

      wait_step 2000
      step read_length: "io_length_word", read_data: 12, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
      step read_length: "io_length_none"
    end
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :input, :ih do
  inst_path = InstRam.from_asm_path(pfr("test/asm/bootloader.s")).path

  dependencies pfr("src/const/*.vhd"), pfr("src/*.vhd"), pfr("src/rs232c/*.vhd"),
    pfr("src/sram/sram_mock.vhd"), pfr("src/sram/sram_controller.vhd"),
    pfr("src/debug/*.vhd"), pfr("src/top/nemips.vhd"), inst_path

  asm = %q{
.text
  main:
    ih r2
    oh r2
    halt
  }
  instructions = InstRam.from_asm(asm).instructions

  generics io_wait: 1
  clock :clk

  context "bootloader parse" do
    context "input output halfword" do
      [*instructions, -1].each do |i|
        step write_length: "io_length_word", write_data: i
      end
      step write_length: "io_length_none"

      wait_step 1400
      step write_length: "io_length_halfword", write_data: 0x1234
      step write_length: "io_length_none"
      wait_step 700

      step read_length: "io_length_halfword", read_data: 0x1234, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :input do
  inst_path = InstRam.from_asm_path(pfr("test/asm/bootloader.s")).path

  dependencies pfr("src/const/*.vhd"), pfr("src/*.vhd"), pfr("src/rs232c/*.vhd"),
    pfr("src/sram/sram_mock.vhd"), pfr("src/sram/sram_controller.vhd"),
    pfr("src/debug/*.vhd"), pfr("src/top/nemips.vhd"), inst_path

  asm = %q{
.text
  main:
    ib r2
    ob r2
    halt
  }
  instructions = InstRam.from_asm(asm).instructions

  generics io_wait: 1
  clock :clk

  context "bootloader parse" do
    context "input output" do
      [*instructions, -1].each do |i|
        step write_length: "io_length_word", write_data: i
      end
      step write_length: "io_length_none"

      wait_step 1400
      step write_length: "io_length_byte", write_data: 5
      step write_length: "io_length_none"
      wait_step 300

      step read_length: "io_length_byte", read_data: 5, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end



VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :many do
  inst_path = InstRam.from_asm_path(pfr("test/asm/bootloader.s")).path

  dependencies pfr("src/const/*.vhd"), pfr("src/*.vhd"), pfr("src/rs232c/*.vhd"),
    pfr("src/sram/sram_mock.vhd"), pfr("src/sram/sram_controller.vhd"),
    pfr("src/debug/*.vhd"), pfr("src/top/nemips.vhd"), inst_path

  asm = %q{
.text
  main:
    li r2, 12
    ow r2
    jr r31
  }
  instructions = InstRam.from_asm(asm).instructions

  generics io_wait: 1
  clock :clk

  context "bootloader parse" do
    context "manytimes" do
      3.times do
        [*instructions, -1].each do |i|
          step write_length: "io_length_word", write_data: i
        end
        step write_length: "io_length_none"

        wait_step 1200
        step read_length: "io_length_word", read_data: 12, read_ready: 1
        step read_length: "io_length_byte", read_ready: 0
        step read_length: "io_length_none"
      end
    end
  end
end


VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :branch, :bne do
  inst_path = InstRam.from_asm_path(pfr("test/asm/bootloader.s")).path

  dependencies pfr("src/const/*.vhd"), pfr("src/*.vhd"), pfr("src/rs232c/*.vhd"),
    pfr("src/sram/sram_mock.vhd"), pfr("src/sram/sram_controller.vhd"),
    pfr("src/debug/*.vhd"), pfr("src/top/nemips.vhd"), inst_path

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
  instructions = InstRam.from_asm(asm).instructions

  generics io_wait: 1
  clock :clk

  context "bootloader parse" do
    context "branch" do
      [*instructions, -1].each do |i|
        step write_length: "io_length_word", write_data: i
      end
      step write_length: "io_length_none"

      wait_step 2000
      step read_length: "io_length_word", read_data: 1, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :jmp, :j do
  inst_path = InstRam.from_asm_path(pfr("test/asm/bootloader.s")).path

  dependencies pfr("src/const/*.vhd"), pfr("src/*.vhd"), pfr("src/rs232c/*.vhd"),
    pfr("src/sram/sram_mock.vhd"), pfr("src/sram/sram_controller.vhd"),
    pfr("src/debug/*.vhd"), pfr("src/top/nemips.vhd"), inst_path

  asm = %q{
.text
  main:
    j rtn
    li r2, 3
    ow r2
    break
    halt
  rtn:
    li r2, 1
    ow r2
    break
    halt
  }
  instructions = InstRam.from_asm(asm).instructions

  generics io_wait: 1
  clock :clk

  context "bootloader parse" do
    context "j" do
      [*instructions, -1].each do |i|
        step write_length: "io_length_word", write_data: i
      end
      step write_length: "io_length_none"

      wait_step 2000
      step read_length: "io_length_word", read_data: 1, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :jmp, :jal do
  inst_path = InstRam.from_asm_path(pfr("test/asm/bootloader.s")).path

  dependencies pfr("src/const/*.vhd"), pfr("src/*.vhd"), pfr("src/rs232c/*.vhd"),
    pfr("src/sram/sram_mock.vhd"), pfr("src/sram/sram_controller.vhd"),
    pfr("src/debug/*.vhd"), pfr("src/top/nemips.vhd"), inst_path

  asm = %q{
.text
  main:
    jal rtn
    li r2, 3
    ow r2
    break
    halt
  rtn:
    li r2, 1
    ow r2
    jr r31
    break
    halt
  }
  instructions = InstRam.from_asm(asm).instructions

  generics io_wait: 1
  clock :clk

  context "bootloader parse" do
    context "jal" do
      [*instructions, -1].each do |i|
        step write_length: "io_length_word", write_data: i
      end
      step write_length: "io_length_none"

      wait_step 2000
      step read_length: "io_length_word", read_data: 1, read_ready: 1
      step read_length: "io_length_word", read_data: 3, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fib do
  inst_path = InstRam.from_asm_path(pfr("test/asm/bootloader.s")).path

  dependencies pfr("src/const/*.vhd"), pfr("src/*.vhd"), pfr("src/rs232c/*.vhd"),
    pfr("src/sram/sram_mock.vhd"), pfr("src/sram/sram_controller.vhd"),
    pfr("src/debug/*.vhd"), pfr("src/top/nemips.vhd"), inst_path

  asm = %q{
.text
  j	_min_caml_start
fib.10:
  li	r3, 1 # 7
  bgt	r2, r3, ble_else.24
  jr	r31
ble_else.24:
  addi	r3, r2, -1 # b
  sw	r2, 0(r29) # save argv[0] pc: c

  move	r2, r3
  sw	r31, -1(r29)
  addi	r29, r29, -2
  jal	fib.10 # fib(argv[0] - 1) pc: 10
  addi	r29, r29, 2
  lw	r31, -1(r29)
  lw	r3, 0(r29) # load argv[0]

  addi	r3, r3, -2 # argv[0] - 2
  sw	r2, -1(r29) # save fib(argv[0] - 1)

  move	r2, r3
  sw	r31, -2(r29)
  addi	r29, r29, -3
  jal	fib.10
  addi	r29, r29, 3
  lw	r31, -2(r29)
  lw	r3, -1(r29) # load fib(argv[0] - 2)

  add	r2, r3, r2 # fib(argv[0] - 2) + fib(argv[0] - 1)
  jr	r31
_min_caml_start: # main entry point
   # main program start
  li	r2, 0 # 1f
  sw	r31, 0(r29)
  addi	r29, r29, -1
  jal	fib.10 # 22
  addi	r29, r29, 1
  lw	r31, 0(r29)
  ow  r2
   # main program end
  jr r31
  }
  instructions = InstRam.from_asm(asm).instructions

  generics io_wait: 1
  clock :clk

  context "bootloader parse" do
    context "fib 3" do
      [*instructions, -1].each do |i|
        step write_length: "io_length_word", write_data: i
      end
      step write_length: "io_length_none"

      wait_step 5000
      step read_length: "io_length_word", read_data: 0, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fib do
  inst_path = InstRam.from_asm_path(pfr("test/asm/bootloader.s")).path

  dependencies pfr("src/const/*.vhd"), pfr("src/*.vhd"), pfr("src/rs232c/*.vhd"),
    pfr("src/sram/sram_mock.vhd"), pfr("src/sram/sram_controller.vhd"),
    pfr("src/debug/*.vhd"), pfr("src/top/nemips.vhd"), inst_path

  asm = %q{
.text
  j	_min_caml_start
fib.10:
  li	r3, 1 # 7
  bgt	r2, r3, ble_else.24
  jr	r31
ble_else.24:
  halt
_min_caml_start: # main entry point
   # main program start
  li	r2, 0 # 1f
  sw	r31, 0(r29)
  addi	r29, r29, -1
  jal	fib.10 # 22
  addi	r29, r29, 1
  lw	r31, 0(r29)
  ow  r2
   # main program end
  jr r31
  }
  instructions = InstRam.from_asm(asm).instructions

  generics io_wait: 1
  clock :clk

  context "bootloader parse" do
    context "fib 1" do
      [*instructions, -1].each do |i|
        step write_length: "io_length_word", write_data: i
      end
      step write_length: "io_length_none"

      wait_step 3000
      step read_length: "io_length_word", read_data: 0, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end


VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fib, :many, :heavy do
  inst_path = InstRam.from_asm_path(pfr("test/asm/bootloader.s")).path

  dependencies pfr("src/const/*.vhd"), pfr("src/*.vhd"), pfr("src/rs232c/*.vhd"),
    pfr("src/sram/sram_mock.vhd"), pfr("src/sram/sram_controller.vhd"),
    pfr("src/debug/*.vhd"), pfr("src/top/nemips.vhd"), inst_path

  asm = %q{
.text
  j	_min_caml_start
fib.10:
  li	r3, 1 # 7
  bgt	r2, r3, ble_else.24
  jr	r31
ble_else.24:
  addi	r3, r2, -1 # b
  sw	r2, 0(r29) # save argv[0] pc: c

  move	r2, r3
  sw	r31, -1(r29)
  addi	r29, r29, -2
  jal	fib.10 # fib(argv[0] - 1) pc: 10
  addi	r29, r29, 2
  lw	r31, -1(r29)
  lw	r3, 0(r29) # load argv[0]

  addi	r3, r3, -2 # argv[0] - 2
  sw	r2, -1(r29) # save fib(argv[0] - 1)

  move	r2, r3
  sw	r31, -2(r29)
  addi	r29, r29, -3
  jal	fib.10
  addi	r29, r29, 3
  lw	r31, -2(r29)
  lw	r3, -1(r29) # load fib(argv[0] - 2)

  add	r2, r3, r2 # fib(argv[0] - 2) + fib(argv[0] - 1)
  jr	r31
_min_caml_start: # main entry point
   # main program start
  li	r2, 0 # 1f
  sw	r31, 0(r29)
  addi	r29, r29, -1
  jal	fib.10 # 22
  addi	r29, r29, 1
  lw	r31, 0(r29)
  ow  r2
   # main program end
  jr r31
  }
  instructions = InstRam.from_asm(asm).instructions

  generics io_wait: 1
  clock :clk

  context "bootloader parse" do
    context "fib 3" do
      3.times do
        [*instructions, -1].each do |i|
          step write_length: "io_length_word", write_data: i
        end
        step write_length: "io_length_none"

        wait_step 5000
        step read_length: "io_length_word", read_data: 0, read_ready: 1
        step read_length: "io_length_byte", read_ready: 0
        step read_length: "io_length_none", read_ready: 0
      end
    end
  end
end

