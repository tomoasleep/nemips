require_relative '../asm_helper'

class NemipsTestRunner
  class << self
    def run(&block)
      @runner ||= new
      @runner.instance_eval(&block)
    end
  end

  def initialize
    @dir = Dir.mktmpdir
  end

  def assemble(code)
    path = InstRam.from_asm(code).make_vhdl(@dir)
    unless @added
      Copper.load_vhdl(path)
      @added = true
    end
  end

  def dut(&block)
    Copper::Scenario::Circuit.configure(:nemips_tb, &block)
  end
end

