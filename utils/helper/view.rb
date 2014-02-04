require 'erb'

module Nemips::Utils
  module Helper
    class View

      # Public: convert template filepath from template file name
      #
      # template_name - The string represent the config file's filepath from 'utils/data'.
      def self.template_path(template_name)
        @template_path = "utils/templates/#{template_name}"
      end

      def initialize(template_path, view_helper)
        @template_path = template_path
        @view_helper = view_helper
      end

      def run
        return @content if @content
        erb = ERB.new(File.read(@template_path), nil, '-')
        @content = @view_helper.instance_eval { erb.result(binding) }
      end
    end
  end
end
