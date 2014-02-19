require_relative 'copper_helper'
require_relative 'nemips_helper'

NemipsTestRunner.run do
  assemble %q{
.text
  main:
    addi r2, r0, 1
    ob r2
    halt
  }

  dut.scenario do |dut|
    wait_for(30)
    step {
      assert dut.read_length => 'io_length_word', read_data: 0x1, read_ready: 1
    }
  end
end
