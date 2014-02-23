require_relative 'copper_helper'

Copper::Scenario::Circuit.configure(:ex_path).scenario do |dut|
  context 'branch' do
    context 'beq' do
      context 'go (1, 1)' do
        step {
          assign dut.int_rd1 => 1, dut.int_rd2 => 1
          assign dut.order => instruction_i('i_op_beq', 1, 2, 3)
          assign dut.pc => 0

          assert dut.pc_jump => 4
          assert dut.jump_enable => true
        }
      end

      context 'don\'t go (1, 2)' do
        step {
          assign dut.int_rd1 => 1, dut.int_rd2 => 2
          assign dut.order => instruction_i('i_op_beq', 1, 2, 3)
          assign dut.pc => 0

          assert dut.jump_enable => false
        }
      end
    end

    context 'bltz' do
      context 'go (-1)' do
        step {
          assign dut.int_rd1 => -1, dut.int_rd2 => 0
          assign dut.order => instruction_i('i_op_bltz', 1, 2, 3)
          assign dut.pc => 0

          assert dut.pc_jump => 4
          assert dut.jump_enable => true
        }
      end

      context 'don\'t go (0)' do
        step {
          assign dut.int_rd1 => 0, dut.int_rd2 => 0
          assign dut.order => instruction_i('i_op_bltz', 1, 2, 3)
          assign dut.pc => 0

          assert dut.jump_enable => false
        }
      end

      context 'don\'t go (1)' do
        step {
          assign dut.int_rd1 => 1, dut.int_rd2 => 0
          assign dut.order => instruction_i('i_op_bltz', 1, 2, 3)
          assign dut.pc => 0

          assert dut.jump_enable => false
        }
      end
    end
  end
end
