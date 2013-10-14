library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- TEST
-- a1   |a2   |a3   |rd1 |rd2  |wd3 |we3 |clk
-- 0000 |0000 |0000 |0   |0    |1   |1   |1
--      |     |     |    |     |    |0   |0
--      |     |     |    |     |32  |0   |1
--      |     |     |    |     |    |1   |0
-- 0000 |0000 |0000 |32  |32   |1   |1   |1
--      |     |     |    |     |    |0   |0
-- /TEST

entity register_file is
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
end register_file;

architecture behave of register_file is
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
            registers(conv_integer(a3)) <= wd3;
          end if;
        when others =>
      end case;
      
    end if;
  end process;

  rd1 <= registers(conv_integer(a1));
  rd2 <= registers(conv_integer(a2));

end behave;

