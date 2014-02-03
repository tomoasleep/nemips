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

  function rs_of_order (
    order: in order_type
  ) return register_addr_type;

  function rt_of_order (
    order: in order_type
  ) return register_addr_type;

  function rd_of_order (
    order: in order_type
  ) return register_addr_type;
end order_utils;

package body order_utils is
  function opcode_of_order (
    order: in order_type
  ) return opcode_type is
    variable opcode : opcode_type;
  begin
    opcode := order(31 downto 26);
    return opcode;
  end opcode_of_order;

  function funct_of_order (
    order: in order_type
  ) return funct_type is
    variable funct : funct_type;
  begin
    funct := order(5 downto 0);
    return funct;
  end funct_of_order;

  function rs_of_order (
    order: in order_type
  ) return register_addr_type is
    variable rs : register_addr_type;
  begin
    rs := order(25 downto 21);
    return rs;
  end rs_of_order;

  function rt_of_order (
    order: in order_type
  ) return register_addr_type is
    variable rt : register_addr_type;
  begin
    rt := order(20 downto 16);
    return rt;
  end rt_of_order;

  function rd_of_order (
    order: in order_type
  ) return register_addr_type is
    variable rd : register_addr_type;
  begin
    rd := order(15 downto 11);
    return rd;
  end rd_of_order;
end order_utils;
