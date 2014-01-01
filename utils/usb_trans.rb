require 'serialport'
require_relative './inst_ram_maker'

class UsbTranslator
  def initialize
    @serialio = SerialPort.new("/dev/ttyUSB0", 115200, 8, 1, 0)
  end

  def send_asm_file(asm_path)
    @instram = InstRam.from_asm_path(asm_path)
    send(*(@instram.instructions), -1)
  end

  def send_file(path)
    content = File
      .open(path, "rb")
      .each_byte
      .each_slice(4)
      .map{ |l| l.inject {|r, i| (r << 8) + i }}
    send(*(content), -1)
  end

  def send(*data)
    data.each do |d|
       send_word d
    end
  end

  def send_word(word)
    word = 2 ** 32 + word if word < 0
    4.times do |i|
      send_byte (word >> (i * 8)) & 0xff
    end
  end

  def send_byte(byte)
    @serialio.putc(byte & 0xff)
  end
end

UsbTranslator.new.send_asm_file(ARGV[0])

