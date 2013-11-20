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
  constant bZero : std_logic_vector(30 downto 0) := (others => '0');
  constant Zero : std_logic_vector(31 downto 0) := (others => '0');

  signal hilo: std_logic_vector(63 downto 0) := (others => '0');
  signal hilo_r: std_logic_vector(63 downto 0) := (others => '0');

  signal result_bool : std_logic;
  signal is_slt, is_sltu, is_seq, is_sne : std_logic := '0';
  signal is_lez, is_gtz, is_ltz, is_gez : std_logic := '0';

  alias hi: std_logic_vector(31 downto 0) is hilo(63 downto 32);
  alias lo: std_logic_vector(31 downto 0) is hilo(31 downto 0);
  alias hi_r: std_logic_vector(31 downto 0) is hilo_r(63 downto 32);
  alias lo_r: std_logic_vector(31 downto 0) is hilo_r(31 downto 0);
  alias shamt: std_logic_vector(4 downto 0) is b(4 downto 0);
begin
  with alu_ctl select
    result <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(shamt)))) when alu_ctl_lshift_r,
              std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(shamt)))) when alu_ctl_lshift_l,
              std_logic_vector(shift_right(signed(a), to_integer(unsigned(shamt)))) when alu_ctl_ashift_r,
              std_logic_vector(unsigned(a) + unsigned(b)) when alu_ctl_add,
              std_logic_vector(unsigned(a) - unsigned(b)) when alu_ctl_sub,
              a and b when alu_ctl_and,
              a or b when alu_ctl_or,
              a xor b when alu_ctl_xor,
              a nor b when alu_ctl_nor,
              a when alu_ctl_select_a,
              b when alu_ctl_select_b,
              hi_r when alu_ctl_mfhi,
              lo_r when alu_ctl_mflo,
              b(15 downto 0) & x"0000" when alu_ctl_lui,
              bzero & result_bool when alu_ctl_slt | alu_ctl_sltu
              | alu_ctl_seq | alu_ctl_sne
              | alu_ctl_cmpz_le | alu_ctl_cmpz_lt
              | alu_ctl_cmpz_ge | alu_ctl_cmpz_gt,
              zero when others;

  with alu_ctl select
    result_bool <= is_slt when alu_ctl_slt,
                   is_sltu when alu_ctl_sltu,
                   is_seq when alu_ctl_seq,
                   is_sne when alu_ctl_sne,
                   is_lez when alu_ctl_cmpz_le,
                   is_gtz when alu_ctl_cmpz_gt,
                   is_ltz when alu_ctl_cmpz_lt,
                   is_gez when alu_ctl_cmpz_ge,
                   '0' when others;

  is_slt <= '1' when (signed(a) < signed(b)) else '0';
  is_sltu <= '1' when (unsigned(a) < unsigned(b)) else '0';
  is_seq <= '1' when (a = b) else '0';
  is_sne <= '1' when not (a = b) else '0';
  is_lez <= '1' when (signed(a) <= 0) else '0';
  is_gtz <= '1' when (signed(a) > 0) else '0';
  is_ltz <= '1' when (signed(a) < 0) else '0';
  is_gez <= '1' when (signed(a) >= 0) else '0';

update_hilo: process(clk) begin
  if rising_edge(clk) then
    case alu_ctl is
      when alu_ctl_mthi =>
        hi_r <= a;
      when alu_ctl_mtlo =>
        lo_r <= a;
      when alu_ctl_mul =>
        hilo <= std_logic_vector(signed(a) * signed(b));
      when alu_ctl_mulu =>
        hilo <= std_logic_vector(unsigned(a) * unsigned(b));
      when others =>
    end case;
  end if;
end process;
end behave;

