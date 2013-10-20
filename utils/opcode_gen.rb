#!/usr/bin/env ruby
# encoding: UTF-8
require "erb"
require "yaml"
require 'trollop'

class OpcodeGenerator
  attr_reader :content

  def initialize(yaml_path, templete_path)
    yaml = YAML.load(File.read yaml_path)
    erb = ERB.new(File.read(templete_path), nil, "-")
    @package_name = "const_" + File.basename(yaml_path, ".*")

    @descs = yaml.map do |key, value|
      ConstDescription.new(value, key)
    end
    @content =  erb.result(binding)
  end

  def self.run(yaml_path, templete_path)
    gen = new(yaml_path, templete_path)
    print gen.content
    gen
  end
end

class ConstDescription
  attr_reader :opcodes, :num_of_digits, :key_length
  def initialize(hsh, key)
    @opcodes = Hash.new
    @name = key
    if hsh["subtype"]
      @subtype_frag = true
      hsh.delete("subtype")
    end
    hsh.each do |name, num|
      @opcodes["#{key}_#{name}"] = num
    end

    @num_of_digits = hsh.max {|a, b| a[1] <=> b[1] }[1].to_s(2).length
    @key_length = hsh.max {|a, b| a[0].length <=> b[0].length}[0].length +
      key.length + 3

  end

  def has_subtype?
    @subtype_frag
  end

  def subtype_name
    @name + "_type"
  end
end

default_templete_path = File.expand_path("../templetes/opcode.vhd.erb", __FILE__)

unless ARGV.size >= 1
  $stderr.puts "Usage: opcode_gen YAML_PATH"
  exit 1
end

opts = Trollop::options do
  opt :templete, "Templete file.", type: :string, default: default_templete_path
end


OpcodeGenerator.run(ARGV[0], opts[:templete])

