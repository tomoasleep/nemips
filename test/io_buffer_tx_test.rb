require_relative "./test_helper"

VhdlTestScript.scenario "../src/rs232c/io_buffer_tx.vhd" do
  dependencies "../src/const/const_io.vhd"
  ports :input, :enqueue_length, :dequeue,
    :output, :dequeue_ready, :enqueue_done
  clock :clk

  BufferSize = 32

  step 0x12345678, "io_length_word", 0, _, 0, 1
  context 'buffer moving data' do
    step _,          "io_length_none", 0, _, 0, _
  end
  context 'buffer output contents' do
    step _,          "io_length_none", 1, 0x78, 1, 0
    step _,          "io_length_none", 1, 0x56, 1, 0
    step _,          "io_length_none", 1, 0x34, 1, 0
    step _,          "io_length_none", 1, 0x12, 1, 0
  end

  step _, "io_length_none", 1, _, 0, 0

  step 0x123456ff, "io_length_byte", 0, _, 0, 1
  context('buffer moving data') { step _, "io_length_none", 0, _, 0, _ }
  context('buffer output contents') { step _, "io_length_none", 1, 0xff, 1, 0 }

  step _, "io_length_none", 1, _, 0, 0

  context "write data to limit (#{BufferSize})" do
    context 'can enqueue' do
      BufferSize.times { |i| step i, "io_length_word", 0, _, 0, 1 }
    end
    context 'cannot enqueue because full' do
      step 0x12345678, "io_length_word", 0, _, 0, 0
    end
  end


end
