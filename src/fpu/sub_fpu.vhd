library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_fpu_ctl.all;

entity sub_fpu is
  port(
        a: in std_logic_vector(31 downto 0);
        b: in std_logic_vector(31 downto 0);
        fpu_ctl: in fpu_ctl_type;

        result: out std_logic_vector(31 downto 0);
        done: out std_logic;
        clk : in std_logic
      );
end sub_fpu;


architecture behave of sub_fpu is
  component fcmp
    port (
          a: in std_logic_vector(31 downto 0);
          b: in std_logic_vector(31 downto 0);
          is_eq: out std_logic;
          is_lt: out std_logic
         );
  end component;

  alias A_sign : std_logic is A(31);
  alias A_exponent : std_logic_vector(7 downto 0) is A(30 downto 23);
  alias A_fraction : std_logic_vector(22 downto 0) is A(22 downto 0);

  signal calc_result : std_logic_vector(31 downto 0);

  alias R_sign : std_logic is calc_result(31);
  alias R_exponent : std_logic_vector(7 downto 0) is calc_result(30 downto 23);
  alias R_fraction : std_logic_vector(22 downto 0) is calc_result(22 downto 0);

  signal bool_result : std_logic_vector(31 downto 0);

  signal lt_result : std_logic;
  signal eq_result : std_logic;

  signal result_fpu_ctl: fpu_ctl_type;
begin
  comp_fcmp: fcmp port map(
            a => a,
            b => b,
            is_eq => eq_result,
            is_lt => lt_result);

  with result_fpu_ctl select
    result <= a when fpu_ctl_none,
              calc_result when fpu_ctl_fabs | fpu_ctl_fneg,
              bool_result when fpu_ctl_fclt | fpu_ctl_fcseq | fpu_ctl_fcle,
              a when others;

  with result_fpu_ctl select
    R_sign <= not A_sign when fpu_ctl_fneg,
              '0' when fpu_ctl_fabs,
              A_sign when others;

  with result_fpu_ctl select
    bool_result(0) <= lt_result when fpu_ctl_fclt,
                      eq_result when fpu_ctl_fcseq,
                      lt_result or eq_result when fpu_ctl_fcle,
                      '0' when others;

  bool_result(31 downto 1) <= (others => '0');
  R_exponent <= A_exponent;
  R_fraction <= A_fraction;

  done <= '0' when result_fpu_ctl = fpu_ctl_none else '1';

  process(clk) begin
    if rising_edge(clk) then
      result_fpu_ctl <= fpu_ctl;
      end if;
  end process;
end behave;

