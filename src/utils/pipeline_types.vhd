library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_pipeline_state.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

package pipeline_types is
  type memory_pipe_record is record
    order : order_type;
    state : memory_state_type;
  end record;

  constant init_memory_record : memory_pipe_record := (
    order => (others => '0'),
    state => (others => '0')
  );
  type memory_pipe_buffer_type is array(0 to 1) of memory_pipe_record;
end pipeline_types;
