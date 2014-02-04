require 'yaml'

module Nemips::Utils
  module Helper
    class ConfigReader

      # Public: convert config filepath from config file name
      #
      # config_name - The string represent the config file's filepath from 'utils/data'.
      def self.config_path(config_name)
        @config_path = "utils/data/#{config_name}"
      end

      # Public:
      #
      # config_name - The string represent the config file's filepath from 'utils/data'.
      # parser - The object to parse the content of config file.
      #          It must have `.configure(hash)` method to parse the content
      def initialize(config_path, parser)
        @config_path = config_path
        @parser = parser
      end

      def run
        @yaml = YAML.load(File.read(@config_path))
        @parser.configure(@yaml)
      end
    end
  end
end
