library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_pipeline_state.all;
use work.const_io.all;
use work.const_sram_cmd.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

use work.order_utils.all;
use work.pipeline_types.all;

-- <%- require_relative 'src/project_helper' -%>
-- <%- project_components %w(write_back_state_decoder) -%>

entity write_back_path is
  port(
        order: in order_type;
        memory_data: in  word_data_type;

        reg_write_data: out word_data_type;
        reg_write_addr: out register_addr_type;

        io_success: in std_logic;

        ireg_write_enable: out std_logic;
        freg_write_enable: out std_logic;

        clk : in std_logic
      );
end write_back_path;

architecture behave of write_back_path is
-- COMPONENT DEFINITION BLOCK BEGIN {{{
component write_back_state_decoder


  port(
      opcode : in opcode_type;
funct : in funct_type;
state : out write_back_state_type
       )

;
end component;


-- COMPONENT DEFINITION BLOCK END }}}
-- SIGNAL BLOCK BEGIN {{{
  signal write_back_state_decoder_opcode : opcode_type;
signal write_back_state_decoder_funct : funct_type;
signal write_back_state_decoder_state : write_back_state_type;

-- SIGNAL BLOCK END }}}
  constant jal_register: register_addr_type := "11111";
begin
-- COMPONENT MAPPING BLOCK BEGIN {{{
write_back_state_decoder_comp: write_back_state_decoder
  port map(
      opcode => write_back_state_decoder_opcode,
funct => write_back_state_decoder_funct,
state => write_back_state_decoder_state
       )
;

-- COMPONENT MAPPING BLOCK END }}}
  write_back_state_decoder_opcode <= opcode_of_order(order);
  write_back_state_decoder_funct <= funct_of_order(order);

  process(write_back_state_decoder_state, order)
  begin
  end process;

  with write_back_state_decoder_state select
    ireg_write_enable <= '1' when write_back_state_wb_rd |
                                  write_back_state_wb_rt |
                                  write_back_state_jal_wb,
                         '0' when others;

  with write_back_state_decoder_state select
    freg_write_enable <= '1' when write_back_state_wb_fd |
                                  write_back_state_wb_ft,
                         '0' when others;

  reg_write_data <= memory_data;

  with write_back_state_decoder_state select
    reg_write_addr <= rd_of_order(order) when write_back_state_wb_rd |
                                              write_back_state_wb_fd,
                      rt_of_order(order) when write_back_state_wb_rt |
                                              write_back_state_wb_ft,
                      jal_register       when write_back_state_jal_wb,
                      (others => '0') when others;

end behave;

