library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_alu_ctl.all;

entity alu is
  port(
        a : in std_logic_vector(31 downto 0);
        b : in std_logic_vector(31 downto 0);
        alu_ctl: in alu_ctl_type;

        result : out std_logic_vector(31 downto 0);
        clk : in std_logic
      );
end alu;

architecture behave of alu is
  signal hilo: std_logic_vector(63 downto 0) := (others => '0');
  signal hilo_r: std_logic_vector(63 downto 0) := (others => '0');
  alias hi: std_logic_vector(31 downto 0) is hilo(63 downto 32);
  alias lo: std_logic_vector(31 downto 0) is hilo(31 downto 0);
  alias hi_r: std_logic_vector(31 downto 0) is hilo_r(63 downto 32);
  alias lo_r: std_logic_vector(31 downto 0) is hilo_r(31 downto 0);
  alias shamt: std_logic_vector(4 downto 0) is b(4 downto 0);
begin
  process(alu_ctl, a, b) begin
    case alu_ctl is
      when alu_ctl_lshift_r =>
        result <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(shamt))));
       when alu_ctl_lshift_l =>
        result <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(shamt))));
       when alu_ctl_ashift_r =>
        result <= std_logic_vector(shift_right(signed(a), to_integer(unsigned(shamt))));
       when alu_ctl_add =>
         result <= std_logic_vector(unsigned(a) + unsigned(b));
       when alu_ctl_sub =>
         result <= std_logic_vector(unsigned(a) - unsigned(b));
       when alu_ctl_mul =>
         hilo <= std_logic_vector(signed(a) * signed(b));
       when alu_ctl_mulu =>
         hilo <= std_logic_vector(unsigned(a) * unsigned(b));
       when alu_ctl_div =>
         lo <= std_logic_vector(signed(a) / signed(b));
         hi <= std_logic_vector(signed(a) mod signed(b));
       when alu_ctl_divu =>
         lo <= std_logic_vector(unsigned(a) / unsigned(b));
         hi <= std_logic_vector(unsigned(a) mod unsigned(b));
       when alu_ctl_and =>
         result <= a and b;
       when alu_ctl_or =>
         result <= a or b;
       when alu_ctl_xor =>
         result <= a xor b;
       when alu_ctl_nor =>
         result <= a nor b;
       when alu_ctl_slt =>
         if (signed(a) < signed(b)) then
           result(0) <= '1';
         else
           result(0) <= '0';
         end if;
         result(31 downto 1) <= (others => '0');
       when alu_ctl_sltu =>
         if (unsigned(a) < unsigned(b)) then
           result(0) <= '1';
         else
           result(0) <= '0';
         end if;
         result(31 downto 1) <= (others => '0');
       when alu_ctl_seq =>
         if (a = b) then
           result(0) <= '1';
         else
           result(0) <= '0';
         end if;
         result(31 downto 1) <= (others => '0');
       when alu_ctl_sne =>
         if not (a = b) then
           result(0) <= '1';
         else
           result(0) <= '0';
         end if;
         result(31 downto 1) <= (others => '0');
       when alu_ctl_cmpz_le =>
         if (signed(a) <= 0) then
           result(0) <= '1';
         else
           result(0) <= '0';
         end if;
         result(31 downto 1) <= (others => '0');
       when alu_ctl_cmpz_gt =>
         if (signed(a) > 0) then
           result(0) <= '1';
         else
           result(0) <= '0';
         end if;
         result(31 downto 1) <= (others => '0');
       when alu_ctl_cmpz_lt =>
         if (signed(a) < 0) then
           result(0) <= '1';
         else
           result(0) <= '0';
         end if;
         result(31 downto 1) <= (others => '0');
       when alu_ctl_cmpz_ge =>
         if (signed(a) >= 0) then
           result(0) <= '1';
         else
           result(0) <= '0';
         end if;
         result(31 downto 1) <= (others => '0');
       when alu_ctl_select_a =>
         result <= a;
       when alu_ctl_select_b =>
         result <= b;
       when alu_ctl_mfhi =>
         result <= hi_r;
       when alu_ctl_mflo =>
         result <= lo_r;
       when alu_ctl_mthi =>
         hi <= a;
       when alu_ctl_mtlo =>
         lo <= a;
       when alu_ctl_lui =>
         result <= b(15 downto 0) & x"0000";
      when others =>
      end case;
  end process;

update_hilo: process(clk) begin
    if rising_edge(clk) then
      hilo_r <= hilo;
    end if;
  end process;
end behave;


