require_relative 'copper_helper'

circuit = Copper::Scenario::Circuit.configure(:ex_path) do |dut|
  clock dut.clk
end

circuit.scenario do |dut|
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

    context 'fadd' do
      context '1.0 + 1.0 = 2.0' do
        step {
          assign dut.float_rd1 => 1.0, dut.float_rd2 => 1.0
          assign dut.order => instruction_r('i_op_f_group', 1, 2, 3, 0, 'f_fun_fadd')
        }

        step {
          assign dut.float_rd1 => 0, dut.float_rd2 => 0
          assign dut.order => 0
          assert dut.result_data => 2.0
          assert dut.result_order => instruction_r('i_op_f_group', 1, 2, 3, 0, 'f_fun_fadd')
        }
      end
    end

    context 'imvf' do
      context 'move int register to float register' do
        step {
          assign dut.int_rd1 => 2.0, dut.int_rd2 => 0
          assign dut.order => instruction_i('i_op_imvf', 1, 2, 3)
          assert dut.result_data => 2.0
        }
      end
    end

    context 'fmvi' do
      context 'move float register to int register' do
        step {
          assign dut.float_rd1 => 3.0, dut.float_rd2 => 0
          assign dut.order => instruction_i('i_op_fmvi', 1, 2, 3)
          assert dut.result_data => 3.0
        }
      end
    end
  end
end
