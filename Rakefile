task :create_gen do
  Dir::glob("./utils/data/*").each do |f|
    sh "ruby ./utils/opcode_gen.rb #{f} > ./src/const/const_#{File.basename(f, ".*")}.vhd"
  end
end

task :test do
  Dir::glob("./test/*").each do |f|
    sh "vhdl_test_script #{f}"
  end
end
