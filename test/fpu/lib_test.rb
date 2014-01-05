require_relative '../test_helper.rb'
require_relative '../asm_helper.rb'

dep_pathes = [*path_dependencies, *FADD_PATHES, *FMUL_PATHES, *FINV_PATHES]
libmincaml_path = pfr('test/asm/libmincaml.S')
libmincaml_asm = File.read(libmincaml_path)
mini_mandelbrot_path = pfr('test/asm/mini-mandelbrot.s')
mini_mandelbrot_asm = File.read(mini_mandelbrot_path)
mini_mandelbrot_debug_path = pfr('test/asm/mini-mandelbrot_debug.s')
mini_mandelbrot_debug_asm = File.read(mini_mandelbrot_debug_path)

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :lib, :itof do
  asm = %q{
.text
  main:
    li r2, 1
    jal min_caml_float_of_int
    fmvi r3, f2
    ow r3
    break
    halt
  }
  inst_path = InstRam.from_asm(asm + libmincaml_asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "call library function float_of_int(1) returns 1.0" do
    wait_step 350
    step read_length: "io_length_word", read_data: 1.0.to_binary, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :lib, :read_float do
  asm = %q{
.text
  main:
    jal min_caml_read_float
    fmvi r3, f2
    ow r3
    break
    halt
  }
  inst_path = InstRam.from_asm(asm + libmincaml_asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "call library function read_float returns 1.0" do
    step write_length: "io_length_word", write_data: 1.0.to_binary
    step write_length: "io_length_none"
    wait_step 600
    step read_length: "io_length_word", read_data: 1.0.to_binary, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :itof do
  asm = %q{
.text
  main:
    li r2, 1
    jal min_caml_float_of_int
    fmvi r3, f2
    ow r3
    break
    halt
  }
  inst_path = InstRam.from_asm(asm + libmincaml_asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "call library function float_of_int(1) returns 1.0" do
    wait_step 350
    step read_length: "io_length_word", read_data: 1.0.to_binary, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :print_int do
  asm = %q{
.text
  main:
    li r2, 2
    jal min_caml_print_int
    li r2, 10
    jal min_caml_print_int
    break
    halt
  }
  inst_path = InstRam.from_asm(asm + libmincaml_asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "call library function print_int 2 and 10" do
    wait_step 400
    step is_break: 1
    step read_length: "io_length_byte", read_data: '2'.ord, read_ready: 1
    step read_length: "io_length_byte", read_data: '1'.ord, read_ready: 1
    step read_length: "io_length_byte", read_data: '0'.ord, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :mandelbrot do
  inst_path = InstRam.from_asm(mini_mandelbrot_asm + libmincaml_asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1, sram_length: 15
  clock :clk

  context "call library function mandelbrot (2 * 2)" do
    wait_step 20000
    step is_break: 1
    %w(0 0 1 1).each_with_index do |ch, i|
      context("bit (#{i / 2}, #{i % 2}) = #{ch.ord}") do
        step read_length: "io_length_byte", read_data: ch.ord, read_ready: 1
      end
    end
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :mini do
  inst_path = InstRam.from_asm(mini_mandelbrot_debug_asm + libmincaml_asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1, sram_length: 15
  clock :clk

  context "call library function mandelbrot" do
    wait_step 2000
    step is_break: 1
    context("bit (0, 0) xloop first") do
      context("x.to_f = 0.0") do
        step read_length: "io_length_word", read_data: 0.0, read_ready: 1
      end
      context("dbl (x.to_f) / xrangef = 0.0") do
        step read_length: "io_length_word", read_data: 0.0, read_ready: 1
      end
    end
    context("bit (0, 0) iloop first(cr, ci) = -1.5, -1.0") do
      step read_length: "io_length_word", read_data: -1.5, read_ready: 1
      step read_length: "io_length_word", read_data: -1.0, read_ready: 1
    end
    context("bit (0, 0) iloop first = 3.25") do
      step read_length: "io_length_word", read_data: 3.25, read_ready: 1
    end
    step read_length: "io_length_byte", read_ready: 0
  end
end

