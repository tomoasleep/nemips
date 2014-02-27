require_relative 'copper_helper'
require_relative 'nemips_helper'
require_relative '../fib_helper'

Copper::Scenario::Description.class_eval do
  include InstructionSend
end

NemipsTestRunner.run do
  bootloader
  inst =  [
    0x20020001, # addi r2, r0, 1
    0x7840000c, # ob r2
    0x00000000, # nop
    0x08000003  # halt
  ]

  dut.scenario do |dut|
    write_insts(inst)
    wait_for(50)

    context 'binary' do
      step {
        assign dut.read_length => 'io_length_word'
        assert dut.read_data_past => 0x1
      }
    end
  end
end

