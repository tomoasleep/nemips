require_relative '../test_helper.rb'
require_relative '../asm_helper.rb'
require_relative './float_fib_helper.rb'

dep_pathes = [*path_dependencies, *FADD_PATHES]

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fib, :ffib do
  asm = %q{
.text
	j	_min_caml_start
fibf.11:
	fli	f3, 2.
	fbgt	f3, f2, fble_else.29
	fli	f3, 1.
	fsub	f3, f2, f3
	swf	f2, 0(r29)
	fmove	f2, f3
	sw	r31, -1(r29)
	addi	r29, r29, -2
	jal	fibf.11
	addi	r29, r29, 2
	lw	r31, -1(r29)
	fli	f3, 2.
	lwf	f4, 0(r29)
	fsub	f3, f4, f3
	swf	f2, -1(r29)
	fmove	f2, f3
	sw	r31, -2(r29)
	addi	r29, r29, -3
	jal	fibf.11
	addi	r29, r29, 3
	lw	r31, -2(r29)
	lwf	f3, -1(r29)
	fadd	f2, f3, f2
	jr	r31
fble_else.29:
	jr	r31
_min_caml_start: # main entry point
   # main program start
	fli	f2, 2
	sw	r31, 0(r29)
	addi	r29, r29, -1

	jal	fibf.11

  fmvi r2, f2
  ow r2

	addi	r29, r29, 1
	lw	r31, 0(r29)
  break
   # main program end
	halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "ffib(2.0) returns 1.0" do
    wait_step 1000
    step is_break: 1
    step read_length: "io_length_word", read_data: 1.0.to_binary, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

7.times.map(&:to_f).each { |i| float_fib_test(i, real_float_fib(i))}
