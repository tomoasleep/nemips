require_relative "./test_helper"
VhdlTestScript.scenario "../src/rs232c/io_controller.vhd" do
  wait_time = 0xf

  # write
  dependencies "../src/const/const_io.vhd", "../src/rs232c/*.vhd"
  ports :write_data, :write_length, :read_length, :write_data_ready

  clock :clk
  generics wtime: wait_time

  test_tx = [0xffffffff, 0x12345678]

  test_tx.each do |n|
    step n, "io_length_word", "io_length_none", 1
    step _, "io_length_none", _, 0
    wait_step wait_time / 2

    n.split_byte.each do |m|
      output_expect = (m | 2 ** 8) << 1
      10.times do |i|
        step rs232c_out: output_expect.bit_range(i, i)
        wait_step wait_time
      end
    end
    step rs232c_out: 1
  end

  # read
  ports :read_length, :read_data, :read_data_ready, :rs232c_in

  test_rx = [0x55aa55aa, 0x87654321]

  step 0, _, _, 1

  test_rx.each do |n|
    n.split_byte.each do |m|
      send_data = [0, *m.to_logic_vector(8), 1]
      send_data.each do |j|
        step rs232c_in: j
        wait_step wait_time
      end
    end
    wait_step wait_time / 2
    step "io_length_word", n, 1, _
    step "io_length_none", _, _, _
  end

  step "io_length_word", _, 0, _
end

require_relative "./test_helper"
VhdlTestScript.scenario "../src/rs232c/io_controller.vhd" do
  wait_time = 0xf

  # write
  dependencies "../src/const/const_io.vhd", "../src/rs232c/*.vhd"
  ports :write_data, :write_length, :read_length, :write_data_ready

  clock :clk
  generics wtime: wait_time

  test_tx = [0x77775555, 0x9abcdef0]

  test_tx.each do |n|
    step n, "io_length_byte", "io_length_none", 1
    step _, "io_length_none", _, 0
    wait_step wait_time / 2

    [n.bit_range(7, 0)].each do |m|
      output_expect = (m | 2 ** 8) << 1
      10.times do |i|
        step rs232c_out: output_expect.bit_range(i, i)
        wait_step wait_time
      end
    end
    step rs232c_out: 1
  end

  test_tx = [0xaaaabbbb, 0x9abcdef0]

  test_tx.each do |n|
    step n, "io_length_halfword", "io_length_none", 1
    step _, "io_length_none", _, 0
    wait_step wait_time / 2

    [n.bit_range(7, 0), n.bit_range(15, 8)].each do |m|
      output_expect = (m | 2 ** 8) << 1
      10.times do |i|
        step rs232c_out: output_expect.bit_range(i, i)
        wait_step wait_time
      end
    end
    step rs232c_out: 1
  end
end
