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

  function funct_of_order (
    order: in order_type
  ) return funct_type;
end order_utils;

package body order_utils is
  function opcode_of_order (
    order: in order_type
  ) return opcode_type is
    variable opcode : opcode_type;
  begin
    opcode := order(31 downto 26);
  end opcode_of_order;

  function funct_of_order (
    order: in order_type
  ) return funct_type is
    variable funct : funct_type;
  begin
    funct := order(5 downto 0);
  end funct_of_order;
end order_utils;
