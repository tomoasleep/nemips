require_relative 'helper'

class Integer
  def to_binary(length=2)
    "\"#{(2**length + self).to_s(2)[-length..-1]}\""
  end

  def to_logic_vector(length)
    self.to_s(2).rjust(length, '0').unpack("C*").map{|i| i - 48}.reverse
  end

  def bit_range(max, min)
    (self >> min) & (2 ** (max - min + 1) - 1)
  end

  def bit_filter(max, min, num)
    (self - (bit_range(max, min) << min)) | (num << min).bit_range(max, min)
  end
end

module InstAnalyzer
  class << self
    include InstAnalyzer
  end

  def from_bin_file(path)
    io = File.open(path, "rb")
    codes = io.each_byte.each_slice(4).map{ |l| l.inject {|r, i| (r << 8) + i }}
    NemipsBinary.new(codes)
  end

  def from_array(ary)
    NemipsBinary.new(ary)
  end

  class NemipsBinary < InstRam
    def disassemble
      instobjs
        .each_with_index
        .map { |i, idx| "#{i.format}\t# #{idx}" }
        .join("\n")
    end

    def instobjs
      @instobjs ||=  @instructions.map { |inst| NemipsInstBinary.new(inst).parsed_inst }
    end
  end

  class NemipsDictionary
    def initialize
      dict_path = Nemips::Utils::Helper::ConfigReader.config_path('opcode.yml')
      @dict = YAML.load_file(dict_path)
    end

    def parse_binary(inst)
      case find_group(inst)
      when :r_group
        RopInstruction
      when :zimm_group
        ZeroImmInstruction
      when :simm_group
        SignImmInstruction
      when :f_group
        FopInstruction
      when :j_group
        JopInstruction
      when :mem_group
        MemoryInstruction
      when :io
        IOopInstruction
      end.new(inst)
    end

    def find_name(inst)
      case find_group(inst)
      when :f_group
        find_f_op(inst)
      when :r_group
        find_r_op(inst)
      when :zimm_group, :simm_group, :mem_group
        find_i_op(inst)
      when :j_group
        find_j_op(inst)
      when :io
        find_io_op(inst)
      end
    end

    def find_group(inst)
      case opcode_name = main_dictionary[inst.opcode].to_sym
      when :f_group, :io, :r_group
        opcode_name
      when :j, :jal
        :j_group
      when :sw, :lw, :sprogram, :swf, :lwf
        :mem_group
      when :addiu, :sltiu, :andi, :ori, :xori, :lui
        :zimm_group
      else
        :simm_group
      end
    end

    def find_i_op(inst)
      main_dictionary[inst.opcode]
    end

    def find_r_op(inst)
      r_op_dictionary[inst.funct]
    end

    def find_f_op(inst)
      f_op_dictionary[inst.funct]
    end

    def find_j_op(inst)
      main_dictionary[inst.opcode]
    end

    def find_io_op(inst)
      io_op_dictionary[inst.funct]
    end

    private
    def main_dictionary
      @main_dictionary ||= @dict['i_op'].merge(@dict['j_op']).invert
    end

    def r_op_dictionary
      @r_op_dictionary ||= @dict['r_fun'].invert
    end

    def f_op_dictionary
      @f_op_dictionary ||= @dict['f_fun'].invert
    end

    def io_op_dictionary
      @io_op_dictionary ||= @dict['io_fun'].invert
    end
  end

  class NemipsInstBinary
    class << self
      def dictionary
        @dictionary ||= NemipsDictionary.new
      end
    end

    attr_reader :bin
    def initialize(bin)
      @bin = bin
    end

    def dictionary
      self.class.dictionary
    end

    def name
      @name ||= dictionary.find_name(self)
    end

    def parsed_inst
      dictionary.parse_binary(self)
    end

    ops = [
      [:opcode, 31, 26],
      [:rs,     25, 21],
      [:rt,     20, 16],
      [:rd,     15, 11],
      [:shamt,  10,  6],
      [:funct,   5,  0],
      [:imm,    15,  0],
      [:addr,   25,  0],
    ]
    ops.each do |name, left, right|
      define_method(name) { bin.bit_range(left, right) }
      define_method("#{name}=") { |i| @bin = @bin.bit_filter(left, right, i) }
    end

    def sign_imm
      bin.bit_range(14, 0) - (bin.bit_range(15, 15) << 15)
    end
  end

  class BaseInstruction
    attr_reader :inst
    def initialize(instbin)
      @inst = instbin
    end

    def to_s
      "#{inst.name}\t#{rd},\t#{rs},\t#{rt},\t#{inst.shamt}"
    end

    def rs; "#{rs_mark}#{inst.rs}"; end
    def rt; "#{rt_mark}#{inst.rt}"; end
    def rd; "#{rd_mark}#{inst.rd}"; end

    def rs_mark; 'r'; end
    def rt_mark; 'r'; end
    def rd_mark; 'r'; end

    def format
      to_s
    end
  end

  class RopInstruction < BaseInstruction; end
  class IOopInstruction < BaseInstruction; end

  class FopInstruction < BaseInstruction
    def to_s
      "#{inst.name}\t#{rd},\t#{rs},\t#{rt}"
    end

    def format
      "#{to_s}\t"
    end

    def rs_mark; 'f'; end
    def rt_mark; 'f'; end
    def rd_mark
      %w(fcseq fclt fcle).member?(inst.name) ? 'r' : 'f'
    end

  end

  class MemoryInstruction < BaseInstruction
    def to_s
      "#{inst.name}\t#{inst.sign_imm.to_s}(#{rs}),  \t#{rt}"
    end

    def rt_mark
      %w(lwf swf).member?(inst.name) ? 'f' : 'r'
    end


    def format
      "#{to_s}\t"
    end
  end

  class JopInstruction < BaseInstruction
    def to_s
      "#{inst.name}\t#{inst.addr.to_s.ljust(8)}"
    end

    def format
      "#{to_s}\t\t"
    end
  end

  class ZeroImmInstruction < BaseInstruction
    def to_s
      "#{inst.name}\t#{rt},\t#{rs},\t#{inst.imm}"
    end

    def format
      "#{to_s}\t"
    end
  end

  class SignImmInstruction < BaseInstruction
    def to_s
      "#{inst.name}\t#{rt},\t#{rs},\t#{inst.sign_imm}"
    end

    def rt_mark
      %w(imvf).member?(inst.name) ? 'f' : 'r'
    end

    def rs_mark
      %w(fmvi).member?(inst.name) ? 'f' : 'r'
    end

    def format
      "#{to_s}\t"
    end
  end
end
