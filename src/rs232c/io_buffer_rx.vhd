library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_io.all;

entity io_buffer_rx is
  port (
        input:  in std_logic_vector(7 downto 0);
        enqueue: in std_logic;
        dequeue_length: in io_length_type;

        output: out std_logic_vector(31 downto 0);
        ready: out std_logic;
        clk: in std_logic
       );
end io_buffer_rx;

architecture behave of io_buffer_rx is
  subtype buffer_unit is std_logic_vector(7 downto 0);
  type buffer_array is array(0 to 127) of buffer_unit;

  subtype index is std_logic_vector(6 downto 0);
  constant ZERO: buffer_unit := x"00";

  signal buffers: buffer_array := (others => ZERO);
  signal enqueue_idx: index := "0000000";
  signal dequeue_idx: index := "0000000";

  signal de_word_ok: std_logic := '0';
  signal de_byte_ok: std_logic := '0';
  signal de_halfword_ok: std_logic := '0';

  signal read_data: std_logic_vector(31 downto 0) := (others => '0');
  signal current_read_mode: io_length_type := io_length_none;

  attribute ram_style : string;
  attribute ram_style of buffers: signal is "distributed";

begin
  de_byte_ok <= '0' when enqueue_idx = dequeue_idx else '1';

  de_halfword_ok <= '0' when enqueue_idx = dequeue_idx else
                    '0' when std_logic_vector(unsigned(enqueue_idx)) = std_logic_vector(unsigned(dequeue_idx) + 1) else
                    '1';

  de_word_ok <= '0' when enqueue_idx = dequeue_idx else
                '0' when std_logic_vector(unsigned(enqueue_idx)) = std_logic_vector(unsigned(dequeue_idx) + 1) else
                '0' when std_logic_vector(unsigned(enqueue_idx)) = std_logic_vector(unsigned(dequeue_idx) + 2) else
                '0' when std_logic_vector(unsigned(enqueue_idx)) = std_logic_vector(unsigned(dequeue_idx) + 3) else
                '1';

  process(clk) begin
    if rising_edge(clk) then
      read_data(7 downto 0) <= buffers(to_integer(unsigned(dequeue_idx)));
      read_data(15 downto 8) <= buffers(to_integer(unsigned(dequeue_idx) + 1));
      read_data(23 downto 16) <= buffers(to_integer(unsigned(dequeue_idx) + 2));
      read_data(31 downto 24) <= buffers(to_integer(unsigned(dequeue_idx) + 3));

      current_read_mode <= dequeue_length;

      if enqueue = '1' then
        buffers(to_integer(unsigned(enqueue_idx))) <= input;
        enqueue_idx <= std_logic_vector(unsigned(enqueue_idx) + 1);
        ready <= '0';
      else
        case dequeue_length is
          when io_length_word =>
            if de_word_ok = '0' then
              ready <= '0';
            else
              dequeue_idx <= std_logic_vector(unsigned(dequeue_idx) + 4);
              ready <= '1';
            end if;
          when io_length_halfword =>
            if de_halfword_ok = '0' then
              ready <= '0';
            else
              dequeue_idx <= std_logic_vector(unsigned(dequeue_idx) + 2);
              ready <= '1';
            end if;

          when io_length_byte =>
            if de_byte_ok = '0' then
              ready <= '0';
            else
              dequeue_idx <= std_logic_vector(unsigned(dequeue_idx) + 1);
              ready <= '1';
            end if;

          when others =>
            ready <= '0';
        end case;
      end if;
    end if;
  end process;

  with current_read_mode select
    output <= x"00" & x"00" & x"00" & read_data(7 downto 0) when io_length_byte,
              x"00" & x"00" & read_data(15 downto 0) when io_length_halfword,
              read_data when io_length_word,
              (others => '0') when others;
end behave;


