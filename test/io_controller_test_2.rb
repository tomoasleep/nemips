require_relative "./test_helper"
VhdlTestScript.scenario "../src/rs232c/io_controller.vhd" do
  wait_time = 0xf
  clock :clk
  generics wtime: wait_time

  # read
  dependencies "../src/const/const_io.vhd", "../src/rs232c/*.vhd"
  ports :read_length, :read_data, :read_data_ready, :rs232c_in

  test_rx = [0x55555555, 0x87654321]

  step 0, _, _, 1

  test_rx.each do |n|
    n.split_byte.each_with_index do |m, i|
      send_data = [0, *m.to_logic_vector(8), 1]
      send_data.each do |j|
        step rs232c_in: j
        wait_step wait_time
      end
      wait_step wait_time / 2
      step "io_length_byte", n.bit_range(8 * (i + 1) - 1, 8 * i), 1, _
      step "io_length_none", _, _, _
    end
  end

  step "io_length_word", _, 0, _
end

VhdlTestScript.scenario "../src/rs232c/io_controller.vhd" do
  wait_time = 0xf
  clock :clk
  generics wtime: wait_time

  # read
  dependencies "../src/const/const_io.vhd", "../src/rs232c/*.vhd"
  ports :read_length, :read_data, :read_data_ready, :rs232c_in

  test_rx = [0x55555555, 0x87654321]

  step 0, _, _, 1

  test_rx.each do |n|
    n.split_byte.each_with_index do |m, i|
      send_data = [0, *m.to_logic_vector(8), 1]
      send_data.each do |j|
        step rs232c_in: j
        wait_step wait_time
      end
      wait_step wait_time / 2
      if i % 2 == 1
        step "io_length_halfword", n.bit_range(8 * (i + 1) - 1, 8 * (i - 1)), 1, _
        step "io_length_none", _, _, _
      else
        step "io_length_halfword", _, 0, _
        step "io_length_none", _, _, _
      end
    end
  end

  step "io_length_word", _, 0, _
end
