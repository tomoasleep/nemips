library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_alu_ctl.all;
use work.const_opcode.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

entity trap_handler is
  port(
        is_io_read_inst_excepiton : in boolean;
        is_io_write_inst_excepiton : in boolean;
        is_device_trap       : in boolean;

        exec_pc              : in pc_data_type;
        memory_pc            : in pc_data_type;
        wb_pc                : in pc_data_type;

        is_exception         : out boolean;
        trap_jump_pc         : out pc_data_type;
        save_pc              : out pc_data_type;
        
        flash_decode         : out boolean;
        flash_to_exec           : out boolean;
        flash_to_memory         : out boolean;
        flash_wb             : out boolean
      );
end trap_handler;

architecture behave of trap_handler is
  constant device_catch_pc : pc_data_type := std_logic_vector(to_unsigned(10, pc_data_type'length));
  constant io_read_catch_pc : pc_data_type := std_logic_vector(to_unsigned(20, pc_data_type'length));
  constant io_write_catch_pc : pc_data_type := std_logic_vector(to_unsigned(25, pc_data_type'length));
  constant return_register : register_addr_type := std_logic_vector(to_unsigned(26, register_addr_type'length));
  constant dummy_order : order_type := i_op_addi & "00000" & return_register & x"0000";

  type excepiton_reason_type is (none, io_read, io_write, device);
  signal exception_reason : excepiton_reason_type;

  signal exec_pc_increment : pc_data_type;
  signal memory_pc_increment : pc_data_type;
  signal wb_pc_increment : pc_data_type;
begin
  is_exception <= is_io_read_inst_excepiton or is_io_write_inst_excepiton or is_device_trap;

  exception_reason <= io_read when is_io_read_inst_excepiton else
                      io_write when is_io_write_inst_excepiton else
                      device when is_device_trap else
                      none;

  with exception_reason select
    save_pc <= memory_pc when io_read | io_write,
               memory_pc_increment when others;

  with exception_reason select
    trap_jump_pc <= io_read_catch_pc when io_read,
                    io_write_catch_pc when io_write,
                    device_catch_pc when others;

  with exception_reason select
    flash_decode <= true when io_read | io_write,
                    false when others;

  with exception_reason select
    flash_to_exec <= true when io_read | io_write | device,
                     false when others;

  with exception_reason select
    flash_to_memory <= true when io_read | io_write | device,
                       false when others;

  with exception_reason select
    flash_wb <= true when io_read | io_write,
                false when others;

end behave;
