require "erb"
require "tmpdir"
require "fileutils"

class InstRam
  class << self
    def from_asm(asm)
      tmpdir = Dir.mktmpdir
      asm_path = File.join(tmpdir, "asm.s")
      File.open(asm_path, "w") { |f| f << asm }
      from_asm_path(asm_path, tmpdir)
    end

    def from_asm_path(asm_path, tmpdir = nil)
      tmpdir ||= Dir.mktmpdir

      asm_path_tmpdir = File.join(tmpdir, File.basename(asm_path))
      bin_path = File.join(tmpdir, File.basename(asm_path, ".*"))
      FileUtils.copy(asm_path, asm_path_tmpdir) unless File.exist?(asm_path_tmpdir)

      raise unless system("#{assembler} -a -o #{bin_path} #{asm_path_tmpdir}")
      io = File.open(bin_path, "rb")
      codes = io.each_byte.each_slice(4).map{ |l| l.inject {|r, i| (r << 8) + i }}
      new(codes, tmpdir)
    end

    def from_asm_to_vhdl(from, to)
      FileUtils.copy(from_asm_path(from).make_vhdl, to)
    end

    def assembler
      ENV['NEMIPS_ASSEMBLER'] || "nemips_asm"
    end
  end

  attr_reader :instructions
  def initialize(codes, tmpdir = nil)
    @instructions = codes
    @tmpdir = tmpdir
  end

  def path
    @path ||= make_vhdl
  end

  def make_vhdl
    file_path = File.join(tmpdir, "inst_ram.vhd")
    erb = ERB.new(File.read(File.expand_path("../templates/inst_ram.vhd.erb", __FILE__)))
    File.open(file_path, "w") do |f|
      f << render_erb(erb) { |pth| ERB.new(File.read(pth)).result(binding) }
    end
    file_path
  end

  def render_erb(erb)
    erb.result(binding)
  end

  def tmpdir
    @tmpdir ||= Dir.mktmpdir
  end

  def inst_template_path
    File.expand_path("../templates/inst_ram_inst.vhd.erb", __FILE__)
  end

  def data_max
    10
  end
end
