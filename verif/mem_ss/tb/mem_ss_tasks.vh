
//=======================================================
//=======================================================
task delay(input int cycles);
  for(int i =0; i< cycles; i++) begin
    @(posedge clk);
  end
endtask

task dmem_wr_req( input logic [19:0] address, 
                  input logic [31:0] data ,
                  input logic [4:0]  id );
    static int count =0;
    while (~dmem_ready) begin
      delay(1); $display("-> not ready! cant send write: %h ", address );
      count++;
      if(count > 100) begin
        $display("-> not ready! cant send write request: %h ", address );
        eot("ERROR: dmem_wr_req: not ready for 100 cycles!");
      end
    end
    $display("dmem_wr_req: %h , address %h:", id, address);
    dmem_core2cache_req.valid   =  1'b1;
    dmem_core2cache_req.opcode  =  WR_OP;
    dmem_core2cache_req.address =  address;
    dmem_core2cache_req.data    =  data;
    dmem_core2cache_req.reg_id  =  id;
    delay(1); 
    dmem_core2cache_req     = '0;
endtask

task dmem_rd_req( input logic [19:0] address,
                  input logic [4:0] id); 
    static int count =0;
    while (~dmem_ready) begin
      delay(1); $display("-> not ready! cant send write: %h ", address );
      count++;
      if(count > 100) begin
        $display("-> not ready! cant send read request: %h ", address );
        eot("ERROR: dmem_rd_req: not ready for 100 cycles!");
      end
    end
    $display("dmem_rd_req: %h , address %h:", id, address);
    dmem_core2cache_req.valid   =  1'b1;
    dmem_core2cache_req.opcode  =  RD_OP;
    dmem_core2cache_req.address =  address;
    dmem_core2cache_req.reg_id  =  id;
    delay(1);
    dmem_core2cache_req     = '0;
endtask

task eot(input string msg);
  $display("END-OF-TEST Message: %s =\n", msg);
  $finish;
endtask 