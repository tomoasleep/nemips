library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_mux.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

entity exec_tag_checker is
  port(
        tagdata: in request_tag_type;
        go_src: in ex_go_src_type;

        io_tag_data: in request_tag_type;
        sram_tag_data: in request_tag_type;
        program_tag_data: in request_tag_type;
        fpu_tag_data: in request_tag_type;
        sub_fpu_tag_data: in request_tag_type;

        go: out std_logic
      );
end exec_tag_checker;

architecture behave of exec_tag_checker is
  signal io_go, sram_go, program_go, fpu_go, sub_fpu_go: std_logic;
begin
  with go_src select
    go <= io_go       when ex_go_src_io,
          sram_go     when ex_go_src_sram,
          program_go  when ex_go_src_program,
          fpu_go      when ex_go_src_fpu,
          sub_fpu_go  when ex_go_src_sub_fpu,
          '1'         when ex_go_src_ok,
          '0'         when others;

  io_go <= '1' when tagdata = io_tag_data else '0';
  sram_go <= '1' when tagdata = sram_tag_data else '0';
  program_go <= '1' when tagdata = program_tag_data else '0';
  fpu_go <= '1' when tagdata = fpu_tag_data else '0';
  sub_fpu_go <= '1' when tagdata = sub_fpu_tag_data else '0';

end behave;

