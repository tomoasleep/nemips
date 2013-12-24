library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sram_controller is
  port(
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
        ZA : out std_logic_vector(19 downto 0);

        WR: in std_logic;
        clk : in std_logic;
        address : in std_logic_vector(19 downto 0);
        input: in std_logic_vector(31 downto 0);
        output: out std_logic_vector(31 downto 0);
        valid : out std_logic
      );
end sram_controller;

architecture sram_ctrl of sram_controller is
  subtype sram_data is std_logic_vector(31 downto 0);
  type data_array is array (0 to 3) of sram_data;
  subtype sram_add is std_logic_vector(19 downto 0);
  type addr_array is array (0 to 3) of sram_add;

  signal ram_buf: data_array;
  signal state: std_logic_vector(3 downto 0) := "0000";
  signal top_address: std_logic_vector(19 downto 0) := x"00000";
  signal index: std_logic_vector(1 downto 0) := "00";

  signal addr_buf: addr_array;

begin
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
  ZCLKMA <= clk & clk;
  ZA <= address;

  ZD <= ram_buf(conv_integer(index)) when state(0) = '0' else (others => 'Z');

  state_machine: process(clk)
  begin
    if rising_edge(clk) then
      addr_buf(conv_integer(index + 2)) <= address; 
      index <= index + 1;

      if WR = '0' then  -- write mode;
        XWA <= '0';
        state <= '0' & state(3 downto 1);

        ram_buf(conv_integer(index + 2)) <= input; 
      else -- read mode;
        XWA <= '1';
        state <= '1' & state(3 downto 1);
      end if;

      if state(0) = '0' then
        output <= ZD;
        if ZD(19 downto 0) = addr_buf(conv_integer(index)) then 
          valid <= '1';
        else
          valid <= '0';
        end if;
      end if;
    end if;
  end process;
end sram_ctrl;


