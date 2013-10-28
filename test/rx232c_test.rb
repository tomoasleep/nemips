require_relative "./test_helper"
VhdlTestScript.scenario "../src/rs232c/rx232c.vhd" do
  ports :rx, :ready, :data
  clock :clk
  generics wtime: 0x0010

  wait_time = 0x0010
  io_test_int = [0xff, 0xaa, 0x65, 0x45, 0]
  io_test_back = [_, *io_test_int]

  io_test_int.each_with_index do |n, idx|
    send_data = [0, *n.to_logic_vector(8)]
    send_data.each do |j|
      step j, _, io_test_back[idx]
      wait_step wait_time
    end

    step 1, _, _
    wait_step wait_time
  end

  step _, _, io_test_int[io_test_int.length - 1]
end

