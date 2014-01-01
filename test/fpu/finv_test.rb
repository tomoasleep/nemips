require_relative '../test_helper.rb'
require_relative '../asm_helper.rb'

dep_pathes = [*path_dependencies, *FINV_PATHES]

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fadd do
  asm = %q{
.data
F1:
.float 1.0 
.text
  main:
    la  r10, F1
    lwf f10, 0(r10)
    finv f4, f10
    fmvi r4, f4
    ow r4
    break
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "finv(1.0) = 1.0" do
    wait_step 400
    step read_length: "io_length_word", read_data: 1.0.to_binary, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :finv do
  asm = %q{
.data
F1:
.float 2.0 
.text
  main:
    la  r10, F1
    lwf f10, 0(r10)
    finv f4, f10
    fmvi r4, f4
    ow r4
    break
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "finv(2.0) = 0,5" do
    wait_step 400
    step read_length: "io_length_word", read_data: 0.5.to_binary, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fdiv do
  asm = %q{
.data
F1:
.float 2.0 
.text
  main:
    la  r10, F1
    lwf f10, 0(r10)
    fdiv f4, f10, f10
    fmvi r4, f4
    ow r4
    break
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "2.0 / 2.0 = 1.0" do
    wait_step 400
    step read_length: "io_length_word", read_data: 1.0.to_binary, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

