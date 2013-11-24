#!/usr/bin/env ruby
require "erb"
require "yaml"
require_relative "./state_ctl_helper"

class StateCtlMaker

  class << self
    def run
      templete_path = File.expand_path("../templetes/path_controller.vhd.erb", __FILE__)
      yaml = YAML.load(
        File.read(File.expand_path("../data/states/state_ctl.yml", __FILE__)))

      NemipsState.load_definetions(yaml)

      @states = yaml["states"].keys
      @ports = yaml["types"].keys.map { |k|
        Port.new(k, NemipsState.typeformat(k.to_sym)) }
      @dependencies = yaml["settings"]["dependencies"]
      @initial_state = yaml["settings"]["initial_state"]

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

puts StateCtlMaker.run
