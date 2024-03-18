
//=======================================================
//=======================================================
task delay(input int cycles);
  for(int i =0; i< cycles; i++) begin
    @(posedge clk);
  end
endtask

// //=======================================================
// task backdoor_fm_load();
//   $display("= backdoor_fm_load start =\n");
//   for(int FM_ADDRESS =0; FM_ADDRESS < NUM_FM_CL ; FM_ADDRESS++) begin
//         back_door_fm_mem[FM_ADDRESS] = FM_ADDRESS + 'hABBA_BABA_0000_1111;
//         $display("backdoor_fm_load: %h ",back_door_fm_mem[FM_ADDRESS]);
//   end
//     force far_memory_array.mem  = back_door_fm_mem;
//     force cache_ref_model.mem  = back_door_fm_mem;
//     delay(5);
//     release far_memory_array.mem;
//     release cache_ref_model.mem;
//   $display("= backdoor_fm_load done =\n");
// endtask

//=======================================================

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

//=======================================================

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

//=======================================================

task imem_rd_req( input logic [19:0] address,
             input logic [4:0] id); 
    static int count =0; 
    while (~imem_ready) begin 
    delay(1); delay(1); $display("-> not ready! cant send write: %h ", address );
      count++;
      if(count > 100) begin
        $display("-> not ready! cant send read request: %h ", address );
        eot("ERROR: dmem_rd_req: not ready for 100 cycles!");
      end
    end
$display("rd_req: %h , address %h:", id, address);
    $display("imem_rd_req: %h , address %h:", id, address);
    imem_core2cache_req.valid   =  1'b1;
    imem_core2cache_req.opcode  =  RD_OP;
    imem_core2cache_req.address =  address;
    imem_core2cache_req.reg_id  =  id;
    delay(1);
    imem_core2cache_req     = '0;
endtask

//=======================================================

task eot(input string msg);
  $display("END-OF-TEST Message: %s =\n", msg);
  $finish;
endtask 


//systemverilog task to create the pull of tags and sets to be used in the test
task create_dmem_addrs_pull();
    int i;
    for (i = 0; i < V_MAX_NUM_TAG_PULL+1; i = i + 1) begin
        dmem_tag_pull[i] = $urandom_range(8'h10, 8'h1F); 
    end
    for (i = 0; i < V_MAX_NUM_SET_PULL+1; i = i + 1) begin
        dmem_set_pull[i] = $urandom_range(8'h00, 8'hFF);
    end
endtask

//=======================================================
task dmem_create_addrs(output logic [19:0] addr);
    // assign the tag bits to the addr[19:12]
    // choose random tag from the tag_pull
    logic [7:0] rand_num;
    rand_num = $urandom_range(0, V_MAX_NUM_TAG_PULL);
    addr[19:12] = dmem_tag_pull[rand_num];
    // assign the set bits for the addr[11:4]
    // choose random set from the set_pull
    rand_num = $urandom_range(0, V_MAX_NUM_SET_PULL);
    addr[11:4] = dmem_set_pull[rand_num];
    // assign random offset bits for the addr[3:0]
    addr[3:2] = $urandom_range(0, 3);
    addr[1:0] = 2'b0;
endtask

//=======================================================

task dmem_random_wr( ); 
    logic [19:0] addr;
    logic [31:0] data;
    logic [4:0]  id;
    int i;
    dmem_create_addrs(.addr(addr) );
    data = $urandom_range(0, 32'hFFFFFFFF);
    id = $urandom_range(0, 5'd31);
    dmem_wr_req(addr, data, id);
    i = $urandom_range(V_MIN_REQ_DELAY, V_MAX_REQ_DELAY);
    delay(i);
endtask

//=======================================================
task dmem_random_rd(); 
    logic [19:0] addr;
    logic [4:0]  id;
    int i;
    dmem_create_addrs(.addr(addr));
    id = $urandom_range(0, 5'd31);
    dmem_rd_req(addr, id);
    i = $urandom_range(V_MIN_REQ_DELAY, V_MAX_REQ_DELAY);
    delay(i);
endtask

