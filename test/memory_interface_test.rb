VhdlTestScript.scenario "../src/memory_interface.vhd" do
  dependencies "../src/const/*.vhd"

  ports :address_in, :memory_in, :write_data, :write_enable, :read_data,
    :write_out, :write_out_data, :address_out
  clock :clk

  step 0x00000000, _, 0x12345678, 1, _, 1, 0x12345678, 0x00000000
  step 0x00000000, _, 0,          0, _, 0, _, _
  step 0xffffffff, _, 0,          0, _, 0, _, _

end
