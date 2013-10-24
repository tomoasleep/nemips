library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_state.all;
use work.const_mux.all;
use work.const_alu_ctl.all;

entity memory_interface is
  port(
        address_in : in std_logic_vector(31 downto 0);
        memory_in : in std_logic_vector(31 downto 0);
        write_data : in std_logic_vector(31 downto 0);
        write_enable: in std_logic;

        read_data: out std_logic_vector(31 downto 0);
        write_out: out std_logic;
        write_out_data: out std_logic_vector(31 downto 0);
        address_out : out std_logic_vector(31 downto 0);
        clk : in std_logic
      );
end memory_interface;

architecture behave of memory_interface is
begin
  main :process(clk) begin
    read_data <= memory_in;
    write_out <= write_enable;
    address_out <= address_in;
    write_out_data <= write_data;
  end process;
end behave;

