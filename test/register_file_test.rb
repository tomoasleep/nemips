RegisterFileTest.dsl do
  assign :a1, :a2, :a3, :rd1, :rd2, :wd3, :we3
  clock :clk

  step 1, 1, 1, 12, 12, 12, 1
  step 1, 1, 1, 12, 12, 12, 0
  step 1, 2, 2, 12, 23, 23, 1
  step 0, 2, 1,  0, 23, 23, 0
  step 1, 0, 0, 12,  0,  0, 1

end
