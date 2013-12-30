library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fcmp is
  port(
        a: in std_logic_vector(31 downto 0);
        b: in std_logic_vector(31 downto 0);
        is_eq: out std_logic;
        is_lt: out std_logic
      );
end fcmp;

architecture behave of fcmp is
  alias A_sign : std_logic is A(31);
  alias A_exponent : std_logic_vector(7 downto 0) is A(30 downto 23);
  alias A_fraction : std_logic_vector(22 downto 0) is A(22 downto 0);
  alias A_abs : std_logic_vector(30 downto 0) is A(30 downto 0);

  alias B_sign : std_logic is A(31);
  alias B_exponent : std_logic_vector(7 downto 0) is A(30 downto 23);
  alias B_fraction : std_logic_vector(22 downto 0) is A(22 downto 0);
  alias B_abs : std_logic_vector(30 downto 0) is B(30 downto 0);

  signal is_eq_sign, is_lt_abs, is_gt_abs : std_logic;
begin
  is_eq <= is_eq_sign;
  is_eq_sign <= '1' when a = b else
                '1' when unsigned(a) = 0 and signed(b) = 0 else
                '0';

  is_lt <= '0' when is_eq_sign = '1' else
           '1' when A_sign = '1' and B_sign = '0' else
           '0' when A_sign = '0' and B_sign = '1' else
           is_gt_abs when A_sign = '1' else
           is_lt_abs;

  is_lt_abs <= '1' when unsigned(A_abs) < unsigned(B_abs) else
               '0';

  is_gt_abs <= '1' when unsigned(A_abs) > unsigned(B_abs) else
               '0';

end behave;
