library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
  port(
        write_data:  in std_logic_vector(29 downto 0);
        pc:  out std_logic_vector(29 downto 0);

        pc_write: in std_logic;
        clk : in std_logic
      );
end program_counter;

architecture behave of program_counter is
begin
  process (clk) begin
    if rising_edge(clk) and pc_write = '1' then
      pc <= write_data;
    end if;
  end process;
end behave;

