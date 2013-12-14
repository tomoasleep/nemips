#!/usr/bin/env ruby
require "erb"
require "yaml"
require_relative "./state_ctl_helper"

# TODO refactor yaml parser
class StateCtlMaker

  class << self
    def run(path)
      fullpath = File.expand_path(path)
      @entity_name = File.basename(path, '.*')

      templete_path = File.expand_path("../templetes/path_controller.vhd.erb", __FILE__)
      yaml = YAML.load(File.read(fullpath))

      @record_name = "record_#{File.basename(fullpath, '.*')}"

      NemipsState.load_definetions(yaml)

      @states = yaml["states"].map { |k, v| NemipsState.new(k, v || {}) }
      @ports = yaml["types"].keys.map { |k|
        Port.new(k, NemipsState.typeformat(k.to_sym)) }

      @dependencies = yaml["settings"]["dependencies"]
      initial_state_name = yaml["settings"]["initial_state"]
      @initial_state = @states.find { |state| state.original_name == initial_state_name }

      @state_name = NemipsState.state_prefix
      @type_name = "#{@state_name}_type"

      erb = ERB.new(File.read(templete_path), nil, "-")
      erb.result(binding)
    end
  end

  class Port
    attr_reader :name, :type
    def initialize(name, type)
      @name = name
      @type = type
    end
  end
end

puts StateCtlMaker.run(ARGV[0])
