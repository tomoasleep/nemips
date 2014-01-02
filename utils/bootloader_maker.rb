require_relative './inst_ram_maker.rb'

class Bootloader < InstRam
  def inst_template_path
    File.expand_path("../templetes/bootloader_inst.vhd.erb", __FILE__)
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
end
