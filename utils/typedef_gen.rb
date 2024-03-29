#!/usr/bin/env ruby
# encoding: UTF-8
require "erb"
require "yaml"
require 'trollop'

class TypedefGenerator
  attr_reader :content

  def initialize(yaml_path, template_path)
    yaml = YAML.load(File.read yaml_path)
    template = ERB.new(File.read(template_path), nil, "-")

    @package_name = "typedef_" + File.basename(yaml_path, ".*")

    @definitions = yaml.map do |name, length|
      TypeDifinition.new(name, length)
    end

    @content = template.result(binding)
  end

  def self.run(yaml_path, template_path)
    gen = new(yaml_path, template_path)
    print gen.content
    gen
  end
end

class TypeDifinition
  attr_reader :typename, :length
  def initialize(name, length)
    @name = name
    @length = length
  end

  def typename
    "#{@name}_type"
  end
end

default_template_path = File.expand_path("../templates/typedef.vhd.erb", __FILE__)

unless ARGV.size >= 1
  $stderr.puts "Usage: typedef_gen YAML_PATH"
  exit 1
end

opts = Trollop::options do
  opt :template, "template file.", type: :string, default: default_template_path
end


TypedefGenerator.run(ARGV[0], opts[:template])

