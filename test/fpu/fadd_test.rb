require_relative '../test_helper.rb'
require_relative '../asm_helper.rb'

dep_pathes = [*path_dependencies, *FADD_PATHES]

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fadd do
  asm = %q{
.data
F1:
.text
  main:
    fadd f4, f2, f3
    break
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "can byte io" do
    wait_step 200
    step is_break: 1
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fadd do
  asm = %q{
.data
F1:
.float 1.0 
.text
  main:
    la  r10, F1
    lwf f10, 0(r10)
    fadd f4, f10, f10
    fmvi r4, f4
    ow r4
    break
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "1.0 + 1.0 = 2.0" do
    wait_step 400
    step read_length: "io_length_word", read_data: 2.0.to_binary, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fadd, :zero do
  asm = %q{
.data
F1:
.float 1.0 
F2:
.float -1.0 
.text
  main:
    la  r10, F1
    lwf f10, 0(r10)
    lwf f11, 1(r10)
    fadd f4, f10, f11
    fmvi r4, f4
    ow r4
    break
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "1.0 + (-1.0) = 0.0" do
    wait_step 400
    step read_length: "io_length_word", read_data: 0.0.to_binary, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fsub, :zero do
  asm = %q{
.data
F1:
.float 1.0 
.text
  main:
    la  r10, F1
    lwf f10, 0(r10)
    fsub f4, f10, f10
    fmvi r4, f4
    ow r4
    break
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "1.0 - 1.0 = 0.0" do
    wait_step 400
    step read_length: "io_length_word", read_data: 0.0.to_binary, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fsub do
  asm = %q{
.data
F1:
.float 2.0 
F2:
.float 1.0 
.text
  main:
    la  r10, F1
    lwf f10, 0(r10)
    lwf f11, 1(r11)
    fsub f4, f10, f11
    fmvi r4, f4
    ow r4
    break
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "2.0 - 1.0 = 1.0" do
    wait_step 400
    step read_length: "io_length_word", read_data: 1.0.to_binary, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

