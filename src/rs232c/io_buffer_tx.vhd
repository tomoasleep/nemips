library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_io.all;

entity io_buffer_tx is
  port (
        input:  in std_logic_vector(31 downto 0);
        enqueue_length: in io_length_type;
        dequeue: in std_logic;

        output: out std_logic_vector(7 downto 0);
        enqueue_done: out std_logic;
        dequeue_ready: out std_logic;

        clk: in std_logic
       );
end io_buffer_tx;

architecture behave of io_buffer_tx is
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
      case enqueue_length is
        when io_length_byte =>
          if unsigned(dequeue_idx) = unsigned(enqueue_idx) + 1 then
            enqueue_done <= '0';
          else
            buffers(to_integer(unsigned(enqueue_idx))) <= input(7 downto 0);
            enqueue_idx <= std_logic_vector(unsigned(enqueue_idx) + 1);
            enqueue_done <= '1';
          end if;
        when io_length_halfword =>
          if unsigned(dequeue_idx) = unsigned(enqueue_idx) + 1 or
             unsigned(dequeue_idx) = unsigned(enqueue_idx) + 2 then
            enqueue_done <= '0';
          else
            buffers(to_integer(unsigned(enqueue_idx))) <= input(7 downto 0);
            buffers(to_integer(unsigned(enqueue_idx) + 1)) <= input(15 downto 8);
            enqueue_idx <= std_logic_vector(unsigned(enqueue_idx) + 2);
            enqueue_done <= '1';
          end if;
        when io_length_word =>
          if unsigned(dequeue_idx) = unsigned(enqueue_idx) + 1 or
             unsigned(dequeue_idx) = unsigned(enqueue_idx) + 2 or
             unsigned(dequeue_idx) = unsigned(enqueue_idx) + 3 or
             unsigned(dequeue_idx) = unsigned(enqueue_idx) + 4 then
            enqueue_done <= '0';
          else
            buffers(to_integer(unsigned(enqueue_idx))) <= input(7 downto 0);
            buffers(to_integer(unsigned(enqueue_idx) + 1)) <= input(15 downto 8);
            buffers(to_integer(unsigned(enqueue_idx) + 2)) <= input(23 downto 16);
            buffers(to_integer(unsigned(enqueue_idx) + 3)) <= input(31 downto 24);
            enqueue_idx <= std_logic_vector(unsigned(enqueue_idx) + 4);
            enqueue_done <= '1';
          end if;
        when others =>
          enqueue_done <= '0';
      end case;

      if dequeue = '1' then
        if dequeue_idx = enqueue_idx then
          dequeue_ready <= '0';
        else
          output <= buffers(to_integer(unsigned(dequeue_idx)));
          dequeue_ready <= '1';
          dequeue_idx <= std_logic_vector(unsigned(dequeue_idx) + 1);
        end if;
      else
        dequeue_ready <= '0';
      end if;
    end if;
  end process;
end behave;


