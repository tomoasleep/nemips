require_relative '../test_helper.rb'
require_relative '../asm_helper.rb'

dep_pathes = [*path_dependencies, FMUL_PATH]

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fmul do
  asm = %q{
.data
F1:
.text
  main:
    fmul f4, f2, f3
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


VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fmul do
  asm = %q{
.data
F1:
.float 1.0 
.text
  main:
    ld r2, F1
    imvf f2, r2
    fmul f4, f2, f2
    fmvi r4, f4
    ow r4
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "can byte io" do
    wait_step 400
    step read_length: "io_length_word", read_data: 1.0.to_binary, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :fact do
  asm = %q{
.data
F1:
.float 1.0 
.text
  main:
    li r4, 5
    ld r2, F1
    imvf f2, r2
  fact:
    iw  r3
    imvf f3, r3
    fmul f2, f2, f3
    addi r4, r4, -1
    bgtz r4, fact
  return:
    fmvi r2, f2
    ow r2
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *dep_pathes

  generics io_wait: 1
  clock :clk

  context "can byte io" do
    wait_step 10
    (1..5).each do |i|
      step write_length: "io_length_word", write_data: i.to_f.to_binary
      step write_length: "io_length_none"
      wait_step 100
    end
    wait_step 400
    step read_length: "io_length_word",
      read_data: (1..5).inject(&:*).to_f.to_binary, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end


