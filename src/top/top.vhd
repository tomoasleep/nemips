library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity top is
  generic (wtime: std_logic_vector(15 downto 0) := x"1ADB");
  port(
        MCLK1 : in std_logic;
        RS_TX : out std_logic;
        RS_RX : in std_logic;

        ZCLKMA : out std_logic_vector(1 downto 0);
        XWA : out std_logic;
        XE1 : out std_logic;
        E2A: out std_logic;
        XE3 : out std_logic;
        XGA : out std_logic;
        XZCKE: out std_logic;
        ADVA: out std_logic;
        XLBO: out std_logic;
        ZZA : out std_logic;
        XFT: out std_logic;
        XZBE : out std_logic_vector(3 downto 0);

        ZD : inout std_logic_vector(31 downto 0);
        ZA : out std_logic_vector(19 downto 0)
      );
end top;

architecture behave of top is
  component nemips
    generic(io_wait: std_logic_vector(15 downto 0) := x"1ADB");
    port(
        rs232c_in : in std_logic;
        rs232c_out: out std_logic;

        sram_inout : inout std_logic_vector(31 downto 0);
        sram_addr : out std_logic_vector(19 downto 0);
        sram_write_enable : out std_logic;

        reset : in std_logic;
        is_break: out std_logic;
        continue: in std_logic;
        clk : in std_logic
        );
  end component;
  signal clk, iclk: std_logic;
  signal reset, is_break, continue: std_logic;
  signal sram_write_enable: std_logic;
begin 
  ib: IBUFG port map(
    i => MCLK1,
    o => iclk);
  bg: BUFG port map(
    i => iclk,
    o => clk);

  nemips generic map(io_wait => x"1ADB")
    port map(
      rs232c_in => RS_RX,
      rs232c_out => RS_TX,

      sram_inout => ZD,
      sram_addr => ZA,
      sram_write_enable => sram_write_enable,

      reset => reset,
      is_break => is_break,
      continue => continue,
      clk => clk
          );

  XE1 <= '0';
  E2A <= '1';
  XE3 <= '0';
  XGA <= '0';
  XZCKE <= '0';
  ADVA <= '0';
  XLBO <= '1';
  ZZA <= '0';
  XFT <= '1';
  XZBE <= "0000";
  ZCLKMA(1) <= clk;
  ZCLKMA(0) <= clk;
  XWA <= not sram_write_enable;

  process begin
    reset <= '1';
    wait for 50 ns;
    reset <= '0';
    wait;
  end process;
end behave;

