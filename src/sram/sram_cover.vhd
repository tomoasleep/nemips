library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sram_cover is
  port(
        data_in: in std_logic_vector(31 downto 0);
        data_out: out std_logic_vector(31 downto 0);
        clk : in std_logic;
        address : in std_logic_vector(7 downto 0);
        cfg_inout: in std_logic;
        we: in std_logic
      );
end sram_cover;

architecture behave of sram_cover is
  component sram_mock
    port (
        data: inout std_logic_vector(31 downto 0);
        clk : in std_logic;
        address : in std_logic_vector(7 downto 0);
        we: in std_logic
      );
  end component;
  signal data_pipe:  std_logic_vector(31 downto 0);
begin
  mock: sram_mock
  port map(
            data=>data_pipe,
            clk=>clk,
            address=>address,
            we=>we
          );

  process (cfg_inout, data_in, data_pipe) begin
    case cfg_inout is
      when '1' =>
        data_pipe <= data_in;
      when others =>
        data_out <= data_pipe;
    end case;
  end process;
end behave;
