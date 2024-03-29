#!/usr/bin/env ruby
require "erb"
require "yaml"
require_relative "./state_ctl_helper"

# TODO refactor yaml parser
class RecordMaker
  def self.run(yaml_path, template_path)
    new(yaml_path).to_vhdl(template_path)
  end

  def initialize(yaml_path)
    yaml = YAML.load(File.read yaml_path)
    NemipsState.load_definetions(yaml)

    @states = yaml["states"].map do |key, value|
      NemipsState.new(key, yaml["default"].merge(value || {}))
    end

    @record_name = @package_name =
      "record_" + File.basename(yaml_path, ".*")
    @fields = NemipsState.types.keys.map {|k| [k, NemipsState.typeformat(k)] }
  end

  def to_vhdl(template_path)
    erb = ERB.new(File.read(template_path), nil, "-")
    erb.result(binding)
  end

  def defs
    erb = ERB.new(File.read(File.expand_path(
      "../templates/record_def.vhd.erb", __FILE__)), nil, "-")
    erb.result(binding)
  end

  def body
    erb = ERB.new(File.read(File.expand_path(
      "../templates/record_body.vhd.erb", __FILE__)), nil, "-")
    erb.result(binding)
  end
end

unless ARGV.size == 1
  $stderr.puts "Usage: record_maker YAML_PATH"
  exit 1
end

puts RecordMaker.run(ARGV[0], File.expand_path("../templates/package.vhd.erb", __FILE__))
