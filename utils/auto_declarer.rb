require 'vhdl_connector'
require 'fileutils'

content = VhdlConnector.parse_connector(ARGV[0])
FileUtils.cp(ARGV[0], "#{ARGV[0]}.orig")
File.write(ARGV[0], content)

