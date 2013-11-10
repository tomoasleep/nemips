library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_sram_cmd.all;
use work.const_io.all;

entity debug_io_receiver is
  generic(wtime: std_logic_vector(15 downto 0) := x"1ADB");
    port (
        -- write_data : in std_logic_vector(31 downto 0);
        -- write_length: in io_length_type;
        read_length: in io_length_type;
        read_addr: in std_logic_vector(10 downto 0);

        read_data: out std_logic_vector(31 downto 0);
        read_data_ready  : out std_logic;
        -- write_data_ready : out std_logic;

        rs232c_in : in std_logic;
        -- rs232c_out: out std_logic;
        clk : in std_logic
         );
end debug_io_receiver;

architecture behave of debug_io_receiver is
  component debug_buffer_rx
    port (
          input:  in std_logic_vector(7 downto 0);
          enqueue: in std_logic;
          read_length: in io_length_type;
          read_addr: in std_logic_vector(10 downto 0);

          output: out std_logic_vector(31 downto 0);
          ready: out std_logic;
          clk: in std_logic);
  end component;

  component rx232c
    generic (wtime: std_logic_vector(15 downto 0) := x"1ADB");
    Port ( clk   : in  std_logic;
           rx    : in std_logic;
           ready : out std_logic;
           data  : out  std_logic_vector (7 downto 0));
  end component;

  signal dequeue_txbuf : std_logic := '0';
  signal tx_data, rx_data : std_logic_vector(7 downto 0) := (others => '0');
  signal txbuf_ready, tx_ready, rx_ready : std_logic;
  signal tx_dequeue : std_logic;
begin
  buf_rx: debug_buffer_rx port map(
      input => rx_data,
      enqueue => rx_ready,
      read_length => read_length,
      read_addr => read_addr,
      output => read_data,
      ready => read_data_ready,
      clk => clk);

  rx: rx232c
    generic map(wtime => wtime)
    port map(
      data => rx_data,
      ready => rx_ready,
      rx => rs232c_in,
      clk => clk);

    tx_dequeue <= '1' when tx_ready = '1' and txbuf_ready = '0' else '0';
end behave;
