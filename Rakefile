
task :default => [:const, :record, :lib]

desc "generate const packages"
task :const do
  Dir::glob("./utils/data/*.yml").each do |f|
    sh "ruby ./utils/opcode_gen.rb #{f} > ./src/const/const_#{File.basename(f, ".*")}.vhd"
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
end

desc "run test"
task :test do
  testfiles = Dir::glob("./test/**/*_test*.rb").to_a
  sh "vhdl_test_script #{testfiles.join(" ")}"
end

desc "generate record packages"
task :record do
  Dir::glob("./utils/data/states/*").each do |f|
    sh "ruby ./utils/record_maker.rb #{f} > ./src/const/record_#{File.basename(f, ".*")}.vhd"
  end
end

desc "generate instruction rom"
task :instrom, 'asm_name'
task :instrom do |t, args|
  require "./utils/inst_rom_maker.rb"

  asmfile = Dir::glob("./test/asm/#{args['asm_name']}.s").first
  InstRom.from_asm_to_vhdl(asmfile, "./lib/inst_rom.vhd")
end



