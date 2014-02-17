require_relative 'copper_helper'

Copper::Scenario::Circuit.configure(:pipeline_controller).scenario do |dut|
  self.class.class_eval do
    define_method :reset do |ent|
      step {
        assign ent.decode_order => 0, ent.exec_first_order => 0,
          ent.memory_first_order => 0, ent.write_back_order => 0
        assign ent.exec_pipe => [{'order' => 0, 'state' => 'exec_state_nop'}]
        assign ent.memory_pipe =>
          ent.memory_pipe.length.times.map { {'order' => 0, 'state' => 'memory_state_nop'} }
      }
    end
  end

  context 'all order is nop' do
    context 'don\'t stall' do
      step {
        assign dut.decode_order => 0, dut.exec_first_order => 0,
          dut.memory_first_order => 0, dut.write_back_order => 0
        assign dut.exec_pipe => [{'order' => 0, 'state' => 'exec_state_nop'}]
        assign dut.memory_pipe =>
          dut.memory_pipe.length.times.map { {'order' => 0, 'state' => 'memory_state_nop'} }
        assert dut.is_data_hazard => false
      }
    end
  end

  context 'only decode stage has alu order' do
    context 'don\'t stall' do
      step {
        assign dut.decode_order => instruction_i('i_op_addi', 2, 3, 4)
        assert dut.is_data_hazard => false
      }
    end
  end

  reset(dut)

  context 'decode stage and exec stage use same register' do
    context 'read and read' do
      context 'don\'t stall' do
        step {
          assign dut.decode_order => instruction_i('i_op_addi', 2, 3, 4),
                 dut.exec_first_order => instruction_i('i_op_addi', 2, 3, 4)
          assert dut.is_data_hazard => false
        }
      end
    end

    reset(dut)

    context 'read and write' do
      context 'stall' do
        step {
          assign dut.decode_order => instruction_i('i_op_addi', 2, 3, 4),
                 dut.exec_first_order => instruction_i('i_op_addi', 3, 2, 4)
          assert dut.is_data_hazard => true
        }
      end
    end
  end
end
  
