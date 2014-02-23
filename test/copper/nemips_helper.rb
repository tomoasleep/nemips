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
    @before = proc do
      path = InstRam.from_asm(code).make_vhdl(@dir)
      unless @added
        Copper.load_vhdl(path)
        @added = true
      end
    end
  end

  def binary(bin)
    path = InstRam.new(bin).make_vhdl(@dir)
    unless @added
      Copper.load_vhdl(path)
      @added = true
    end
  end

  def dut(&block)
    set_clock = proc do |dut|
      clock dut.clk
    end
    block = set_clock unless block
    Copper::Scenario::Circuit.configure(:nemips_tb, { before: @before }, &block)
  end
end

