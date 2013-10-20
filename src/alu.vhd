library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
  signal hilo: std_logic_vector(63 downto 0) := (others => 0);
  signal hilo_r: std_logic_vector(63 downto 0) := (others => 0);
  alias hi: std_logic_vector(31 downto 0) is hilo(63 downto 32);
  alias lo: std_logic_vector(31 downto 0) is hilo(31 downto 0);
  alias hi_r: std_logic_vector(31 downto 0) is hilo_r(63 downto 32);
  alias lo_r: std_logic_vector(31 downto 0) is hilo_r(31 downto 0);
  alias shamt: std_logic_vector(4 downto 0) is b(4 downto 0);
begin
  process(alu_ctl) begin
    case alu_ctl is
      when alu_lshift_r =>
        result <= SHL(a, shamt);
      when alu_lshift_l =>
        result <= SHR(a, shamt);
      when alu_ashift_r =>
        result <= a srl shamt;
      when alu_add =>
        result <= a + b;
      when alu_sub =>
        result <= a - b;
      when alu_mul =>
        hilo <= a * b;
      when alu_mulu =>
        hilo <= a * b;
      when alu_div =>
        lo <= a / b;
        hi <= a mod b;
      when alu_divu =>
        lo <= a / b;
        hi <= a mod b;
      when alu_and =>
        result <= a and b;
      when alu_or =>
        result <= a or b;
      when alu_xor =>
        result <= a xor b;
      when alu_nor =>
        result <= a nor b;
      when alu_slt =>
        if (a < b) then
          result(0) <= '1';
        else
          result(0) <= '0';
        end if;
        result(31 downto 1) <= (others => '0');
      when alu_sltu =>
        if (a < b) then
          result(0) <= '1';
        else
          result(0) <= '0';
        end if;
        result(31 downto 1) <= (others => '0');
      when alu_seq =>
        if (a = b) then
          result(0) <= '1';
        else
          result(0) <= '0';
        end if;
        result(31 downto 1) <= (others => '0');
      when alu_sne =>
        if not (a = b) then
          result(0) <= '1';
        else
          result(0) <= '0';
        end if;
        result(31 downto 1) <= (others => '0');
      when alu_cmpz_legt =>
        if (a < 0) then
          result(0) <= '1' xor b(0);
        else
          result(0) <= '0' xor b(0);
        end if;
        result(31 downto 1) <= (others => '0');
      when alu_cmpz_ltge =>
        if (a <= 0) then
          result(0) <= '1' xor b(0);
        else
          result(0) <= '0' xor b(0);
        end if;
        result(31 downto 1) <= (others => '0');
      when alu_select_a =>
        result <= a;
      when alu_select_b =>
        result <= b;
      when alu_mfhi =>
        result <= hi_r;
      when alu_mflo =>
        result <= lo_r;
      when alu_mthi =>
        hi <= a;
      when alu_mtlo =>
        lo <= a;
      when alu_lui =>
        result <= SHL(b, 16);
      when others =>
      end case;
  end process;

update_hilo: process(clk) begin
    if rising_edge(clk) then
      hilo_r <= hilo;
    end if;
  end process;
end behave;


