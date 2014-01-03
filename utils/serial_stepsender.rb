require 'readline'
require 'serialport'

class Float
  def to_binary
    [self].pack("f").unpack("I").first
  end
end

serialio = SerialPort.new("/dev/ttyUSB0", 115200, 8, 1, 0)

while line = Readline.readline('> ', true)
  line.strip!
  str = if line.match('\.')
    line.to_f.to_binary
  elsif line.match('0x')
    line.to_i(16)
  elsif line.match('0b')
    line.to_i(2)
  else
    line.to_i(10)
  end
  4.times { |i| serialio.putc((str >> (i * 8)) & 0xff) }
  puts str.to_s(2).rjust(32, '0')
end

