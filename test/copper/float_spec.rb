require_relative 'copper_helper'
require_relative 'nemips_helper'
require_relative '../fib_helper'

mini_mandelbrot_path = pfr('test/asm/mini-mandelbrot.s')
mini_mandelbrot_asm = File.read(mini_mandelbrot_path)
mini_mandelbrot_debug_path = pfr('test/asm/mini-mandelbrot_debug.s')
mini_mandelbrot_debug_asm = File.read(mini_mandelbrot_debug_path)

NemipsTestRunner.run do
  assemble %q{
.data
F1:
.float 1.0 
.text
  main:
    la  r10, F1
    lwf f10, 0(r10)
    finv f4, f10
    fmvi r4, f4
    ow r4
    break
    halt
  }

  dut.scenario do |dut|
    wait_for 350

    context "finv(1.0) = 1.0" do
      step {
        assign dut.read_length => "io_length_word"
        assert dut.read_data_past => 1.0
      }
    end
  end
end

NemipsTestRunner.run do
  assemble %q{
.text
  main:
    fli f2, 400.
    finv f3, f2
    owf f3
    break
  }

  dut.scenario do |dut|
    wait_for 350

    context "1.0 / 400.0 = 0x3b23d70" do
      step {
        assign dut.read_length => "io_length_word"
        assert dut.read_data_past => 0x3b23d70a
      }
    end
  end
end

NemipsTestRunner.run do
  libmincaml %q{
.text
  main:
    li r2, 1
    jal min_caml_float_of_int
    fmvi r3, f2
    ow r3
    halt
  }

  dut.scenario do |dut|
    wait_for 350

    context "call library function float_of_int(1) returns 1.0" do
      step {
        assign dut.read_length => 'io_length_word'
        assert dut.read_data_past => 1.0
      }
    end
  end
end

NemipsTestRunner.run do
  libmincaml mini_mandelbrot_asm

  dut.scenario do |dut|
    wait_for 350

    context "call library function mandelbrot (2 * 2)" do
      wait_for 5000
      %w(0 0 1 1).each_with_index do |ch, i|
        context("bit (#{i / 2}, #{i % 2}) = #{ch.ord}") do
          step {
            assign dut.read_length => 'io_length_byte'
            assert dut.read_data_past => ch.ord
          }
        end
      end
    end
  end
end

NemipsTestRunner.run do
  libmincaml mini_mandelbrot_debug_asm

  dut.scenario do |dut|
    context "call library function mandelbrot" do
      wait_for 2000

      context("bit (0, 0) xloop first") do
        context("x.to_f = 0.0") do
          step {
            assign dut.read_length => 'io_length_word'
            assert dut.read_data_past => 0.0
          }
        end
        context("dbl (x.to_f) / xrangef = 0.0") do
          step {
            assign dut.read_length => 'io_length_word'
            assert dut.read_data_past => 0.0
          }
        end
      end
      context("bit (0, 0) iloop first(cr, ci) = -1.5, -1.0") do
        step {
          assign dut.read_length => 'io_length_word'
          assert dut.read_data_past => -1.5
        }
        step {
          assign dut.read_length => 'io_length_word'
          assert dut.read_data_past => -1.0
        }
      end
      context("bit (0, 0) iloop first = 3.25") do
        step {
          assign dut.read_length => 'io_length_word'
          assert dut.read_data_past => 3.25
        }
      end
    end
  end
end

