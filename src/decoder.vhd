library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_opcode.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

entity decoder is
  port(
        instr : in order_type;

        rs_reg  : out register_addr_type;
        rt_reg  : out register_addr_type;
        rd_reg  : out register_addr_type;
        imm     : out immediate_type;
        address : out addr_type;

        opcode : out opcode_type;
        funct  : out funct_type;
        shamt  : out shift_amount_type
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
  shamt <= instr(10 downto 6);
  funct <= instr(5 downto 0);

end behave;

