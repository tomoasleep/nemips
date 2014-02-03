library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.typedef_opcode.all;
use work.typedef_data.all;

package order_utils is
  function opcode_of_order (
    order: in order_type
  ) return opcode_type;
end order_utils;

package body order_utils is
  function opcode_of_order (
    order: in order_type
  ) return opcode_type is
    variable opcode : opcode_type;
  begin
    opcode := order(31 downto 26);
  end opcode_of_order;
end order_utils;
