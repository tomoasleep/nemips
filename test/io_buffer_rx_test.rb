require_relative "./test_helper"

VhdlTestScript.scenario "../src/rs232c/io_buffer_rx.vhd" do
  dependencies "../src/const/const_io.vhd"
  ports :input, :enqueue, :dequeue_length, :output, :ready
  clock :clk

  step 0x78, 1, "io_length_none", _, 0
  step 0x56, 1, "io_length_none", _, 0
  step 0x34, 1, "io_length_none", _, 0
  step 0x12, 1, "io_length_none", _, 0
  step    _, 0, "io_length_word", 0x12345678, 1

  step    _, 0, "io_length_word", _, 0

  step 0xaa, 1, "io_length_none", _, 0
  step 0xff, 1, "io_length_none", _, 0
  step    _, 0, "io_length_halfword", 0x0000ffaa, 1

  step 0xee, 1, "io_length_none", _, 0
  step    _, 0, "io_length_byte", 0x000000ee, 1

  step    _, 0, "io_length_byte", _, 0

  step 0x78, 1, "io_length_none", _, 0
  step 0x56, 1, "io_length_none", _, 0
  step 0x34, 1, "io_length_none", _, 0
  step 0x12, 1, "io_length_none", _, 0
  step    _, 0, "io_length_byte", 0x78, 1
  step    _, 0, "io_length_byte", 0x56, 1
  step    _, 0, "io_length_byte", 0x34, 1
  step    _, 0, "io_length_byte", 0x12, 1

  step 0x78, 1, "io_length_none", _, 0
  step    _, 0, "io_length_byte", 0x78, 1
  step 0x56, 1, "io_length_none", _, 0
  step    _, 0, "io_length_byte", 0x56, 1
  step 0x34, 1, "io_length_none", _, 0
  step    _, 0, "io_length_byte", 0x34, 1
  step 0x12, 1, "io_length_none", _, 0
  step    _, 0, "io_length_byte", 0x12, 1

  step 0x78, 1, "io_length_none", _, 0
  step    _, 0, "io_length_word", _, 0
  step 0x56, 1, "io_length_none", _, 0
  step    _, 0, "io_length_word", _, 0
  step 0x34, 1, "io_length_none", _, 0
  step    _, 0, "io_length_word", _, 0
  step 0x12, 1, "io_length_none", _, 0
  step    _, 0, "io_length_word", 0x12345678, 1
end
