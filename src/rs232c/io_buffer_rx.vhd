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
begin
  process(clk) begin
    if rising_edge(clk) then
      case dequeue_length is
        when io_length_word =>
          if enqueue_idx = dequeue_idx or
              std_logic_vector(unsigned(enqueue_idx)) =
                std_logic_vector(unsigned(dequeue_idx) + 1) or
              std_logic_vector(unsigned(enqueue_idx)) =
                std_logic_vector(unsigned(dequeue_idx) + 2) or
              std_logic_vector(unsigned(enqueue_idx)) =
                std_logic_vector(unsigned(dequeue_idx) + 3) then
            ready <= '0';
          else
            output(7 downto 0) <= buffers(to_integer(unsigned(dequeue_idx)));
            output(15 downto 8) <= buffers(to_integer(unsigned(dequeue_idx) + 1));
            output(23 downto 16) <= buffers(to_integer(unsigned(dequeue_idx) + 2));
            output(31 downto 24) <= buffers(to_integer(unsigned(dequeue_idx) + 3));
            dequeue_idx <= std_logic_vector(unsigned(dequeue_idx) + 4);
            ready <= '1';
          end if;
        when io_length_halfword =>
          if enqueue_idx = dequeue_idx or
              std_logic_vector(unsigned(enqueue_idx)) =
              std_logic_vector(unsigned(dequeue_idx) + 1) then
            ready <= '0';
          else
            output(7 downto 0) <= buffers(to_integer(unsigned(dequeue_idx)));
            output(15 downto 8) <= buffers(to_integer(unsigned(dequeue_idx) + 1));
            output(31 downto 16) <= (others => '0');
            dequeue_idx <= std_logic_vector(unsigned(dequeue_idx) + 2);
            ready <= '1';
          end if;
        when io_length_byte =>
          if enqueue_idx = dequeue_idx then
            ready <= '0';
          else
            output(7 downto 0) <= buffers(to_integer(unsigned(dequeue_idx)));
            output(31 downto 8) <= (others => '0');
            dequeue_idx <= std_logic_vector(unsigned(dequeue_idx) + 1);
            ready <= '1';
          end if;
        when others =>
          ready <= '0';
      end case;

      if enqueue = '1' then
        buffers(to_integer(unsigned(enqueue_idx))) <= input;
        enqueue_idx <= std_logic_vector(unsigned(enqueue_idx) + 1);
      end if;
    end if;
  end process;
end behave;


