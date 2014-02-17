require_relative '../test_helper'

Dir['src/**/*.vhd'].map { |path| Copper.load_vhdl(File.expand_path(path)) }
