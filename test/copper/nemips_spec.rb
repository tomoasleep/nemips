require_relative 'copper_helper'
require_relative 'nemips_helper'
require_relative '../fib_helper'

NemipsTestRunner.run do
  binary [
    0x20020001, # addi r2, r0, 1
    0x7840000c, # ob r2
    0x00000000, # nop
    0x08000003  # halt
  ]

  dut.scenario do |dut|
    wait_for(50)

    context 'binary' do
      step {
        assign dut.read_length => 'io_length_word'
        assert dut.read_data_past => 0x1
      }
    end
  end
end

NemipsTestRunner.run do
  assemble %q{
.text
  main:
    addi r2, r0, 1
    ob r2
    halt
  }

  dut.scenario do |dut|
    wait_for(50)

    context 'asm' do
      step {
        assign dut.read_length => 'io_length_word'
        assert dut.read_data_past => 0x1
      }
    end
  end
end

NemipsTestRunner.run do
# , :branch, :bne do
  assemble %q{
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

  dut.scenario do |dut|
    context "can branch (bne)" do
      wait_for(100)

      step {
        assign dut.read_length => "io_length_byte"
        assert dut.read_data_past => 1
      }
    end
  end
end

# VhdlTestScript.scenario "./tb/nemips_tbq.vhd", :branch, :bltz, :bgez do
NemipsTestRunner.run do
  assemble %q{
.text
    li r4, 12
    li r5, 0
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
  dut.scenario do |dut|
    context "bltz, bgez" do
      wait_for(400)

      context "bltz doesn't jump when src(= 12)" do
        step {
          assign dut.read_length => "io_length_word"
          assert dut.read_data_past => 0
        }
      end
      context "bltz doesn't jumps when src(= 0)" do
        step {
          assign dut.read_length => "io_length_word"
          assert dut.read_data_past => 0
        }
      end
      context "bgez jumps when src(= 12)" do
        step {
          assign dut.read_length => "io_length_word"
          assert dut.read_data_past => 1
        }
      end
      context "bgez jump when src(= 0)" do
        step {
          assign dut.read_length => "io_length_word"
          assert dut.read_data_past => 1
        }
      end
    end
  end
end

# VhdlTestScript.scenario "./tb/nemips_tb.vhd", :memory, :sw, :ow do
NemipsTestRunner.run do
  assemble %q{
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

  dut.scenario do |dut|
    context "can memory load" do
      wait_for(300)
      step {
        assign dut.sram_debug_addr => 20
        assert dut.sram_debug_data => 12
      }
      step {
        assign dut.read_length => "io_length_word"
        assert dut.read_data_past => 12
      }
      step {
        assign dut.read_length => "io_length_byte"
        assert dut.read_data_past => 0
      }
    end
  end
end

NemipsTestRunner.run do
  assemble %q{
.text
  main:
    li r2, 1
    li r3, 2
    li r4, 3
    li r5, 4
    ob r2
    ob r3
    ob r4
    ob r5
    j main2
    nop
    nop
    nop
    nop
  main2:
    li r2, 1
    li r3, 2
    li r4, 3
    li r5, 4
    ob r2
    ob r3
    ob r4
    ob r5
    halt
  }

  dut.scenario do |dut|
    context "can seqential io" do
      wait_for(300)

      2.times do
        (1..4).each do |i|
          step {
            assign dut.read_length => "io_length_byte"
            assert dut.read_data_past => i
          }
        end
      end
    end
  end
end

NemipsTestRunner.run do
  assemble %q{
.text
  main:
    li r3, 12
    li r6, 10
    li r5, 20
    sw r5, 20(r3)
    sw r6, 19(r3)
    li r3, 20
    lw r5, 11(r3)
    lw r6, 12(r3)
    ow r5
    ow r6
    break
    halt
  }

  dut.scenario do |dut|
    context "can seqential memory load" do
      wait_for(300)
      step {
        assign dut.sram_debug_addr => 32
        assert dut.sram_debug_data => 20
      }
      step {
        assign dut.sram_debug_addr => 31
        assert dut.sram_debug_data => 10
      }
      step {
        assign dut.read_length => "io_length_word"
        assert dut.read_data_past => 10
      }
      step {
        assign dut.read_length => "io_length_word"
        assert dut.read_data_past => 20
      }
    end
  end
end

NemipsTestRunner.run do
  assemble fib_asm(0)

  dut.scenario do |dut|
    wait_for(150)

    context 'real_fib 0' do
      step {
        assign dut.read_length => 'io_length_word'
        assert dut.read_data_past => real_fib(0)
      }
    end
  end
end

NemipsTestRunner.run do
  assemble fib_asm(1)

  dut.scenario do |dut|
    wait_for(150)

    context 'real_fib 1' do
      step {
        assign dut.read_length => 'io_length_word'
        assert dut.read_data_past => real_fib(1)
      }
    end
  end
end

NemipsTestRunner.run do
  assemble fib_asm(2)

  dut.scenario do |dut|
    wait_for(150)

    context 'real_fib 2' do
      step {
        assign dut.read_length => 'io_length_word'
        assert dut.read_data_past => real_fib(2)
      }
    end
  end
end

NemipsTestRunner.run do
  assemble fib_asm(3)

  dut.scenario do |dut|
    wait_for(300)

    context 'real_fib 3' do
      step {
        assign dut.read_length => 'io_length_word'
        assert dut.read_data_past => real_fib(3)
      }
    end
  end
end

NemipsTestRunner.run do
  assemble %q{
.text
    j main
  IOReadFault:
    addi r28, r28, 1
    jr r28
  main:
    li r2, 1
    ib r2
    ob r2
    halt
  }

  dut.scenario do |dut|
    context "cause io exception" do
      wait_for(300)
      step {
        assign dut.read_length => "io_length_byte"
        assert dut.read_data_past => 1
      }
    end
  end
end

NemipsTestRunner.run do
  assemble %q{
.text
    li r2, 1
    j main
  main:
    nop
    ib r2
    ob r2
    break
    halt
  }

  dut.scenario do |dut|
    step { assign dut.write_data => 2,
                  dut.write_length => 'io_length_byte' }
    step { assign dut.write_length => 'io_length_none' }

    context 'don\'t cause io exception' do
      wait_for(300)
      step {
        assign dut.read_length => "io_length_byte"
        assert dut.read_data_past => 2
      }
    end
  end
end

