library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_mux.all;

entity state_go_selector is
  port(
        mem_read_ready: in std_logic;
        io_write_ready: in std_logic;
        io_read_ready: in std_logic;
        continue: in std_logic;
        go_src: in go_src_type;

        go: out std_logic
      );
end state_go_selector;

architecture behave of state_go_selector is
begin
  with go_src select
    go <= '1' when go_src_ok,
          mem_read_ready when go_src_mem_read,
          io_write_ready when go_src_io_write,
          io_read_ready when go_src_io_read,
          continue when go_src_continue,
         '0' when others;

end behave;

