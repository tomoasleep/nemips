library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_pipeline_state.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

package pipeline_types is
  type register_info_type is record
    int_read1 : register_addr_type;
    int_read2 : register_addr_type;
    int_write : register_addr_type;
    float_read1 : register_addr_type;
    float_read2 : register_addr_type;
    float_write : register_addr_type;
  end record;
  subtype pipeline_length_type is std_logic_vector(4 downto 0);

  constant jal_register : register_addr_type := "11111";

  type memory_pipe_record is record
    order : order_type;
    state : memory_state_type;
  end record;

  constant init_memory_record : memory_pipe_record := (
    order => (others => '0'),
    state => (others => '0')
  );
  constant memory_pipe_length : integer := 4;
  -- memory_pipe_length - 1
  type memory_pipe_buffer_type is array(0 to 3) of memory_pipe_record;
  type memory_orders_type is array(0 to 4) of order_type;

  type exec_pipe_record is record
    order : order_type;
    state : exec_state_type;
  end record;

  constant init_exec_record : exec_pipe_record := (
    order => (others => '0'),
    state => (others => '0')
  );
  constant exec_pipe_length : integer := 2;
  -- exec_pipe_length - 1
  type exec_pipe_buffer_type is array(0 to 1) of exec_pipe_record;
  type exec_orders_type is array(0 to 2) of order_type;


  -- exec_pipe_length + memory_pipe_length + 2
  type composed_pipe_type is array(0 to 8) of order_type;

  type pipeline_judge_type is ( stall, forwarding_mem, forwarding_wb, ok );

  type input_forwardings_record is record
    int1   : boolean;
    int2   : boolean;
    float1 : boolean;
    float2 : boolean;
  end record;

  constant trap_pc_addr : integer := 28;
end pipeline_types;
