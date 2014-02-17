library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_pipeline_state.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

package pipeline_types is
  constant jal_register : register_addr_type := "11111";

  type memory_pipe_record is record
    order : order_type;
    state : memory_state_type;
  end record;

  constant init_memory_record : memory_pipe_record := (
    order => (others => '0'),
    state => (others => '0')
  );
  constant memory_pipe_length : integer := 2;
  -- memory_pipe_length - 1
  type memory_pipe_buffer_type is array(0 to 1) of memory_pipe_record;

  type exec_pipe_record is record
    order : order_type;
    state : exec_state_type;
  end record;

  constant init_exec_record : exec_pipe_record := (
    order => (others => '0'),
    state => (others => '0')
  );
  constant exec_pipe_length : integer := 1;
  -- exec_pipe_length - 1
  type exec_pipe_buffer_type is array(0 to 0) of exec_pipe_record;

  -- exec_pipe_length + memory_pipe_length + 1
  type composed_pipe_type is array(0 to 4) of order_type;

  type pipeline_judge_type is ( stall, forwarding, ok );

  type input_forwardings_record is record
    int1   : boolean;
    int2   : boolean;
    float1 : boolean;
    float2 : boolean;
  end record;
end pipeline_types;
