require_relative '../test_helper.rb'
require_relative '../asm_helper.rb'

VhdlTestScript.scenario '../tb/nemips_tbq.vhd', :fpu, :fcseq do
  asm = %q{
.data
F1:
.float 1.0
.text
  main:
    ld r2, F1
    imvf f2, r2
    fcseq r4, f2, f0
    ow r4
    break
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *path_dependencies

  generics io_wait: 1
  clock :clk

  context "fcseq should return 0" do
    wait_step 400
    step is_break: 1
    step read_length: "io_length_word", read_data: 0, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

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

VhdlTestScript.scenario '../tb/nemips_tbq.vhd', :fpu, :fclt do
  asm = %q{
.data
F1:
.float 1.0
.float -1.0
.float 3.0
.float -3.0
.text
  main:
    la r11, F1
    lwf f11, 0(r11)
    lwf f12, 1(r11)
    lwf f13, 2(r11)
    lwf f14, 3(r11)
    nop
    fclt r4, f11, f0
    ow r4
    fclt r4, f12, f0
    ow r4
    fclt r4, f12, f11
    ow r4
    fclt r4, f12, f14
    ow r4
    fclt r4, f11, f14
    ow r4
    fclt r4, f11, f13
    ow r4
    break
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *path_dependencies

  generics io_wait: 1
  clock :clk

  wtime = 500

  context "fclt(1, 0) should return 0" do
    wait_step wtime
    step read_length: "io_length_word", read_data: 0, read_ready: 1
    step read_length: "io_length_none"
  end

  context "fclt(-1, 0) should return 1" do
    wait_step wtime
    step read_length: "io_length_word", read_data: 1, read_ready: 1
    step read_length: "io_length_none"
  end

  context "fclt(-1, 1) should return 1" do
    wait_step wtime
    step read_length: "io_length_word", read_data: 1, read_ready: 1
    step read_length: "io_length_none"
  end

  context "fclt(-1, -3) should return 0" do
    wait_step wtime
    step read_length: "io_length_word", read_data: 0, read_ready: 1
    step read_length: "io_length_none"
  end

  context "fclt(1, -3) should return 0" do
    wait_step wtime
    step read_length: "io_length_word", read_data: 0, read_ready: 1
    step read_length: "io_length_none"
  end

  context "fclt(1, 3) should return 1" do
    wait_step wtime
    step read_length: "io_length_word", read_data: 1, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :lwf do
  asm = %q{
.data
F1:
.float 1.0
.text
  main:
    la r2, F1
    lwf f2, 0(r2)
    fmvi r4, f2
    ow r4
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *path_dependencies

  generics io_wait: 1
  clock :clk

  context "can la and lwf" do
    wait_step 400
    step read_length: "io_length_word", read_data: 1.0.to_binary, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end

VhdlTestScript.scenario "../tb/nemips_tbq.vhd", :swf do
  asm = %q{
.data
F1:
.float 1.0
.float 2.0
.text
  main:
    la r2, F1
    lwf f2, 0(r2)
    swf f2, 1(r2)
    lw r4, 1(r2)
    ow r4
    halt
  }
  inst_path = InstRam.from_asm(asm).path

  dependencies inst_path, *path_dependencies

  generics io_wait: 1
  clock :clk

  context "can swf" do
    wait_step 400
    step read_length: "io_length_word", read_data: 1.0.to_binary, read_ready: 1
    step read_length: "io_length_byte", read_ready: 0
  end
end
