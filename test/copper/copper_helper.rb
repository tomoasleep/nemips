require_relative '../test_helper'

FMUL_PATHES = ['fpu/yasuda/hardware/FMUL/fmul.vhd',
               'fpu/yasuda/hardware/FMUL/exception_handler.vhd']
  .map { |pa| Dir[pa] }
FADD_PATHES = ['fpu/nemunemu/fadd/*.vhd']
  .map { |pa| Dir[pa] }
FINV_PATHES = ['fpu/nobita/fpu/VHDL/*.vhd']
  .map { |pa| Dir[pa] }

dirs = FMUL_PATHES + FADD_PATHES + FINV_PATHES + Dir['src/**/*.vhd'] + Dir['test/copper/tb/*.vhd']
files = dirs.flatten
files.map { |path| Copper.load_vhdl(File.expand_path(path)) }

