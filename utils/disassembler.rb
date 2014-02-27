require_relative './inst_ram_maker'
require_relative 'inst_analyzer'
require "yaml"


puts InstAnalyzer.from_bin_file(ARGV[0]).disassemble
