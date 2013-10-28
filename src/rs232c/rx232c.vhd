library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity rx232c is
  generic (wtime: std_logic_vector(15 downto 0) := x"1ADB");
  Port ( clk   : in  std_logic;
         rx    : in std_logic;
         ready : out std_logic;
         data  : out  std_logic_vector (7 downto 0));
end rx232c;

architecture behave of rx232c is
  constant state_standby : std_logic_vector(3 downto 0) := x"0";
  constant state_byte_ready : std_logic_vector(3 downto 0) := x"1";
  constant state_write_byte : std_logic_vector(3 downto 0) := x"2";
  constant state_start_bit : std_logic_vector(3 downto 0) := x"b";
  constant ZERO: std_logic_vector(15 downto 0) := (others=>'0');

  signal countdown: std_logic_vector(15 downto 0) := (others=>'0');
  signal state: std_logic_vector(3 downto 0) := state_standby;
  signal sendbuf: std_logic_vector(7 downto 0) := (others=>'1');
begin
  state_machine: process(clk)
  begin

    if rising_edge(clk) then
      case state is
        when state_standby =>
          if rx = '0' then
            sendbuf <= (others=>'0');
            state <= state_start_bit;
            countdown <= '0' & wtime(15 downto 1);
          end if;

        when state_byte_ready =>
          state <= std_logic_vector(unsigned(state) - 1);

        when state_write_byte =>
          if countdown = ZERO then
            data <= sendbuf;

            state <= std_logic_vector(unsigned(state) - 1);
          else
            countdown <= std_logic_vector(unsigned(countdown) - 1);
          end if;

        when state_start_bit =>
          if countdown = ZERO then
            if rx = '1' then
              state <= state_standby;
            else
              state <= std_logic_vector(unsigned(state) - 1);
              countdown <= wtime;
            end if;
          else
            countdown <= std_logic_vector(unsigned(countdown) - 1);
          end if;

        when others =>
          if countdown = ZERO then
            sendbuf <= rx & sendbuf(7 downto 1);
            countdown <= wtime;
            state <= std_logic_vector(unsigned(state) - 1);
          else
            countdown <= std_logic_vector(unsigned(countdown) - 1);
          end if;
      end case;
    end if;
  end process;

  ready <= '1' when state = state_byte_ready else '0';
end behave;

