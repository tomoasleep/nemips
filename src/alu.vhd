library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity alu is
  port(
        a : in std_logic_vector(31 downto 0);
        b : in std_logic_vector(31 downto 0);
        op : in std_logic_vector(5 downto 0);

        result : out std_logic_vector(31 downto 0)
      );
end alu;

architecture behave of alu is
  constant ADDU : std_logic_vector(5 downto 0) := "1000001";
begin
  case op is
    when ""

end behave;


