require_relative 'copper_helper'
require_relative 'nemips_helper'

NemipsTestRunner.run do
  binary [
    0x20020001, # addi r2, r0, 1
    0x7840000c, # ob r2
    0x00000000, # nop
    0x08000008  # halt
  ]

  dut.scenario do |dut|
    wait_for(50)

    step {
      assign dut.read_length => 'io_length_word'
      assert dut.read_data => 0x1
    }
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

    step {
      assign dut.read_length => 'io_length_word'
      assert dut.read_data => 0x1
    }
  end
end
