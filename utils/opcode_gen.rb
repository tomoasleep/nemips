require "erb"
require "yaml"

@opcodes = Hash.new
yaml = (YAML.load(File.read File.expand_path("../data/opcode.yml", __FILE__)))
yaml.each { |k, v| v.each { |name, num| @opcodes["#{k}_#{name}"] = num }}
erb = ERB.new(File.read File.expand_path("../templetes/opcode.vhd.erb", __FILE__))
print erb.result(binding)


