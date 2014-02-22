library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_state.all;
use work.const_mux.all;
use work.const_alu_ctl.all;
use work.const_fpu_ctl.all;
use work.const_io.all;
use work.const_sram_cmd.all;
use work.const_opcode.all;

use work.typedef_opcode.all;

use work.order_utils.all;
use work.pipeline_types.all;
use work.pipeline_utils.all;

entity structual_hazards_controller is
  port(
        decode_order : in order_type;
        is_data_hazard : in boolean;
        pipeline_rest_length : in pipeline_length_type;

        is_hazard : out boolean;
        next_pipeline_rest_length : out pipeline_length_type
      );
end structual_hazards_controller;

architecture behave of structual_hazards_controller is
  signal is_stall : boolean;
  signal decode_stage_exmem_length : pipeline_length_type;
begin
  decode_stage_exmem_length <= pipeline_exmem_length_count(decode_order);

  process(
    decode_stage_exmem_length,
    is_data_hazard,
    pipeline_rest_length
  )
  begin
    if is_data_hazard then
      -- TODO min = 0
      next_pipeline_rest_length <= std_logic_vector(signed(pipeline_rest_length) - 1);
      is_hazard <= true;
    else
      if decode_stage_exmem_length < pipeline_rest_length then
        next_pipeline_rest_length <= std_logic_vector(unsigned(pipeline_rest_length) - 1);
        is_hazard <= true;
      else
        next_pipeline_rest_length <= decode_stage_exmem_length;
        is_hazard <= false;
      end if;
    end if;
  end process;

end behave;
