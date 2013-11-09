VhdlTestScript.scenario "../src/state_go_selector.vhd" do
  dependencies "../src/const/const_mux.vhd"

  ports :mem_read_ready, :io_write_ready, :io_read_ready, :go_src, :go

  step 1, 0, 0, "go_src_mem_read", 1
  step 0, 1, 0, "go_src_io_write", 1
  step 0, 0, 1, "go_src_io_read", 1
  step 0, 0, 0, "go_src_ok", 1

end
