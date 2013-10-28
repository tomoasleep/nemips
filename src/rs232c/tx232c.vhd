library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx232c is
  generic (wtime: std_logic_vector(15 downto 0) := x"1ADB");
  Port ( clk  : in  STD_LOGIC;
         data : in  STD_LOGIC_VECTOR (7 downto 0);
         go   : in  STD_LOGIC;
         ready: out STD_LOGIC;
         tx   : out STD_LOGIC);
end tx232c;

architecture behave of tx232c is
  constant ZERO : std_logic_vector(15 downto 0) := (others => '0');
  constant state_standby : std_logic_vector(3 downto 0) := x"0";
  constant state_send_start : std_logic_vector(3 downto 0) := x"a";

  signal countdown: std_logic_vector(15 downto 0) := (others=>'0');
  signal sendbuf: std_logic_vector(8 downto 0) := (others => '1');
  signal state: std_logic_vector(3 downto 0) := "0000";
begin
  statemachine: process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when state_standby =>
          if go = '1' then
            sendbuf <= data & "0";
            countdown <= wtime;
            state <= state_send_start;
          end if;
        when others=>
          if countdown = ZERO then
            sendbuf <= "1" & sendbuf(8 downto 1);
            countdown <= wtime;
            state <= std_logic_vector(unsigned(state) - 1);
          else
            countdown <= std_logic_vector(unsigned(countdown) - 1);
          end if;
      end case;
    end if;
  end process;
  tx <= sendbuf(0);
  ready <= '1' when state = state_standby else '0';
end behave;

