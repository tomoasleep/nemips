VhdlTestScript.scenario "./tb/nemips_tb.vhd" do
  dependencies "../src/const/const_*.vhd", "../src/const/record_*.vhd",
    "../src/alu.vhd", "../src/alu_decoder.vhd", "../src/decoder.vhd", "../src/fsm.vhd",
    "../src/path_controller.vhd", "../src/program_counter.vhd", "../src/register_file.vhd",
    "../src/sign_extender.vhd", "../src/state_go_selector.vhd", "../src/path.vhd",
    "../src/rs232c/io_buffer*.vhd", "../src/rs232c/*232c.vhd", "../src/rs232c/io_controller.vhd",
    "../src/inst_rom/inst_rom.vhd", "../src/sram/sram_controller.vhd",
    "../src/debug/debug_buffer_rx.vhd", "../src/debug/debug_io_receiver.vhd", "../src/top/nemips.vhd"

  generics io_wait: 4
  clock :clk

  step reset: 1
  step reset: 0
  wait_step 300
  step read_length: "io_length_word", read_addr: 0, read_data: 0b0101010110101010, read_ready: 1
  step read_length: "io_length_byte", read_addr: 4, read_ready: 0
end
