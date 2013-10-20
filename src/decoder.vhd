library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.opcode.all;

entity decoder is
  port(
        instr : in std_logic_vector(31 downto 0);

        rs_reg : out std_logic_vector(4 downto 0);
        rt_reg : out std_logic_vector(4 downto 0);
        rd_reg : out std_logic_vector(4 downto 0);
        imm    : out std_logic_vector(15 downto 0);
        address : out std_logic_vector(25 downto 0);

        shamt  : out std_logic_vector(4 downto 0);
        funct  : out std_logic_vector(4 downto 0);

        clk : in std_logic
      );
end decoder;

architecture behave of decoder is
  subtype register_unit is std_logic_vector(31 downto 0);
  type register_array is array (0 to 31) of register_unit;

  signal registers: data_array;
  constant ZERO: std_logic_vector(31 downto 0) := "x00000000";
begin
  registers(0) <= ZERO; 

  main: process (instr)
  begin
    case (instr(31 downto 26)) is
      when '0' => 
          -- write
        registers(conv_integer(a3)) <= wd3;
      when '1' =>
      -- read
    end case;
  end process;

  rs_reg <= instr(25 downto 21);
  rt_reg <= instr(20 downto 16);
  rd_reg <= instr(15 downto 11);
  imm <= instr(15 downto 0); 
  address <= instr(25 downto 0); 
  shamt <= instr(4 downto 0); 
  funct <= instr(4 downto 0);

end behave;

