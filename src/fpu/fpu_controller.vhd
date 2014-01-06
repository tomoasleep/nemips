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
        done: out std_logic;
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

  type fpu_ctl_array is array(0 to 3) of fpu_ctl_type;
  signal fpu_ctl_pipeline : fpu_ctl_array := (others => fpu_ctl_none);

  signal fpu_ctl_insert_idx : std_logic_vector(1 downto 0) := "00";
  signal fpu_ctl_output_idx : std_logic_vector(1 downto 0) := "10";

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
      if result_fpu_ctl /= fpu_ctl_none then
        fpu_ctl_pipeline(to_integer(unsigned(fpu_ctl_insert_idx))) <= fpu_ctl_none;
      else
        fpu_ctl_pipeline(to_integer(unsigned(fpu_ctl_insert_idx))) <= fpu_ctl;
      end if;
      result_fpu_ctl <= fpu_ctl_pipeline(to_integer(unsigned(fpu_ctl_output_idx)));

      fpu_ctl_insert_idx <= std_logic_vector(unsigned(fpu_ctl_insert_idx) + 1);
      fpu_ctl_output_idx <= std_logic_vector(unsigned(fpu_ctl_insert_idx) + 2);
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

  with result_fpu_ctl select
  done <= '1' when fpu_ctl_fadd | fpu_ctl_fsub
                 | fpu_ctl_fmul | fpu_ctl_finv
                 | fpu_ctl_fsqrt,
          '0' when others;
end behave;

