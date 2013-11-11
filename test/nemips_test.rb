require_relative "../utils/inst_rom_maker.rb"

# VhdlTestScript.scenario "./tb/nemips_tb.vhd" do
#   dependencies "../src/const/const_*.vhd", "../src/const/record_*.vhd",
#     "../src/alu.vhd", "../src/alu_decoder.vhd", "../src/decoder.vhd", "../src/fsm.vhd",
#     "../src/path_controller.vhd", "../src/program_counter.vhd", "../src/register_file.vhd",
#     "../src/sign_extender.vhd", "../src/state_go_selector.vhd", "../src/path.vhd",
#     "../src/rs232c/io_buffer*.vhd", "../src/rs232c/*232c.vhd", "../src/rs232c/io_controller.vhd",
#     "../src/inst_rom/inst_rom.vhd", "../src/sram/sram_controller.vhd",
#     "../src/debug/debug_buffer_rx.vhd", "../src/debug/debug_io_receiver.vhd", "../src/top/nemips.vhd"
# 
#   generics io_wait: 4
#   clock :clk
# 
#   step reset: 1
#   step reset: 0
#   wait_step 300
#   step read_length: "io_length_word", read_addr: 0, read_data: 0b0101010110101010, read_ready: 1
#   step read_length: "io_length_byte", read_addr: 4, read_ready: 0
# end

VhdlTestScript.scenario "./tb/nemips_tb.vhd" do
  asm = %q{
.text
  main:
    li r1, 12
    bne r1, r0, bne.1
    li r2, 0
    j rtn
  bne.1:
    li r2, 1
  rtn:
    ob r2
    halt
  }
  inst_path = InstRom.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd", "../src/sram/sram_mock.vhd",
    "../src/sram/sram_controller.vhd", "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 4
  clock :clk

  context "can branch" do
    step reset: 1
    step reset: 0
    wait_step 400
    step read_length: "io_length_byte", read_addr: 0, read_data: 1, read_ready: 1
    step read_length: "io_length_byte", read_addr: 4, read_ready: 0
  end
end

VhdlTestScript.scenario "./tb/nemips_tb.vhd" do
  asm = %q{
.text
  main:
    li r1, 12
    sw r1, 20(r0)
    li r1, 8
    lw r1, 12(r1)
    ow r1
    halt
  }
  inst_path = InstRom.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
    "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 4
  clock :clk

  context "can memory load" do
    step reset: 1
    step reset: 0
    wait_step 300
    step sram_debug_addr: 20, sram_debug_data: 12
    step read_length: "io_length_word", read_addr: 0, read_data: 12, read_ready: 1
    step read_length: "io_length_byte", read_addr: 4, read_ready: 0
  end
end

VhdlTestScript.scenario "./tb/nemips_tb.vhd" do
  asm = %q{
.text
  j	_min_caml_start
fib.10:
  li	r3, 1
  bgt	r2, r3, ble_else.24
  jr	r31
ble_else.24:
  addi	r3, r2, -1
  sw	r2, 0(r29)
  move	r2, r3
  sw	r31, -1(r29)
  addi	r29, r29, -2
  jal	fib.10
  addi	r29, r29, 2
  lw	r31, -1(r29)
  lw	r3, 0(r29)
  addi	r3, r3, -2
  sw	r2, -1(r29)
  move	r2, r3
  sw	r31, -2(r29)
  addi	r29, r29, -3
  jal	fib.10
  addi	r29, r29, 3
  lw	r31, -2(r29)
  lw	r3, -1(r29)
  add	r2, r3, r2
  jr	r31
_min_caml_start: # main entry point
   # main program start
  li	r2, 3
  sw	r31, 0(r29)
  addi	r29, r29, -1
  jal	fib.10
  addi	r29, r29, 1
  lw	r31, 0(r29)
  sw	r31, 0(r29)
  addi	r29, r29, -1
  ow  r2
  addi	r29, r29, 1
  lw	r31, 0(r29)
   # main program end
  halt
  }
  inst_path = InstRom.from_asm(asm).path

  dependencies "../src/const/*.vhd", "../src/*.vhd", "../src/rs232c/*.vhd",
    "../src/sram/sram_controller.vhd", "../src/sram/sram_mock.vhd",
    "../src/debug/*.vhd", "../src/top/nemips.vhd",
    inst_path

  generics io_wait: 4
  clock :clk

  context "can memory load" do
    step reset: 1
    step reset: 0
    wait_step 1000
    step read_length: "io_length_word", read_addr: 0, read_data:  2, read_ready: 1
    step read_length: "io_length_byte", read_addr: 4, read_ready: 0
  end
end

