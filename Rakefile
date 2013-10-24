task :const do
  Dir::glob("./utils/data/*").each do |f|
    sh "ruby ./utils/opcode_gen.rb #{f} > ./src/const/const_#{File.basename(f, ".*")}.vhd"
  end
end

task :test do
  Dir::glob("./test/*").each do |f|
    sh "vhdl_test_script #{f}"
  end
end

task :lib do
  Dir::glob("./src/const/*").each do |f|
    sh "ghdl -a --workdir=lib #{f}"
  end
end
