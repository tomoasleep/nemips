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
use work.typedef_data.all;

entity forwarding_controller is
  port(
        decode_data1:             in  work_data_type;
        decode_data2:             in  work_data_type;

        pipe_alu_result:          in  word_data_type;
        pipe_mem_result:          in  word_data_type;

        calc_input1:               out word_data_type;
        calc_input2:               out word_data_type;

      );
end hazard_controller;

architecture behave of forwarding_controller is
begin
  calc_input1 <= decode_data1;
  calc_input2 <= decode_data2;
end bahave;
