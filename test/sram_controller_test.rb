require_relative "./test_helper"
VhdlTestScript.scenario "../src/sram/sram_controller.vhd" do |dut|
  dependencies "../src/const/const_sram_cmd.vhd"

  clock :clk

  nums = [[12345678, 12345], [23456789, 23456],
          [87654321, 87654], [76543210, 76543],
          [43218765, 76584], [54327610, 65437]]
  reserve_nums = [*nums]
  write_nums = [[z, _], [z, _], *nums]

  context("write") {
    reserve_nums.each_with_index do |i, idx|
      rr = (idx > 1) ? 0 : _

      step {
        assign write_data: i.first, addr: i.last,
        command: "sram_cmd_write"
        assert_after dut.sram_data.out => write_nums[idx].first,
          sram_addr: reserve_nums[idx].last, sram_write_disable: 0,
          read_ready: rr
      }
    end

    step command: "sram_cmd_none", dut.sram_data.out => write_nums[-2].first,
      sram_write_disable: 1, read_ready: 0
  }

end

VhdlTestScript.scenario "../src/sram/sram_controller.vhd" do |dut|
  dependencies "../src/const/const_sram_cmd.vhd"

  clock :clk

  nums = [[12345678, 12345], [23456789, 23456],
          [87654321, 87654], [76543210, 76543],
          [43218765, 76584], [54327610, 65437]]
  reserve_nums = [*nums]
  read_nums = [[_, _], [_, _], [_, _], *nums]

  context("read") {
    reserve_nums.each_with_index do |i, idx|
      rr = (idx > 2) ? 1 : _

      step {
        assign addr: i.last, command: "sram_cmd_read",
        dut.sram_data.in => read_nums[idx].first
        assert_after sram_addr: reserve_nums[idx].last, sram_write_disable: 1,
          read_ready: rr, read_data: read_nums[idx].first
      }
    end

    step {
      assign command: "sram_cmd_read",
      dut.sram_data.in => read_nums[-2].first
      assert_after read_ready: 1, read_data: read_nums[-2].first
    }
  }
end
