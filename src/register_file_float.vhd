library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.typedef_opcode.all;
use work.typedef_data.all;

entity register_file_float is
  port(
        a1 : in register_addr_type;
        a2 : in register_addr_type;
        a3 : in register_addr_type;

        rd1 : out word_data_type;
        rd2 : out word_data_type;
        wd3 : in  word_data_type;

        we3 : in std_logic;
        clk : in std_logic
      );
end register_file_float;

architecture behave of register_file_float is
  subtype register_unit is word_data_type;
  type register_array is array (0 to 31) of register_unit;

  constant ZERO: word_data_type := (others => '0');
  signal registers: register_array := (others => ZERO);
begin
  main: process (clk) begin
    if rising_edge(clk) then
      case we3 is
        when '1' =>
          -- write
          if a3 /= "00000" then
            registers(to_integer(unsigned(a3))) <= wd3;
          end if;
        when others =>
      end case;
    end if;
  end process;

  rd1 <= registers(to_integer(unsigned(a1)));
  rd2 <= registers(to_integer(unsigned(a2)));

end behave;

