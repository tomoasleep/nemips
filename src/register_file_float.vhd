library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file_float is
  port(
        a1 : in std_logic_vector(4 downto 0);
        a2 : in std_logic_vector(4 downto 0);
        a3 : in std_logic_vector(4 downto 0);

        rd1 : out std_logic_vector(31 downto 0);
        rd2 : out std_logic_vector(31 downto 0);
        wd3 : in std_logic_vector(31 downto 0);

        we3 : in std_logic;
        clk : in std_logic
      );
end register_file_float;

architecture behave of register_file_float is
  subtype register_unit is std_logic_vector(31 downto 0);
  type register_array is array (0 to 31) of register_unit;

  constant ZERO: std_logic_vector(31 downto 0) := x"00000000";
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

