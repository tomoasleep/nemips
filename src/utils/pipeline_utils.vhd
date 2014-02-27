library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.typedef_opcode.all;
use work.typedef_data.all;
use work.const_pipeline_state.all;

use work.decode_order_functions.all;
use work.pipeline_types.all;
use work.order_utils.all;

package pipeline_utils is
  function register_info_of_order (
    order: in order_type
  ) return register_info_type;

  function compose_pipelines(
    exec_pipe : in exec_orders_type;
    memory_pipe : in memory_orders_type;
    write_back_order: in order_type
  ) return composed_pipe_type;

  function check_register_dependency_each(
    input : in register_addr_type;
    is_int : in boolean;
    pipe : composed_pipe_type
  ) return pipeline_judge_type;

  function pipeline_exmem_length_count(
    order : in order_type
  ) return pipeline_length_type;

  function pipeline_ex_length_count(
    order : in order_type
  ) return pipeline_length_type;
end pipeline_utils;

package body pipeline_utils is
  function register_info_of_order (
    order: in order_type
  ) return register_info_type is
    variable opcode : opcode_type;
    variable funct : funct_type;

    variable exec_state : exec_state_type;
    variable memory_state : memory_state_type;
    variable write_back_state : write_back_state_type;

    variable int_read1   : register_addr_type := (others => '0');
    variable int_read2   : register_addr_type := (others => '0');
    variable int_write   : register_addr_type := (others => '0');
    variable float_read1 : register_addr_type := (others => '0');
    variable float_read2 : register_addr_type := (others => '0');
    variable float_write : register_addr_type := (others => '0');

    variable register_info : register_info_type;
  begin
    opcode := opcode_of_order(order);
    funct := funct_of_order(order);

    exec_state := decode_exec_state(opcode, funct);
    memory_state := decode_memory_state(opcode, funct);
    write_back_state := decode_write_back_state(opcode, funct);

    case exec_state is
      when exec_state_alu | exec_state_branch =>
        int_read1 := rs_of_order(order);
        int_read2 := rt_of_order(order);
      when exec_state_alu_shift | exec_state_alu_imm |
           exec_state_alu_zimm | exec_state_jmpr =>
        int_read1 := rs_of_order(order);
      when exec_state_fpu | exec_state_sub_fpu =>
        float_read1 := rs_of_order(order);
        float_read2 := rt_of_order(order);
      when others =>
    end case;

    case memory_state is
      when memory_state_io_write_w | memory_state_io_write_b =>
        int_read1 := rs_of_order(order);
      when memory_state_sram_write =>
        int_read1 := rs_of_order(order);
        int_read2 := rt_of_order(order);
      when memory_state_program_write =>
        int_read1 := rs_of_order(order);
        int_read2 := rt_of_order(order);
      when memory_state_sram_read =>
        int_read1 := rs_of_order(order);
      when others =>
    end case;

    case write_back_state is
      when write_back_state_wb_rt =>
        int_write := rt_of_order(order);
      when write_back_state_wb_rd =>
        int_write := rd_of_order(order);
      when write_back_state_wb_ft =>
        float_write := rt_of_order(order);
      when write_back_state_wb_fd =>
        float_write := rd_of_order(order);
      when write_back_state_jal_wb =>
        int_write := jal_register;
      when others =>
    end case;

    register_info := (
      int_read1 => int_read1,
      int_read2 => int_read2,
      int_write => int_write,
      float_read1 => float_read1,
      float_read2 => float_read2,
      float_write => float_write
    );
    return register_info;
  end register_info_of_order;

  function compose_pipelines(
    exec_pipe : in exec_orders_type;
    memory_pipe : in memory_orders_type;
    write_back_order: in order_type
  ) return composed_pipe_type is
    variable composed_pipe : composed_pipe_type;
    variable index : integer := 0;
  begin
    for i in 0 to exec_pipe'length - 1 loop
      composed_pipe(i + index) := exec_pipe(i);
    end loop;

    index := exec_pipe'length;

    for i in 0 to memory_pipe'length - 1 loop
      composed_pipe(i + index) := memory_pipe(i);
    end loop;

    composed_pipe(composed_pipe'length - 1) := write_back_order;
    return composed_pipe;
  end function;

  function check_register_dependency(
    input : in register_addr_type;
    is_int : in boolean;
    order : in order_type
  ) return boolean is
    variable register_info : register_info_type;
    constant zero : register_addr_type := (others => '0');
  begin
    register_info := register_info_of_order(order);

    if input = zero then
      return true;
    elsif is_int then
      if register_info.int_write = input then
        return false;
      else
        return true;
      end if;
    else
      if register_info.float_write = input then
        return false;
      else
        return true;
      end if;
    end if;
  end function;

  function check_register_dependency_each(
    input : in register_addr_type;
    is_int : in boolean;
    pipe : composed_pipe_type
  ) return pipeline_judge_type is
  begin
    for i in 0 to composed_pipe_type'length - 3 loop
      if not check_register_dependency(input, is_int, pipe(i)) then
        return stall;
      end if;
    end loop;

    if not check_register_dependency(input, is_int, pipe(composed_pipe_type'length - 2)) then
      return forwarding_mem;
    elsif not check_register_dependency(input, is_int, pipe(composed_pipe_type'length - 1)) then
      return forwarding_wb;
    else
      return ok;
    end if;
  end function;

  function pipeline_exmem_length_count(
    order : in order_type
  ) return pipeline_length_type is
    variable stage_length: pipeline_length_type := (others => '0');

    variable exec_state : exec_state_type;
    variable memory_state : memory_state_type;
  begin
    stage_length := pipeline_ex_length_count(order);

    memory_state := decode_memory_state(opcode_of_order(order), funct_of_order(order));

    case memory_state is
      when memory_state_sram_read =>
        stage_length := std_logic_vector(unsigned(stage_length) + 5);
      when others =>
        stage_length := std_logic_vector(unsigned(stage_length) + 1);
    end case;

    return std_logic_vector(stage_length);
  end function;

  function pipeline_ex_length_count(
    order : in order_type
  ) return pipeline_length_type is
    variable stage_length: pipeline_length_type := (others => '0');

    variable exec_state : exec_state_type;
  begin
    exec_state := decode_exec_state(opcode_of_order(order), funct_of_order(order));

    case exec_state is
      when exec_state_fpu =>
        stage_length := std_logic_vector(unsigned(stage_length) + 3);
      when others =>
        stage_length := std_logic_vector(unsigned(stage_length) + 1);
    end case;

    return std_logic_vector(stage_length);
  end function;
end pipeline_utils;

