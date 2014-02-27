require_relative './inst_ram_maker.rb'
require_relative './inst_analyzer'

class Bootloader < InstRam
  def inst_template_path
    File.expand_path("../templates/bootloader_inst.vhd.erb", __FILE__)
  end

  def bootloader_space
    100
  end

  def bootloader_start
    (2 ** data_max) - bootloader_space
  end

  def jump_to_bootloader
    "000010#{bootloader_start.to_s(2).rjust(26, '0')}"
  end

  def shift_jump(insts)
    InstAnalyzer.from_array(insts).instobjs.map do |inst|
      case inst
      when InstAnalyzer::JopInstruction
        instbin = inst.inst
        instbin.addr += bootloader_start
        instbin.bin
      else
        inst.inst.bin
      end
    end
  end
end
