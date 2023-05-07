
//=======================================================
task delay(input int cycles);
  for(int i =0; i< cycles; i++) begin
    @(posedge Clk);
  end
endtask