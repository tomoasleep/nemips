library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_io.all;

entity io_buffer_tx is
  generic(buffer_max: integer := 4);
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
  constant buffer_length : integer := 2 ** (buffer_max + 1);

  subtype buffer_unit is std_logic_vector(31 downto 0);
  type buffer_array is array(0 to buffer_length - 1) of buffer_unit;

  subtype length_unit is std_logic_vector(2 downto 0);
  type length_array is array(0 to buffer_length - 1) of length_unit;

  subtype index is std_logic_vector(buffer_max downto 0);
  constant buffer_ZERO: buffer_unit := (others => '0');
  constant length_ZERO: length_unit := (others => '0');

  signal buffers: buffer_array := (others => buffer_ZERO);
  signal lengths: length_array := (others => length_ZERO);
  signal enqueue_idx: index := (others => '0');
  signal dequeue_idx: index := (others => '0');

  signal is_ok_enqueue: std_logic := '0';

  signal stock_buffer : buffer_unit := buffer_ZERO;
  signal stock_length : length_unit := length_ZERO;
begin
  process(clk) begin
    if rising_edge(clk) then
      if is_ok_enqueue = '1' then
        case enqueue_length is
          when io_length_byte =>
            buffers(to_integer(unsigned(enqueue_idx))) <= input;
            lengths(to_integer(unsigned(enqueue_idx))) <= "001";

            enqueue_idx <= std_logic_vector(unsigned(enqueue_idx) + 1);
            enqueue_done <= '1';
          when io_length_halfword =>
            buffers(to_integer(unsigned(enqueue_idx))) <= input;
            lengths(to_integer(unsigned(enqueue_idx))) <= "010";

            enqueue_idx <= std_logic_vector(unsigned(enqueue_idx) + 1);
            enqueue_done <= '1';
          when io_length_word =>
            buffers(to_integer(unsigned(enqueue_idx))) <= input;
            lengths(to_integer(unsigned(enqueue_idx))) <= "100";

            enqueue_idx <= std_logic_vector(unsigned(enqueue_idx) + 1);
            enqueue_done <= '1';
          when others =>
            enqueue_done <= '0';
        end case;
      else
        enqueue_done <= '0';
      end if;

      if stock_length = "000" then
        if dequeue_idx /= enqueue_idx then
          stock_buffer <= buffers(to_integer(unsigned(dequeue_idx)));
          stock_length <= lengths(to_integer(unsigned(dequeue_idx)));
          dequeue_idx <= std_logic_vector(unsigned(dequeue_idx) + 1);
        end if;
      end if;

      if dequeue = '1' then
        if stock_length = "000" then
          dequeue_ready <= '0';
        else
          output <= stock_buffer(7 downto 0);
          stock_buffer <= x"00" & stock_buffer(31 downto 8);
          stock_length <= std_logic_vector(unsigned(stock_length) - 1);

          dequeue_ready <= '1';
        end if;
      else
        dequeue_ready <= '0';
      end if;
    end if;
  end process;

  is_ok_enqueue <= '0' when unsigned(dequeue_idx) = unsigned(enqueue_idx) + 1 else '1';
end behave;


