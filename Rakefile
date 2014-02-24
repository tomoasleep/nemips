
task :default => [:typedef, :const, :record, :path_ctl, :decoder, :lib]

task :require do
  $LOAD_PATH.push(File.expand_path('.'))
end

desc "generate const packages"
task :const do
  Dir::glob("./utils/data/*.yml").each do |f|
    sh "ruby ./utils/opcode_gen.rb #{f} > ./src/const/const_#{File.basename(f, ".*")}.vhd"
  end
end

desc "generate typedef packages"
task :typedef do
  Dir::glob("./utils/data/typedef/*.yml").each do |f|
    sh "ruby ./utils/typedef_gen.rb #{f} > ./src/const/typedef_#{File.basename(f, ".*")}.vhd"
  end
end

desc "generate path controller"
task :path_ctl do
  Dir::glob("./utils/data/states/*.yml").each do |f|
    sh "ruby ./utils/path_ctl_maker.rb #{f} > ./src/state_ctl/#{File.basename(f, '.*')}.vhd"
  end
end

desc "compile const packages"
task :lib do
  Dir::glob("./src/const/const_*").each do |f|
    sh "ghdl -a --workdir=lib #{f}"
  end
  Dir::glob("./src/const/record_*").each do |f|
    sh "ghdl -a --workdir=lib #{f}"
  end
  Dir::glob("./src/const/typedef_*").each do |f|
    sh "ghdl -a --workdir=lib #{f}"
  end
  Dir::glob("./src/decoder/decode_*").each do |f|
    sh "ghdl -a --workdir=lib #{f}"
  end
  Dir::glob("./src/utils/*types.vhd").each do |f|
    sh "ghdl -a --workdir=lib #{f}"
  end
  Dir::glob("./src/utils/order_utils.vhd").each do |f|
    sh "ghdl -a --workdir=lib #{f}"
  end
  Dir::glob("./src/utils/pipeline_utils.vhd").each do |f|
    sh "ghdl -a --workdir=lib #{f}"
  end
end

desc "run test"
task :test do
  testfiles = Dir::glob("./test/**/*_test*.rb").to_a
  sh "vhdl_test_script #{testfiles.join(" ")} -t ~slow"
end

desc "generate record packages"
task :record do
  Dir::glob("./utils/data/states/*.yml").each do |f|
    sh "ruby ./utils/record_maker.rb #{f} > ./src/const/record_#{File.basename(f, ".*")}.vhd"
  end
end

desc "generate opcode decoders"
task :decoder => [:require] do
  require 'utils/decoder_maker'
  require 'utils/decode_function_maker'

  Dir::glob("./utils/data/order/order.yml").each do |f|
    stages = %w(exec memory write_back)
    stages.each do |name|
      File.write(
        "./src/decoder/#{name}_state_decoder.vhd",
        Nemips::Utils::DecoderMaker.new(f, name).run
      )
    end
    File.write(
      './src/decoder/decode_order_functions.vhd',
      Nemips::Utils::FunctionPackage.new(
        'decode_order_functions', f, stages
      ).run
    )
  end
end

desc "generate instruction ram"
task :instram, 'asm_name'
task :instram do |t, args|
  require "./utils/inst_ram_from_file_maker.rb"

  asmfile = Dir::glob("./test/asm/#{args['asm_name']}.s").first
  Nemips::Utils::InstRamFromFile.from_asm_path(asmfile).save
end

desc "generate instruction ram"
task :bootloader do |t, args|
  require "./utils/bootloader_maker.rb"

  Bootloader.from_asm_to_vhdl('./test/asm/bootloader.s', "./lib/inst_ram.vhd")
end



