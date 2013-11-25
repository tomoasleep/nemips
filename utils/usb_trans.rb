require 'serialport'
require './inst_ram_maker'

class UsbTranslater
  def initialize
    @serialio = SerialPort.new("/dev/ttyUSB0", 9600, 8, 1, 0)
  end

  def send_asm_file(asm_path)
    @instram = InstRam.from_asm_path(asm_path)
    send *@instructions.instructions, -1
  end

  def send(*data)
    data.each do |d|

    end
  end

  def send_word(word)
    word = 2 ** 32 + word if word < 0
    4.times do |byte|
      send_byte (byte >> (i * 8)) & 0xff
    end
  end

  def send_byte(word)
    @serialio.putc byte & 0xff
  end
end

