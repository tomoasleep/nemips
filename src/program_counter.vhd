library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.typedef_data.all;

entity program_counter is
  port(
        write_data:  in pc_data_type;
        pc:  out pc_data_type;

        pc_write: in std_logic;
        reset: in std_logic;
        clk : in std_logic
      );
end program_counter;

architecture behave of program_counter is
  signal current_pc : pc_data_type := (others => '0');
begin
  process (clk) begin
    if rising_edge(clk) then
      if reset = '1' then
        current_pc <= (others => '0');
      elsif pc_write = '1' then
        current_pc <= write_data;
      end if;
    end if;
  end process;

  pc <= current_pc;
end behave;

