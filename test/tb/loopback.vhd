library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_io.all;

library UNISIM;
use UNISIM.VComponents.all;

entity loopback is
    Port ( MCLK1 : in std_logic;
           RS_RX : in std_logic;
           RS_TX : out std_logic);
end loopback;

architecture behave of loopback is
  signal clk, iclk: std_logic;

  component io_controller
    generic(wtime: std_logic_vector(15 downto 0) := x"1ADB");
    port (
           write_data : in std_logic_vector(31 downto 0);
           write_length: in io_length_type;
           read_length: in io_length_type;

           read_data: out std_logic_vector(31 downto 0);
           read_data_ready  : out std_logic;
           write_data_ready : out std_logic;

           rs232c_in : in std_logic;
           rs232c_out: out std_logic;
           clk : in std_logic
         );
  end component;
  signal data : std_logic_vector(31 downto 0);
  signal write : io_length_type;
  signal nouse, read_data_ready : std_logic;
begin
  ib: IBUFG port map (
    i=>MCLK1,
    o=>iclk);
  bg: BUFG port map (
    i=>iclk,
    o=>clk);

  io: io_controller generic map (wtime => x"1ADB")
  port map(
            write_data => data,
            write_length => write,
            read_length => io_length_word,

            read_data => data,
            read_data_ready => read_data_ready,
            write_data_ready => nouse,

            rs232c_in => RS_RX,
            rs232c_out => RS_TX,
            clk => clk
          );

  with read_data_ready select
    write <= io_length_word when '1',
             io_length_none when others;
end behave;

