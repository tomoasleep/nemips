require_relative 'decoder_maker'

module Nemips::Utils
  class DecodeFunctionMaker < DecoderMaker
    def decorator_klass
      DecodeFunctionPresenter
    end
  end

  class DecodeFunctionPresenter < DecoderPresenter
    def function_name
      "decode_#{@stage}"
    end
  end

  class FunctionPackage
    TemplatePath = Helper::View.template_path('function_package.vhd.erb')

    def initialize(package_name, yaml_path, stages)
      @package_name = package_name
      @functions = stages.map do |stage_name|
        DecodeFunctionMaker.new(yaml_path, stage_name).tap { |func| func.run }.decorator
      end
    end

    def run
      Helper::View.new(TemplatePath, self).run
    end

    def definitions
      'decode_package_definitions.vhd.erb'
    end

    def body
      'decode_package_body.vhd.erb'
    end

    def functions
      @functions
    end

    def package_name
      @package_name
    end
  end
end
