require_relative 'copper_helper'

Copper::Scenario::Circuit.configure(:pipeline_controller).scenario do |dut|
  self.class.class_eval do
    define_method :reset do |ent|
      step {
        assign dut.decode_order => 0
        assign ent.exec_pipe =>
          ent.exec_pipe.length.times.map { 0 }
        assign ent.memory_pipe =>
          ent.memory_pipe.length.times.map { 0 }
      }
    end
  end

  context 'all order is nop' do
    context 'don\'t stall' do
      step {
        assign dut.decode_order => 0
        assign dut.exec_pipe =>
          dut.exec_pipe.length.times.map { 0 }
        assign dut.memory_pipe =>
          dut.memory_pipe.length.times.map { 0 }
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
                 dut.exec_pipe =>
                   [instruction_i('i_op_addi', 2, 3, 4), 0, 0]
          assert dut.is_data_hazard => false
        }
      end
    end

    reset(dut)

    context 'read and write' do
      context 'stall' do
        step {
          assign({
            dut.decode_order => instruction_i('i_op_addi', 2, 3, 4),
            dut.exec_pipe => [instruction_i('i_op_addi', 3, 2, 4), 0, 0],
          })
          assert dut.is_data_hazard => true
        }
      end
    end
  end

  reset(dut)

  # TODO: Fix copper
  context 'decode stage and memory stage use same register' do
    context 'read and write' do
      context 'forwarding' do
        step {
          assign dut.decode_order => instruction_i('i_op_addi', 2, 3, 4),
                 dut.memory_pipe =>
                    [0, 0, 0, 0, instruction_i('i_op_addi', 3, 2, 4)]
          assert dut.is_data_hazard => false
          assert dut.input_forwardings => { 'int1' => true }
        }
      end
    end
  end

  reset(dut)

  context 'decode stage and memory stage use same register' do
    context 'read and write' do
      context 'stall' do
        step {
          assign dut.decode_order =>
                    instruction_i('i_op_sw', 0, 1, 20)
          assign dut.exec_pipe =>
                    [0, 0, instruction_i('i_op_addi', 0, 1, 12)]
          assign dut.memory_pipe =>
                    [0, 0, 0, 0, instruction_i('i_op_addi', 29, 29, -1)]
          assert dut.is_data_hazard => true
        }
      end
    end
  end

  context 'decode stage and memory stage use same register' do
    context 'read and write' do
      context 'forwarding' do
        step {
          assign dut.decode_order =>
                    instruction_r('i_op_io', 1, 0, 0, 0, 'io_fun_ow')
          assign dut.exec_pipe =>
                    [0, 0, 0]
          assign dut.memory_pipe =>
                    [0, 0, 0, 0, instruction_i('i_op_lw', 1, 1, 12)]
          assert dut.is_data_hazard => false
          assert dut.input_forwardings => { 'int1' => true }
        }
      end
    end
  end
end

