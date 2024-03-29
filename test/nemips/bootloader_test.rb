require_relative "../asm_helper.rb"
require_relative "../test_helper.rb"
require_relative './bootloader_helper.rb'

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :li, :ow, :jr do
  extend BootloaderHelper

  dependencies *path_dependencies, inst_path

  asm = %q{
.text
  main:
    li r2, 12
    ow r2
    jr r31
  }

  generics io_wait: 1
  clock :clk

  write_insts_from_asm(asm)
  context "bootloader parse" do
    context "li, ow, jr" do
      wait_step 500
      step read_length: "io_length_word", read_data: 12, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
      step read_length: "io_length_none"
    end
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :input, :ih do
  extend BootloaderHelper

  dependencies *path_dependencies, inst_path

  asm = %q{
.text
  main:
    ih r2
    oh r2
    halt
  }

  generics io_wait: 1
  clock :clk

  write_insts_from_asm(asm)
  context "bootloader parse" do
    context "input output halfword" do
      wait_step 200
      step write_length: "io_length_halfword", write_data: 0x1234
      step write_length: "io_length_none"
      wait_step 700

      step read_length: "io_length_halfword", read_data: 0x1234, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :input do
  extend BootloaderHelper

  dependencies *path_dependencies, inst_path

  asm = %q{
.text
  main:
    ib r2
    ob r2
    halt
  }

  generics io_wait: 1
  clock :clk

  write_insts_from_asm(asm)
  context "bootloader parse" do
    context "input output" do
      wait_step 200
      step write_length: "io_length_byte", write_data: 5
      step write_length: "io_length_none"
      wait_step 300

      step read_length: "io_length_byte", read_data: 5, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end



VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :many do
  extend BootloaderHelper

  dependencies *path_dependencies, inst_path

  asm = %q{
.text
  main:
    li r2, 12
    ow r2
    jr r31
  }

  generics io_wait: 1
  clock :clk

  3.times do
    write_insts_from_asm(asm)
    context "bootloader parse" do
      context "manytimes" do
        wait_step 500
        step read_length: "io_length_word", read_data: 12, read_ready: 1
        step read_length: "io_length_byte", read_ready: 0
        step read_length: "io_length_none"
      end
    end
  end
end


VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :branch, :bne do
  extend BootloaderHelper

  dependencies *path_dependencies, inst_path

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

  generics io_wait: 1
  clock :clk

  write_insts_from_asm(asm)
  context "bootloader parse" do
    context "branch" do
      wait_step 1000
      step read_length: "io_length_word", read_data: 1, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :jmp, :j do
  extend BootloaderHelper

  dependencies *path_dependencies, inst_path

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

  generics io_wait: 1
  clock :clk

  write_insts_from_asm(asm)
  context "bootloader parse" do
    context "j" do
      wait_step 1000
      step is_break: 1
      step read_length: "io_length_word", read_data: 1, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :jmp, :jal do
  extend BootloaderHelper

  dependencies *path_dependencies, inst_path

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

  generics io_wait: 1
  clock :clk

  write_insts_from_asm(asm)
  context "bootloader parse" do
    context "jal" do
      wait_step 1000
      step read_length: "io_length_word", read_data: 1, read_ready: 1
      step read_length: "io_length_word", read_data: 3, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fib, :slow do
  extend BootloaderHelper

  dependencies *path_dependencies, inst_path

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

  generics io_wait: 1
  clock :clk

  write_insts_from_asm(asm)
  context "bootloader parse" do
    context "fib 3" do
      wait_step 3000
      step read_length: "io_length_word", read_data: 0, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fib do
  extend BootloaderHelper

  dependencies *path_dependencies, inst_path

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
  generics io_wait: 1
  clock :clk

  write_insts_from_asm(asm)

  context "bootloader parse" do
    context "fib 1" do
      wait_step 3000
      step read_length: "io_length_word", read_data: 0, read_ready: 1
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end


VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fib, :many, :slow do
  extend BootloaderHelper

  dependencies *path_dependencies, inst_path

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
  generics io_wait: 1
  clock :clk


  3.times do
    write_insts_from_asm(asm)
    context "bootloader parse" do
      context "fib 3" do
        wait_step 2000
        step read_length: "io_length_word", read_data: 0, read_ready: 1
        step read_length: "io_length_byte", read_ready: 0
        step read_length: "io_length_none", read_ready: 0
      end
    end
  end
end

# VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :twice do
#   extend BootloaderHelper
# 
#   dependencies *path_dependencies, inst_path
# 
#   asm_first = %q{
#   .data
#     zero:
#       .int 0
#   .text
#     main:
#       nop
#       li r1, 4
#       ob r1
#       jr r31
#   }
#   generics io_wait: 1
#   clock :clk
# 
#   global_var_address = 0
# 
#   jump_code = 0x03e00008
# 
#   write_insts_from_asm(asm_first)
#   write_insts_from_asm(".text\nbreak")
# 
#   context "bootloader load instruction twice" do
#     context "execute ob once" do
#       wait_step 1500
#       step read_length: 'io_length_byte', read_data:  4, read_ready: 1
#       step read_length: 'io_length_byte', read_ready: 0
#       step read_length: 'io_length_none'
#       step is_break: 1
#       step sram_debug_addr: global_var_address, sram_debug_data: jump_code
#     end
#   end
# end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :la, :jr do
  extend BootloaderHelper

  dependencies *path_dependencies, inst_path

  asm = %q{
  .text
    start:
      j main
    jump_here:
      ob r0
      break
    main:
      la r1, jump_here
      jr r1
  }
  generics io_wait: 1
  clock :clk

  write_insts_from_asm(asm)

  context "bootloader" do
    context "can jr with immediate register" do
      wait_step 500
      step is_break: 1
      step read_length: 'io_length_byte', read_data: 0, read_ready: 1
      step read_length: 'io_length_none'
    end
  end
end

