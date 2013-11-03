VhdlTestScript.scenario "tb/sram_tb.vhd" do
  dependencies  "../src/const/const_sram_cmd.vhd", "../src/sram/sram_controller.vhd",
    "../src/sram/sram_mock.vhd"

  ports :read_data, :write_data, :addr, :command, :read_ready
  clock :clk

  step  _, 10, 1, "sram_cmd_write", 0
  step  _,  _, _, "sram_cmd_none", 0
  step  _,  _, 1, "sram_cmd_read", 0
  step  _, 40, 1, "sram_cmd_write", 0
  step  _, 20, 2, "sram_cmd_write", 0
  step 10, 30, 3, "sram_cmd_write", 1
  step  _,  _, 1, "sram_cmd_read", 0
  step  _,  _, _, "sram_cmd_none", 0
  wait_step 1
  step 40,  _, 2, "sram_cmd_read", 1
  wait_step 2
  step 20,  _, _, "sram_cmd_read", 1
end

