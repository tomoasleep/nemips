library ieee;
use ieee.std_logic_1164.all;

-- TEST
-- imm   h|signe |ex_imm h
-- ffff |0     |0000ffff
-- ffff |1     |ffffffff
-- 7fff |1     |00007fff
-- /TEST

entity sign_extender is
  port(
        imm    : in std_logic_vector(15 downto 0);

        ex_imm : out std_logic_vector(31 downto 0)
      );
end sign_extender;

architecture behave of sign_extender is
begin
  ex_imm(31 downto 16) <= (others => imm(15));
  ex_imm(15 downto 0) <= imm;
end behave;

