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

entity hazard_controller is
  port(
        to_ex_flush:         out std_logic;
        to_mem_flush:        out std_logic;
        to_write_back_flush: out std_logic;

        pc_update:            out std_logic;
        to_decode_update:     out std_logic;
        to_ex_update:         out std_logic;
        to_mem_update:        out std_logic;
        to_write_back_update: out std_logic;
      );
end hazard_controller;

architecture behave of hazard_controller is
begin
  pc_update             <= '1';
  to_decode_update      <= '1';
  to_ex_update          <= '1';
  to_mem_update         <= '1';
  to_write_back_update  <= '1';
end bahave;
