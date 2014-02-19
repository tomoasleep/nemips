require_relative '../test_helper'

files = Dir['src/**/*.vhd'] + Dir['test/copper/tb/*.vhd']
files.map { |path| Copper.load_vhdl(File.expand_path(path)) }
