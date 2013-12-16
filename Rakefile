
task :default => [:typedef, :const, :record, :path_ctl, :decoder, :lib]

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
end

desc "run test"
task :test do
  testfiles = Dir::glob("./test/**/*_test*.rb").to_a
  sh "vhdl_test_script #{testfiles.join(" ")}"
end

desc "generate record packages"
task :record do
  Dir::glob("./utils/data/states/*.yml").each do |f|
    sh "ruby ./utils/record_maker.rb #{f} > ./src/const/record_#{File.basename(f, ".*")}.vhd"
  end
end

desc "generate opcode decoders"
task :decoder do
  Dir::glob("./utils/data/order/order.yml").each do |f|
    %w(exec write_back).each do |name|
      sh "ruby ./utils/decoder_maker.rb #{f} #{name} > ./src/decoder/#{name}_state_decoder.vhd"
    end
  end
end

desc "generate instruction ram"
task :instram, 'asm_name'
task :instram do |t, args|
  require "./utils/inst_ram_maker.rb"

  asmfile = Dir::glob("./test/asm/#{args['asm_name']}.s").first
  InstRam.from_asm_to_vhdl(asmfile, "./lib/inst_ram.vhd")
end



