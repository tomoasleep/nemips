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

use work.typedef_opcode.all;

entity pipeline_controller is
  port(
        decode_rs : in register_addr_type;
        decode_rt : in register_addr_type;
        decode_rd : in register_addr_type;
        decode_register_is_int: in std_logic;
        decode_state: in decode_state_type;

        ex_rs : in register_addr_type;
        ex_rt : in register_addr_type;
        ex_rd : in register_addr_type;
        ex_register_is_int: in std_logic;
        ex_state: in decode_state_type;

        mem_rs : in register_addr_type;
        mem_rt : in register_addr_type;
        mem_rd : in register_addr_type;
        mem_register_is_int: in std_logic;
        mem_state: in decode_state_type;

        write_back_rs : in register_addr_type;
        write_back_rt : in register_addr_type;
        write_back_rd : in register_addr_type;
        write_back_register_is_int: in std_logic;
        write_back_state: in decode_state_type;
      );
end pipeline_controller;

architecture behave of pipeline_controller is
begin
end bahave;
