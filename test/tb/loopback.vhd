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
    generic(wtime: std_logic_vector(15 downto 0) := x"1ADB";
            buffer_max: integer := 4);
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
  signal rdata, wdata : std_logic_vector(31 downto 0);
  signal write : io_length_type;
  signal nouse, read_data_ready : std_logic;
begin
  ib: IBUFG port map (
    i=>MCLK1,
    o=>iclk);
  bg: BUFG port map (
    i=>iclk,
    o=>clk);

  io: io_controller generic map (wtime => x"0240", buffer_max => 4)
  port map(
            write_data => wdata,
            write_length => write,
            read_length => io_length_byte,

            read_data => rdata,
            read_data_ready => read_data_ready,
            write_data_ready => nouse,

            rs232c_in => RS_RX,
            rs232c_out => RS_TX,
            clk => clk
          );

  process(clk) begin
    if rising_edge(clk) then
      case read_data_ready is
        when '1' =>
          write <= io_length_byte;
          wdata <= rdata;
        when others =>
          write <= io_length_none;
      end case;
    end if;
  end process;
end behave;

