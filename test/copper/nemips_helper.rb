require_relative '../asm_helper'
require_relative '../nemips/bootloader_helper'

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

  def bootloader
    code = File.read(pfr('test/asm/bootloader.s'))
    @before = proc do
      path = Bootloader.from_asm(code).make_vhdl(@dir)
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

module InstructionSend
  def write_insts_from_asm(inst_str)
    write_insts InstRam.from_asm(inst_str).instructions
  end

  def write_insts(insts)
    dut = @dut
    context 'write instruction' do
      step {
        assign dut.write_length => 'io_length_none'
      }
      [*insts, -1].each do |i|
        step {
          assign dut.write_length => 'io_length_word'
          assign dut.write_data => i
        }
        step {
          assign dut.write_length => 'io_length_none'
          assign dut.write_data => 0
        }
        wait_for 100
      end
      wait_for 60
    end
  end

  def check(insts)
    dut = @dut
    context 'read instruction' do
      step {
        assign dut.read_length => 'io_length_none'
      }
      [*insts, -1].each do |i|
        step {
          assign dut.read_length => 'io_length_word'
          assert dut.read_data_past => i
        }
      end
      step {
        assign dut.read_length => 'io_length_none'
      }
    end
  end

  def write_data(insts)
    dut = @dut
    context 'write instruction' do
      step {
        assign dut.write_length => 'io_length_none'
      }
      [*insts, -1].each do |i|
        step {
          assign dut.write_length => 'io_length_word'
          assign dut.write_data => i
        }
        step {
          assign dut.write_length => 'io_length_none'
          assign dut.write_data => 0
        }
        wait_for 10
      end
      wait_for 120 * insts.length
    end
  end

end

