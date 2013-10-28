require_relative "./test_helper"

VhdlTestScript.scenario "../src/rs232c/io_buffer_tx.vhd" do
  dependencies "../src/const/const_io.vhd"
  ports :input, :enqueue_length, :dequeue, :output, :ready
  clock :clk

  step 0x12345678, "io_length_word", 0, _, 0
  step _,          "io_length_none", 1, 0x78, 1
  step _,          "io_length_none", 1, 0x56, 1
  step _,          "io_length_none", 1, 0x34, 1
  step _,          "io_length_none", 1, 0x12, 1

  step _, "io_length_none", 1, _, 0

  step 0x123456ff, "io_length_byte", 0, _, 0
  step _,          "io_length_none", 1, 0xff, 1

  step _, "io_length_none", 1, _, 0

end
