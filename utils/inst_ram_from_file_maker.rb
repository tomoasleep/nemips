require_relative './inst_ram_maker'

module Nemips::Utils
  class InstRamFromFile
    class << self
      def from_asm(asm)
        tmpdir = Dir.mktmpdir
        asm_path = File.join(tmpdir, 'asm.s')
        File.write(asm_path, asm)
        from_asm_path(asm_path, tmpdir)
      end

      def from_asm_path(asm_path, tmpdir = Dir.mktmpdir)
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

    def initialize(codes, dir = nil)
      @codes = codes
      @tmpdir = dir
    end

    def save
      @circuit ||= Helper::View.new(Helper::View.template_path('inst_ram_from_file.vhd.erb'), self)
      @data ||= Helper::View.new(Helper::View.template_path('ram_init.data.erb'), self)
      @circuit.save('lib/inst_ram.vhd')
      @data.save(data_path)
    end

    def tmpdir
      @tmpdir ||= Dir.mktmpdir
    end

    def data_max
      10
    end

    def instructions
      @instructions ||= (2 ** data_max).times.map { |i| @codes[i] || 0 }
    end

    def data_path
      File.expand_path('lib/ram_init.data')
    end
  end
end
