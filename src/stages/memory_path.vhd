library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.const_pipeline_state.all;
use work.const_io.all;
use work.const_sram_cmd.all;

use work.typedef_opcode.all;
use work.typedef_data.all;

use work.decode_order_functions.all;
use work.order_utils.all;
use work.pipeline_types.all;

-- <%- require_relative 'src/project_helper' -%>
-- <%- project_components %w(memory_state_decoder) -%>

entity memory_path is
  port(
        order: in order_type;

        exec_addr: in mem_addr_type;
        exec_data: in  word_data_type;
        result_data:  out word_data_type;
        result_order: out order_type;

        sram_write_data: out word_data_type;
        sram_read_data:  in  word_data_type;

        io_write_data: out word_data_type;
        io_read_data:  in  word_data_type;

        sram_addr:       out mem_addr_type;
        sram_cmd:        out sram_cmd_type;

        io_write_cmd: out io_length_type;
        io_read_cmd: out io_length_type;

        io_read_success:  in std_logic;
        io_write_success: in std_logic;
        io_success: out std_logic;

        memory_orders: out memory_orders_type;

        flash_flag: in boolean;
        clk : in std_logic
      );
end memory_path;

architecture behave of memory_path is
-- COMPONENT DEFINITION BLOCK BEGIN {{{
component memory_state_decoder


  port(
      opcode : in opcode_type;
funct : in funct_type;
state : out memory_state_type
       )

;
end component;


-- COMPONENT DEFINITION BLOCK END }}}
-- SIGNAL BLOCK BEGIN {{{
  signal memory_state_decoder_opcode : opcode_type;
signal memory_state_decoder_funct : funct_type;
signal memory_state_decoder_state : memory_state_type;

-- SIGNAL BLOCK END }}}

  signal pipe_buffer: memory_pipe_buffer_type := (others => init_memory_record);
begin
-- COMPONENT MAPPING BLOCK BEGIN {{{
memory_state_decoder_comp: memory_state_decoder
  port map(
      opcode => memory_state_decoder_opcode,
funct => memory_state_decoder_funct,
state => memory_state_decoder_state
       )
;

-- COMPONENT MAPPING BLOCK END }}}
  memory_state_decoder_opcode <= opcode_of_order(order);
  memory_state_decoder_funct <= funct_of_order(order);

  with memory_state_decoder_state select
    io_write_cmd <= io_length_word when memory_state_io_write_w,
                    io_length_byte when memory_state_io_write_b,
                    io_length_none when others;

  with memory_state_decoder_state select
    io_read_cmd <= io_length_word when memory_state_io_read_w,
                   io_length_byte when memory_state_io_read_b,
                   io_length_none when others;

  with memory_state_decoder_state select
    sram_cmd <= sram_cmd_write when memory_state_sram_write,
                sram_cmd_read  when memory_state_sram_read,
                sram_cmd_none  when others;

  with memory_state_decoder_state select
    io_success <= io_write_success when memory_state_io_write_w | memory_state_io_write_b,
                  io_read_success when memory_state_io_read_w | memory_state_io_read_b,
                  '1' when others; -- success unless order is io

  sram_write_data <= exec_data;
  io_write_data <= exec_data;
  sram_addr <= exec_addr;
  process(clk)
  begin
    if rising_edge(clk) then
      if flash_flag then
        -- flash pipeline
        for i in 0 to (pipe_buffer'length - 1) loop
          pipe_buffer(i) <= init_memory_record;
        end loop;
      else
        -- save pipeline
        case memory_state_decoder_state is
          when memory_state_sram_read | memory_state_sram_write =>
            pipe_buffer(0).order <= order;
            pipe_buffer(0).state <= memory_state_decoder_state;
          when others =>
        end case;

        for i in 1 to (pipe_buffer'length - 1) loop
          pipe_buffer(i) <= pipe_buffer(i - 1);
        end loop;
      end if;
    end if;
  end process;

  result_selector : process(
    memory_state_decoder_state,
    pipe_buffer(pipe_buffer'length - 1),
    io_read_data,
    order,
    exec_data,
    sram_read_data
  ) begin
    case pipe_buffer(pipe_buffer'length - 1).state is
      when memory_state_sram_read | memory_state_sram_write =>
        result_data <= sram_read_data;
        result_order <= pipe_buffer(pipe_buffer'length - 1).order;
      when others =>
        case memory_state_decoder_state is
          when memory_state_sram_read | memory_state_sram_write =>
            result_data  <= (others => '0');
            result_order <= (others => '0');
          when memory_state_io_read_b  | memory_state_io_read_w =>
            result_data <= io_read_data;
            result_order <= order;
          when others =>
            result_data <= exec_data;
            result_order <= order;
        end case;
    end case;
  end process;

  process(pipe_buffer, order) begin
    case decode_memory_state(opcode_of_order(order), funct_of_order(order)) is
      when memory_state_sram_read | memory_state_sram_write =>
        memory_orders(0) <= order;
        memory_orders(1) <= pipe_buffer(0).order;
        memory_orders(2) <= pipe_buffer(1).order;
      when others =>
        case pipe_buffer(pipe_buffer'length - 1).state is
          when memory_state_sram_read | memory_state_sram_write =>
            memory_orders(0) <= order;
            memory_orders(1) <= pipe_buffer(0).order;
            memory_orders(2) <= pipe_buffer(1).order;
          when others =>
            memory_orders(0 to 1) <= (others => (others => '0'));
            memory_orders(2) <= order;
        end case;
    end case;
  end process;

end behave;
