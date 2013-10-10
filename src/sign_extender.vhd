library ieee;
use ieee.std_logic_1164.all;

entity sign_extender is
  port(
        imm    : in std_logic_vector(15 downto 0);
        signe  : in std_logic;

        ex_imm : out std_logic_vector(31 downto 0)
      );
end sign_extender;

architecture behave of sign_extender is
begin
  main: process(imm, signe) begin
    case signe is
      when '1' =>
        ex_imm(31 downto 16) <= (others => imm(15));
        ex_imm(15 downto 0) <= imm;
      when '0' =>
        ex_imm(31 downto 16) <= (others => '0');
        ex_imm(15 downto 0) <= imm;
      when others =>
    end case;
  end process;
end behave;

