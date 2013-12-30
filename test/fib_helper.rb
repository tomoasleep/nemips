
def fib_asm(fib_arg)
%Q{
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
  li	r2, #{fib_arg} # 1f
  sw	r31, 0(r29)
  addi	r29, r29, -1
  jal	fib.10 # 22
  addi	r29, r29, 1
  lw	r31, 0(r29)
  ow  r2
   # main program end
  break
  halt
}
end

def fib_test(fib_arg, fib_value)
  tags = [:fib, "fib#{fib_arg}".to_sym] + (fib_arg > 4 ? [:slow] : [])
  VhdlTestScript.scenario "./tb/nemips_tbq.vhd", *tags do
    asm = fib_asm(fib_arg)
    inst_path = InstRam.from_asm(asm).path

    dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
      "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
      "../src/top/nemips.vhd", inst_path

    generics io_wait: 4
    clock :clk

    context "fib #{fib_arg}" do
      wait_step(400 + 20 * (2 ** (fib_arg + 1)))
      step is_break: 1

      context("return #{fib_value}") do
        step read_length: "io_length_word", read_data: fib_value, read_ready: 1
      end
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end

def real_fib(i)
  if i <= 1 then i else real_fib(i - 1) + real_fib(i - 2) end
end

