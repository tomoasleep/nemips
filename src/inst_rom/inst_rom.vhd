library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity inst_rom is
  port(
        addr: in std_logic_vector(29 downto 0);
        data: out std_logic_vector(31 downto 0)
      );
end inst_rom;

architecture behave of inst_rom is
  constant data_length: integer := 128;

  subtype data_unit is std_logic_vector(31 downto 0);
  type data_array is array(0 to data_length - 1) of data_unit;

  subtype index is std_logic_vector(6 downto 0);
  constant ZERO: data_unit := x"00000000";

  signal rom: data_array := (
  "00100000000000010101010110101010",
  "01111000001000000000000000001011",
  "00001000000000000000000000000010",
  others => ZERO);
begin
  data <= rom(to_integer(unsigned(addr(6 downto 0))));
end behave;
