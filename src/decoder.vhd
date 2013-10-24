library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_opcode.all;

entity decoder is
  port(
        instr : in std_logic_vector(31 downto 0);

        rs_reg : out std_logic_vector(4 downto 0);
        rt_reg : out std_logic_vector(4 downto 0);
        rd_reg : out std_logic_vector(4 downto 0);
        imm    : out std_logic_vector(15 downto 0);
        address : out std_logic_vector(25 downto 0);

        opcode : out std_logic_vector(5 downto 0);
        funct  : out std_logic_vector(5 downto 0);
        shamt  : out std_logic_vector(4 downto 0)
      );
end decoder;

architecture behave of decoder is
begin
  rs_reg <= instr(25 downto 21);
  rt_reg <= instr(20 downto 16);
  rd_reg <= instr(15 downto 11);
  imm <= instr(15 downto 0);
  opcode <= instr(31 downto 26);
  address <= instr(25 downto 0);
  shamt <= instr(4 downto 0);
  funct <= instr(5 downto 0);

end behave;

