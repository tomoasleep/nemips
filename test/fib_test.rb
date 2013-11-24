require_relative "./asm_helper.rb"
require_relative "./fib_helper.rb"

(0..10).each {|i| fib_test(i, real_fib(i)) }

VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :fib, :fib_debug do
  asm = %q{
.text
  j	_min_caml_start
fib.10:
  li	r3, 1
  bgt	r2, r3, ble_else.24
  jr	r31
ble_else.24:
  addi	r3, r2, -1
  sw	r2, 0(r29) # save argv[0]

  move	r2, r3
  sw	r31, -1(r29)
  addi	r29, r29, -2
  jal	fib.10 # fib(argv[0] - 1)
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
  lw	r3, -1(r29) # load fib(argv[0] - 1)
  move r4, r2

  add	r2, r3, r4 # fib(argv[0] - 1) + fib(argv[0] - 2)
  jr	r31
_min_caml_start: # main entry point
   # main program start
  li	r2, 4
  sw	r31, 0(r29)
  addi	r29, r29, -1
  jal	fib.10
  addi	r29, r29, 1
  lw	r31, 0(r29)
  ow  r2
  ow  r3
  ow  r4
   # main program end
  break
  halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 4
  clock :clk

  context "fib 4" do
    step reset: 1; step reset: 0
    wait_step 4000
    step is_break: 1
    step read_length: "io_length_word", read_data:  3, read_ready: 1
    step read_length: "io_length_word", read_data:  2, read_ready: 1
    step read_length: "io_length_word", read_data:  1, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

