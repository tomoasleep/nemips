require_relative "./test_helper"
VhdlTestScript.scenario "../src/sram/sram_mock.vhd" do |dut|

  ports dut.data.in, dut.data.out, dut.address, dut.we
  clock dut.clk
  nz = z

  step z, _, 1, 1
  step _, _, _, 0
  step 12, _, 1, 0
  step z, 12, 1, 0
  wait_step 2

  step  z, _, 2, 1
  step  z, _, 1, 0
  step 38, _, 2, 0
  step do
    assign dut.data.in => z
    assert_before dut.data.out => 12
  end
  step  z, _, 1, 0
  wait_step 3

  step  z, _, 2, 0
  step  z, 38, 2, 1
  step  _,  _, 2, 0
  step  12,  _, 2, 0
  step  z,  12, 2, 0
  wait_step 2

  step  z, _, 8, 0
  step  z, _, 8, 1
  step  _,  _, 8, 0
  step  20,  _, 8, 0
  step  z,  20, 8, 0
  wait_step 2
end
