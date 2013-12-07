require_relative '../test_helper.rb'
require_relative '../asm_helper.rb'

dep_pathes = ["../../src/const/*.vhd", "../../src/*.vhd",
              "../../src/rs232c/*.vhd", "../../src/sram/sram_mock.vhd",
              "../../src/sram/sram_controller.vhd", "../../src/debug/*.vhd",
              "../../src/top/nemips.vhd",
              "../../src/fpu/fpu_controller.vhd",
              "../../src/fpu/sub_fpu.vhd",
              "../../src/fpu/fpu_decoder.vhd",
              ]

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fmul do
  asm = %q{
.data
F1:
.int 100
.text
  main:
    la r2, F1
    imvf f3, r2
    fmvi r4, f3
    ow r4
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "can byte io" do
    wait_step 400
    step read_length: "io_length_word", read_data: 100, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end


