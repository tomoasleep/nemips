require_relative '../test_helper.rb'
require_relative '../asm_helper.rb'

dep_pathes = [*path_dependencies, *FADD_PATHES, *FMUL_PATHES, *FINV_PATHES]
libmincaml_path = pfr('test/asm/libmincaml.S')
libmincaml_asm = File.read(libmincaml_path)

min_rt_read_path = pfr('test/asm/min-rt-read-screen.s')
min_rt_read_asm = File.read(min_rt_read_path)

globals_path = pfr('test/asm/globals.s')
globals_asm = File.read(globals_path)


VhdlTestScript.scenario '../tb/nemips_tbq.vhd', :man do
  inst_path = InstRam.from_asm(min_rt_read_asm + globals_asm + libmincaml_asm).path
  dependencies inst_path, *dep_pathes

  generics io_wait: 1, sram_length: 15
  clock :clk

  context "min_rt read parameter" do
    [-70, 35, -20, 20, 30].map(&:to_f).each do |i|
      step write_length: 'io_length_word', write_data: i
      step write_length: 'io_length_none'
    end

    wait_step 5000
    step is_break: 1

    fdumps = %w(
-70.0
35.0
-20.0
93.96926
-68.40402
162.75954
0.86602545
0.0
-0.5
-0.17101006
-0.9396926
-0.29619813
-163.96927
103.40402
-182.75954
)

    dumps = %w{
    0xc28c0000
    0x420c0000
    0xc1a00000
    0x42bbf043
    0xc288cedc
    0x4322c271
    0x3f5db3d8
    0x00000000
    0xbf000000
    0xbe2f1d43
    0xbf708fb2
    0xbe97a748
    0xc323f822
    0x42cecedc
    0xc336c271
    }

    dump_names = %w(
    screen.(0);
    screen.(1);
    screen.(2);

    screenz_dir.(0);
    screenz_dir.(1);
    screenz_dir.(2);

    screenx_dir.(0);
    screenx_dir.(1);
    screenx_dir.(2);

    screeny_dir.(0);
    screeny_dir.(1);
    screeny_dir.(2);

    viewpoint.(0);
    viewpoint.(1);
    viewpoint.(2);
)

    dumps.zip(dump_names).each do |dump, name|
      context "#{name} should be #{dump}" do
        step read_length: "io_length_word", read_data: dump.to_i(16), read_ready: 1
      end
    end
    step read_length: "io_length_byte", read_ready: 0
  end
end

