
//=======================================================
//=======================================================
task delay(input int cycles);
  for(int i =0; i< cycles; i++) begin
    @(posedge clk);
  end
endtask

//=======================================================
//=======================================================
task backdoor_cache_load();
  for(int SET =0; SET< NUM_SET ; SET++) begin
    for(int WAY =0; WAY< NUM_WAYS; WAY++) begin
        back_door_entry.tags    [WAY] = WAY + 1000;
        back_door_entry.valid   [WAY] = 1'b1;
        back_door_entry.modified[WAY] = 1'b0;
        back_door_entry.mru     [WAY] = 1'b0;
    end
    tag_mem[SET]  = back_door_entry;
  end

  for(int D_WAY = 0; D_WAY< (SET_ADRS_WIDTH + WAY_WIDTH) ; D_WAY++) begin
    data_mem[D_WAY]  = 'h5000+D_WAY;
  end
    force cache.cache_pipe_wrap.tag_array.mem  = tag_mem;
    force cache.cache_pipe_wrap.data_array.mem = data_mem;
    delay(5);

    release cache.cache_pipe_wrap.data_array.mem;
    release cache.cache_pipe_wrap.tag_array.mem;
endtask

//=======================================================
//=======================================================
task backdoor_fm_load();
  $display("= backdoor_fm_load start =\n");
  for(int FM_ADDRESS =0; FM_ADDRESS < NUM_FM_CL ; FM_ADDRESS++) begin
        back_door_fm_mem[FM_ADDRESS] = FM_ADDRESS + 'hABBA_BABA_0000_1111;
  end
    force far_memory_array.mem  = back_door_fm_mem;
    force cache_ref_model.mem  = back_door_fm_mem;
    delay(5);
    release far_memory_array.mem;
    release cache_ref_model.mem;
  $display("= backdoor_fm_load done =\n");
endtask

//=======================================================
//=======================================================
task wr_req( input logic [19:0]  address, 
             input logic [127:0] data ,
             input logic [4:0]   id );
    while (stall) begin
      delay(1); $display("-> stall! cant send write: %h ", address );
    end
$display("wr_req: %h , address %h:", id, address);
    core2cache_req.valid   =  1'b1;
    core2cache_req.opcode  =  WR_OP;
    core2cache_req.address =  address;
    core2cache_req.data    =  data;
    core2cache_req.reg_id  =  id;
    delay(1); 
    core2cache_req     = '0;
endtask

//=======================================================
//=======================================================
task rd_req( input logic [19:0] address,
             input logic [4:0] id); 
    while (stall) begin 
    delay(1);  $display("-> stall! cant send read: %h ", address);
    end
$display("rd_req: %h , address %h:", id, address);
    core2cache_req.valid   =  1'b1;
    core2cache_req.opcode  =  RD_OP;
    core2cache_req.address =  address;
    core2cache_req.reg_id  =  id;
    delay(1);
    core2cache_req     = '0;
endtask


//=======================================================
//=======================================================
//systemverilog task to create the pull of tags and sets to be used in the test
task create_addrs_pull(output logic [7:0] tag_pull [MAX_NUM_TAG_PULL:0],
                       output logic [7:0] set_pull [MAX_NUM_SET_PULL:0]);
    int i;
    for (i = 0; i < NUM_TAG_PULL; i = i + 1) begin
        tag_pull[i] = $urandom_range(8'h00, 8'hFF);
        set_pull[i] = $urandom_range(8'h00, 8'hFF);
    end
endtask



//=======================================================
//=======================================================
task create_addrs(output logic [19:0] addr);
    // assign the tag bits to the addr[19:12]
    // choose random tag from the tag_pull
    logic [7:0] rand_num;
    rand_num = $urandom_range(0, NUM_TAG_PULL - 1);
    addr[19:12] = tag_pull[rand_num];
    // assign the set bits for the addr[11:4]
    // choose random set from the set_pull
    rand_num = $urandom_range(0, NUM_SET_PULL - 1);
    addr[11:4] = set_pull[rand_num];
    // assign random offset bits for the addr[3:0]
    addr[3:2] = $urandom_range(0, 3);
    addr[1:0] = 2'b0;
endtask

//=======================================================
//=======================================================
task random_wr(); 
    logic [19:0] addr;
    logic [31:0] data;
    logic [4:0]  id;
    int i;
    create_addrs(addr);
    data = $urandom_range(0, 32'hFFFFFFFF);
    id = $urandom_range(0, 5'd31);
    wr_req(addr, data, id);
    i = $urandom_range(MIN_REQ_DELAY, MAX_REQ_DELAY);
    delay(i);
endtask

//=======================================================
//=======================================================
task random_rd(); 
    logic [19:0] addr;
    logic [4:0]  id;
    int i;
    create_addrs(addr);
    id = $urandom_range(0, 5'd31);
    rd_req(addr, id);
    i = $urandom_range(MIN_REQ_DELAY, MAX_REQ_DELAY);
    delay(i);
endtask
