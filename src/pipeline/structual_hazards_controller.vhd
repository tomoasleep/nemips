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
        use_cache: in boolean;
        pipeline_rest_length : in pipeline_length_type;
        ex_pipeline_rest_length : in pipeline_length_type;

        is_hazard : out boolean;
        next_pipeline_rest_length : out pipeline_length_type;
        next_ex_pipeline_rest_length : out pipeline_length_type
      );
end structual_hazards_controller;

architecture behave of structual_hazards_controller is
  signal is_stall : boolean;
  signal decode_stage_exmem_length : pipeline_length_type;
  signal decode_stage_ex_length : pipeline_length_type;
  signal pipe_len : pipeline_length_type;

  function decrement(
    pipe : in pipeline_length_type
  ) return pipeline_length_type is
  begin
    if unsigned(pipe) = 0 then
      return pipe;
    else
      return std_logic_vector(signed(pipe) - 1);
    end if;
  end function;

  function shortcut(
    pipe : in pipeline_length_type
  ) return pipeline_length_type is
  begin
    if unsigned(pipe) < 4 then
      return (others => '0');
    else
      return std_logic_vector(signed(pipe) - 4);
    end if;
  end function;

begin
  decode_stage_exmem_length <= pipeline_exmem_length_count(decode_order);
  decode_stage_ex_length <= pipeline_ex_length_count(decode_order);
  pipe_len <= shortcut(pipeline_rest_length) when use_cache else pipeline_rest_length;
  process(
    decode_stage_exmem_length,
    is_data_hazard,
    pipe_len,
    ex_pipeline_rest_length
  )
  begin
    if is_data_hazard then
      -- TODO min = 0
      next_pipeline_rest_length <= decrement(pipe_len);
      next_ex_pipeline_rest_length <= decrement(ex_pipeline_rest_length);
      is_hazard <= true;
    else
      if decode_stage_exmem_length < pipe_len or
         decode_stage_ex_length < ex_pipeline_rest_length then
        next_pipeline_rest_length <= decrement(pipe_len);
        next_ex_pipeline_rest_length <= decrement(ex_pipeline_rest_length);
        is_hazard <= true;
      else
        next_pipeline_rest_length <= decode_stage_exmem_length;
        next_ex_pipeline_rest_length <= decode_stage_ex_length;
        is_hazard <= false;
      end if;
    end if;
  end process;

end behave;
