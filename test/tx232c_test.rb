require_relative "./test_helper"
VhdlTestScript.scenario "../src/rs232c/tx232c.vhd" do
  ports :tx, :data, :go, :ready
  clock :clk
  generics wtime: 0x0010

  wait_time = 0x0010
  io_test_int = [0xff, 0xaa, 0x65, 0x45, 0]
  io_test_back = [_, *io_test_int]

  step _, 0, 0, 1

  io_test_int.each_with_index do |n, idx|
    recv_data = [0, *n.to_logic_vector(8), 1]

    step {
      assign data: n, go: 1
      assert_after ready: 0, tx: recv_data.first
    }

    recv_data[1..-1].each do |j|
      wait_step wait_time
      step {
        assign go: 0
        assert_after ready: 0, tx: j
      }
    end

    wait_step wait_time
    step 1, _, _, 1
  end

end

