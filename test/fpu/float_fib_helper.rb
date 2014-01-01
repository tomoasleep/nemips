
def float_fib_asm(fib_arg)
%Q{
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
	fli	f2, #{fib_arg}
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
end

def float_fib_test(fib_arg, fib_value)
  tags = [:ffib, "ffib#{fib_arg}".to_sym] + (fib_arg > 4.0 ? [:slow] : [])

  VhdlTestScript.scenario "../tb/nemips_tbq.vhd", *tags do
    asm = float_fib_asm(fib_arg)
    inst_path = InstRam.from_asm(asm).path

    dependencies inst_path, *[*path_dependencies, *FADD_PATHES]


    generics io_wait: 1
    clock :clk

    context "ffib(#{fib_arg})" do
      wait_step(400 + 40 * (2 ** (fib_arg.to_i + 1)))
      step is_break: 1

      context("returns #{fib_value}") do
        step read_length: "io_length_word", read_data: fib_value.to_binary, read_ready: 1
      end
      step read_length: "io_length_byte", read_ready: 0
    end
  end
end

def real_float_fib(i)
  if i <= 1.0 then i else real_float_fib(i - 1.0) + real_float_fib(i - 2.0) end
end

