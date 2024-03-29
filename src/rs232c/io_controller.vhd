library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_io.all;

entity io_controller is
  generic(
        wtime: std_logic_vector(15 downto 0) := x"1ADB";
        buffer_max: integer := 4);
    port (
        write_data : in std_logic_vector(31 downto 0);
        write_length: in io_length_type;
        read_length: in io_length_type;

        read_data: out std_logic_vector(31 downto 0);
        read_data_past: out std_logic_vector(31 downto 0);
        read_data_ready  : out std_logic;
        write_data_ready : out std_logic;

        rs232c_in : in std_logic;
        rs232c_out: out std_logic;
        clk : in std_logic
         );
end io_controller;

architecture behave of io_controller is
  component io_buffer_tx
    generic(buffer_max: integer := 4);
    port(
        input:  in std_logic_vector(31 downto 0);
        enqueue_length: in io_length_type;
        dequeue: in std_logic;

        output: out std_logic_vector(7 downto 0);
        enqueue_done: out std_logic;
        dequeue_ready: out std_logic;

        clk: in std_logic);
  end component;

  component tx232c
    generic (wtime: std_logic_vector(15 downto 0) := x"1ADB");
    Port ( clk   : in  STD_LOGIC;
           data  : in  STD_LOGIC_VECTOR (7 downto 0);
           go    : in  STD_LOGIC;
           ready : out STD_LOGIC;
           tx    : out STD_LOGIC);
  end component;

  component io_buffer_rx
    port (
          input:  in std_logic_vector(7 downto 0);
          enqueue: in std_logic;
          dequeue_length: in io_length_type;

          output: out std_logic_vector(31 downto 0);
          past_output: out std_logic_vector(31 downto 0);
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
  signal io_wait : std_logic_vector(15 downto 0);
begin
  io_wait <= wtime;
  buf_tx: io_buffer_tx 
  generic map(buffer_max => buffer_max)
  port map(
      input => write_data,
      enqueue_length => write_length,
      dequeue => tx_dequeue,
      output => tx_data,
      enqueue_done => write_data_ready,
      dequeue_ready => txbuf_ready,
      clk => clk);

  buf_rx: io_buffer_rx port map(
      input => rx_data,
      enqueue => rx_ready,
      dequeue_length => read_length,
      output => read_data,
      past_output => read_data_past,
      ready => read_data_ready,
      clk => clk);

  tx: tx232c
    generic map(wtime => wtime)
    port map(
      data => tx_data,
      go => txbuf_ready,
      ready => tx_ready,
      tx => rs232c_out,
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
