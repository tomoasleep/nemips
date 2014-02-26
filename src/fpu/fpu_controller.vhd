library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_fpu_ctl.all;

entity fpu_controller is
  port(
        a: in std_logic_vector(31 downto 0);
        b: in std_logic_vector(31 downto 0);
        fpu_ctl: in fpu_ctl_type;

        result: out std_logic_vector(31 downto 0);
        clk : in std_logic
      );
end fpu_controller;

architecture behave of fpu_controller is
  component fadd
    port (
        a: in std_logic_vector(31 downto 0);
        b: in std_logic_vector(31 downto 0);
        result: out std_logic_vector(31 downto 0);
        clk : in std_logic);
  end component;

  component fmul
    port (
        a: in std_logic_vector(31 downto 0);
        b: in std_logic_vector(31 downto 0);
        R: out std_logic_vector(31 downto 0);
        clk : in std_logic);
  end component;

  component finv
    port (
        f1: in std_logic_vector(31 downto 0);
        ans: out std_logic_vector(31 downto 0);
        clk : in std_logic);
  end component;

  component fsqrt
    port (
        f1: in std_logic_vector(31 downto 0);
        ans: out std_logic_vector(31 downto 0);
        clk : in std_logic);
  end component;

  signal fadd_b: std_logic_vector(31 downto 0);

  signal fadd_result: std_logic_vector(31 downto 0);
  signal fmul_result: std_logic_vector(31 downto 0);
  signal finv_result: std_logic_vector(31 downto 0);
  signal fsqrt_result: std_logic_vector(31 downto 0);

  type fpu_ctl_array is array(0 to 0) of fpu_ctl_type;
  signal fpu_ctl_pipeline : fpu_ctl_array := (others => fpu_ctl_none);

  signal result_fpu_ctl : fpu_ctl_type;
begin
  fpu_fadd: fadd port map(
        a => a,
        b => fadd_b,
        result => fadd_result,
        clk => clk);

  fpu_fmul: fmul port map(
        a => a,
        b => b,
        R => fmul_result,
        clk => clk);

  fpu_finv: finv port map(
        f1 => a,
        ans => finv_result,
        clk => clk);

  fpu_fsqrt: fsqrt port map(
        f1 => a,
        ans => fsqrt_result,
        clk => clk);

  pipeline: process(clk) begin
    if rising_edge(clk) then
      fpu_ctl_pipeline(0) <= fpu_ctl;
      result_fpu_ctl <= fpu_ctl_pipeline(0);
    end if;
  end process;

  with fpu_ctl select
    fadd_b <= (not b(31)) & b(30 downto 0) when fpu_ctl_fsub,
              b when others;

  with result_fpu_ctl select
    result <= fadd_result when fpu_ctl_fadd | fpu_ctl_fsub,
              fmul_result when fpu_ctl_fmul,
              finv_result when fpu_ctl_finv,
              fsqrt_result when fpu_ctl_fsqrt,
              a when others;

end behave;

