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

      def initialize(template_path, view_helper, &partial_renderer)
        @template_path = template_path
        @view_helper = view_helper
        @original_partial_renderer = partial_renderer
        @partial_renderer = methodnize(partial_renderer)
      end

      def methodnize(block)
        case block
        when Proc, Method
          block
        when Symbol
          @view_helper.method(block)
        else
          self.method(:render_partial)
        end
      end

      def run
        return @content if @content
        erb = ERB.new(File.read(@template_path), nil, '-')
        @content = erb.result(context(&@partial_renderer))
      end

      private
      def context
        @view_helper.instance_eval { binding }
      end

      def render_partial(path, options = {})
        options = { as: @view_helper }.merge(options)
        self.class.new(
          self.class.template_path(path), options[:as], &@original_partial_renderer
        ).run
      end
    end
  end
end
