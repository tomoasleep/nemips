require "erb"
require "yaml"

@opcodes = (YAML.load(File.read File.expand_path("../data/opcode.yml", __FILE__)))["r_op"]
erb = ERB.new(File.read File.expand_path("../templetes/opcode.vhd.erb", __FILE__))
print erb.result(binding)


