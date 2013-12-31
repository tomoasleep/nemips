module BootloaderHelper
  def inst_path
    InstRam.from_asm_path(pfr("test/asm/bootloader.s")).path
  end

  def write_insts_from_asm(inst_str)
    write_insts InstRam.from_asm(inst_str).instructions
  end

  def write_insts(insts)
    context 'write instruction' do
      step read_length: 'io_length_none'
      [*insts, -1].each do |i|
        step write_length: 'io_length_word', write_data: i
        step write_length: 'io_length_none', write_data: 0
        wait_step 60
      end
      wait_step 60
    end
  end
end

