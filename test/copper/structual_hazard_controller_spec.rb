require_relative 'copper_helper'

Copper::Scenario::Circuit.configure(:structual_hazards_controller).scenario do |dut|
  self.class.class_eval do
    define_method :reset do |ent|
      step {
        assign ent.decode_order => 0, ent.is_data_hazard => false,
          ent.pipeline_rest_length => 0
      }
    end
  end
  
  context 'alu order and rest_length = 2' do
    context 'don\'t stall' do
      step {
        assign dut.decode_order => instruction_i('i_op_addi', 1, 2, 3),
               dut.is_data_hazard => false,
               dut.pipeline_rest_length => 2
        assert dut.is_hazard => false
      }
    end
  end

  context 'alu order and rest_length = 3' do
    context 'stall' do
      step {
        assign dut.decode_order => instruction_i('i_op_addi', 1, 2, 3),
               dut.is_data_hazard => false,
               dut.pipeline_rest_length => 3
        assert dut.is_hazard => true
      }
    end
  end
end
