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
use work.const_pipeline_state.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

use work.order_utils.all;
use work.pipeline_types.all;
use work.pipeline_utils.all;

use work.decode_order_functions.all;

entity pipeline_controller is
  port(
        decode_order : in order_type;

        exec_pipe: in exec_orders_type;
        memory_pipe: in memory_orders_type;

        write_back_order: in order_type;

        input_forwardings_mem : out input_forwardings_record;
        input_forwardings_wb : out input_forwardings_record;
        is_data_hazard : out boolean
      );
end pipeline_controller;

architecture behave of pipeline_controller is
  signal is_stall : boolean;
begin
  process(
    decode_order,
    exec_pipe,
    memory_pipe,
    write_back_order
  )
    variable decode_reginfo : register_info_type;
    variable composed_pipe : composed_pipe_type;

    type pipeline_judges_record is record
      int1 : pipeline_judge_type;
      int2 : pipeline_judge_type;
      float1 : pipeline_judge_type;
      float2 : pipeline_judge_type;
    end record;
    variable pipeline_judges : pipeline_judges_record;
  begin
    composed_pipe := compose_pipelines(
      exec_pipe,
      memory_pipe,
      write_back_order
    );
    decode_reginfo := register_info_of_order(decode_order);

    pipeline_judges.int1 := check_register_dependency_each(
      decode_reginfo.int_read1,
      true,
      composed_pipe
    );

    pipeline_judges.int2 := check_register_dependency_each(
      decode_reginfo.int_read2,
      true,
      composed_pipe
    );

    pipeline_judges.float1 := check_register_dependency_each(
      decode_reginfo.float_read1,
      false,
      composed_pipe
    );

    pipeline_judges.float2 := check_register_dependency_each(
      decode_reginfo.float_read2,
      false,
      composed_pipe
    );

    if pipeline_judges.int1 = stall or pipeline_judges.int2 = stall or
       pipeline_judges.float1 = stall or pipeline_judges.float2 = stall then
      is_stall <= true;
    else
      is_stall <= false;
    end if;

    input_forwardings_mem.int1   <= pipeline_judges.int1   = forwarding_mem;
    input_forwardings_mem.int2   <= pipeline_judges.int2   = forwarding_mem;
    input_forwardings_mem.float1 <= pipeline_judges.float1 = forwarding_mem;
    input_forwardings_mem.float2 <= pipeline_judges.float2 = forwarding_mem;

    input_forwardings_wb.int1   <= pipeline_judges.int1   = forwarding_wb;
    input_forwardings_wb.int2   <= pipeline_judges.int2   = forwarding_wb;
    input_forwardings_wb.float1 <= pipeline_judges.float1 = forwarding_wb;
    input_forwardings_wb.float2 <= pipeline_judges.float2 = forwarding_wb;

  end process;

  is_data_hazard <= is_stall;
end behave;
