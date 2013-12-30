require_relative '../test_helper.rb'
require_relative '../asm_helper.rb'


VhdlTestScript.scenario '../tb/nemips_tbq.vhd', :fpu, :fbeq do
  asm = %q{
.data
F1:
.float 1.0 
.text
  main:
    ld r2, F1
    imvf f2, r2
    fbeq f2, f0, dame
    li r4, 1
    ow r4
    break
    halt
  dame:
    break
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *path_dependencies

  generics io_wait: 1
  clock :clk

  context "dont fbeq" do
    wait_step 400
    step is_break: 1
    step read_length: "io_length_word", read_data: 1, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario '../tb/nemips_tbq.vhd', :fpu, :fbeq do
  asm = %q{
.data
F1:
.float 0 
.text
  main:
    ld r2, F1
    imvf f2, r2
    fbeq f2, f0, ok
    break
    halt
  ok:
    li r4, 1
    ow r4
    break
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *path_dependencies

  generics io_wait: 1
  clock :clk

  context "do fbeq" do
    wait_step 400
    step is_break: 1
    step read_length: "io_length_word", read_data: 1, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end
