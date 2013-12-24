
require 'vhdl_connector'
require 'tempfile'

tf = Tempfile.new('connector')
tf << VhdlConnector.parse_connector(ARGV[0])
tf.close

str = ""
IO.popen("ghdl -s --workdir=lib --ieee=synopsys #{tf.path} 2>&1") do |r|
  str = r.read
end

STDERR.puts str

tf_array = tf.open.each_line.to_a

# str.split("\n").map { |line| str.split(":")[1] }
#   .compact.map(&:to_i)
#   .map { |i| STDERR.puts tf_array[(i - 5)..(i + 3)] }

str.split("\n").map { |line| [line, str.split(":")[1]] }
  .map { |line, i| STDERR.puts [line, tf_array[(i.to_i - 5)..(i.to_i + 3)]] }

tf.delete

