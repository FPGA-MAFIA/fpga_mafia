
//=======================================================
//=======================================================
task delay(input int cycles);
  for(int i =0; i< cycles; i++) begin
    @(posedge clk);
  end
endtask

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
             input logic [31:0] data ,
             input logic [4:0]   id );
    while (~ready) begin
      delay(1); $display("-> not ready! cant send write: %h ", address );
    end
$display("wr_req: %h , address %h:", id, address);
    core2cache_req.valid       =  1'b1;
    core2cache_req.opcode      =  WR_OP;
    core2cache_req.address     =  address;
    core2cache_req.data        =  data;
    core2cache_req.reg_id      =  id;
    core2cache_req.byte_en     =  4'b1111;  // default value for wr_req task. To change them better use the wr_req_b_en task
    core2cache_req.sign_extend =  1'b0;     // default value  for wr_req task
    delay(1); 
    core2cache_req     = '0;
endtask

//=======================================================
//=======================================================
task wr_req_sb( input logic [19:0]  address, 
                input logic [31:0]  data ,
                input logic [4:0]   id);
    while (~ready) begin
      delay(1); $display("-> not ready! cant send write: %h ", address );
    end
$display("wr_req_sb: %h , address %h:", id, address);
    core2cache_req.valid       =  1'b1;
    core2cache_req.opcode      =  WR_OP;
    core2cache_req.address     =  address;
    core2cache_req.data        =  data;
    core2cache_req.reg_id      =  id;
    core2cache_req.byte_en     =  4'b0001;  
    core2cache_req.sign_extend =  1'b0;     
    delay(1); 
    core2cache_req     = '0;
endtask

//=======================================================
//=======================================================
task wr_req_sh( input logic [19:0]  address, 
                input logic [31:0]  data ,
                input logic [4:0]   id);
    while (~ready) begin
      delay(1); $display("-> not ready! cant send write: %h ", address );
    end
$display("wr_req_store_half_byte: %h , address %h:", id, address);
    core2cache_req.valid       =  1'b1;
    core2cache_req.opcode      =  WR_OP;
    core2cache_req.address     =  address;
    core2cache_req.data        =  data;
    core2cache_req.reg_id      =  id;
    core2cache_req.byte_en     =  4'b0011;  
    core2cache_req.sign_extend =  1'b0;     
    delay(1); 
    core2cache_req     = '0;
endtask

//=======================================================
//=======================================================
task rd_req( input logic [19:0] address,
             input logic [4:0] id); 
    while (~ready) begin 
    delay(1);  $display("-> Not ready! cant send read: %h ", address);
    end
$display("rd_req: %h , address %h:", id, address);
    core2cache_req.valid       =  1'b1;
    core2cache_req.opcode      =  RD_OP;
    core2cache_req.address     =  address;
    core2cache_req.reg_id      =  id;
    core2cache_req.byte_en     =  4'b1111;  // default value for rd_req task
    core2cache_req.sign_extend =  1'b0;     // default value for rd_req task
    delay(1);
    core2cache_req     = '0;
endtask

//=======================================================
//=======================================================
task rd_req_lb( input logic [19:0] address,
                input logic [4:0]  id); 
    while (~ready) begin 
    delay(1);  $display("-> Not ready! cant send read: %h ", address);
    end
$display("rd_req_lb: %h , address %h:", id, address);
    core2cache_req.valid       =  1'b1;
    core2cache_req.opcode      =  RD_OP;
    core2cache_req.address     =  address;
    core2cache_req.reg_id      =  id;
    core2cache_req.byte_en     =  4'b0001;  
    core2cache_req.sign_extend =  1'b1;   
    delay(1);
    core2cache_req     = '0;
endtask

//=======================================================
//=======================================================
task rd_req_lh( input logic [19:0] address,
                input logic [4:0]  id); 
    while (~ready) begin 
    delay(1);  $display("-> Not ready! cant send read: %h ", address);
    end
$display("rd_req_lh: %h , address %h:", id, address);
    core2cache_req.valid       =  1'b1;
    core2cache_req.opcode      =  RD_OP;
    core2cache_req.address     =  address;
    core2cache_req.reg_id      =  id;
    core2cache_req.byte_en     =  4'b0011;  
    core2cache_req.sign_extend =  1'b1;   
    delay(1);
    core2cache_req     = '0;
endtask

//=======================================================
//=======================================================
task rd_req_lbu( input logic [19:0] address,
                 input logic [4:0]  id); 
    while (~ready) begin 
    delay(1);  $display("-> Not ready! cant send read: %h ", address);
    end
$display("rd_req_lbu: %h , address %h:", id, address);
    core2cache_req.valid       =  1'b1;
    core2cache_req.opcode      =  RD_OP;
    core2cache_req.address     =  address;
    core2cache_req.reg_id      =  id;
    core2cache_req.byte_en     =  4'b0001;  
    core2cache_req.sign_extend =  1'b0;   
    delay(1);
    core2cache_req     = '0;
endtask

//=======================================================
//=======================================================
task rd_req_lhu( input logic [19:0] address,
                 input logic [4:0]  id); 
    while (~ready) begin 
    delay(1);  $display("-> Not ready! cant send read: %h ", address);
    end
$display("rd_req_lhu: %h , address %h:", id, address);
    core2cache_req.valid       =  1'b1;
    core2cache_req.opcode      =  RD_OP;
    core2cache_req.address     =  address;
    core2cache_req.reg_id      =  id;
    core2cache_req.byte_en     =  4'b0011;  
    core2cache_req.sign_extend =  1'b0;   
    delay(1);
    core2cache_req     = '0;
endtask

//=======================================================
//=======================================================
//systemverilog task to create the pull of tags and sets to be used in the test
task create_addrs_pull(input int local_num_tag_pull = V_MAX_NUM_TAG_PULL, // default values
                       input int local_num_set_pull = V_MAX_NUM_SET_PULL, // default values
                       output logic [7:0] tag_pull [V_MAX_NUM_TAG_PULL:0],
                       output logic [7:0] set_pull [V_MAX_NUM_SET_PULL:0]);
    int i;
    for (i = 0; i < local_num_tag_pull+1; i = i + 1) begin
        tag_pull[i] = $urandom_range(8'h00, 8'hFF);
    end
    for (i = 0; i < local_num_set_pull+1; i = i + 1) begin
        set_pull[i] = $urandom_range(8'h00, 8'hFF);
    end
endtask


task read_all_tag_set_pull(input int local_num_tag_pull = V_NUM_TAG_PULL, // default values
                           input int local_num_set_pull = V_NUM_SET_PULL, // default values
                           input logic [7:0] tag_pull [V_MAX_NUM_TAG_PULL:0],
                           input logic [7:0] set_pull [V_MAX_NUM_SET_PULL:0]
                           );
  // got over the tag_pull & the set_pull and read all the tags and sets up to the local_num_tag_pull & local_num_set_pull
  // this is used to makes sure in EOT (end of test) that all the data was correct
  for(int i = 0; i < local_num_tag_pull; i = i + 1) begin
    for(int j = 0; j < local_num_set_pull; j = j + 1) begin
      //go over the 4 cl offset:
      $display("===EOT==== rd -> tag=%0h, set=%0h", tag_pull[i], set_pull[j]);
      for(logic [2:0] k = 0; k < 4; k++)begin 
        rd_req( {tag_pull[i], set_pull[j], k[1:0], 2'b00}, 1);
      end//k offset
    end//j set
  end//i tag

endtask




//=======================================================
//=======================================================
task create_addrs(input int local_num_tag_pull, 
                  input int local_num_set_pull, 
                  output logic [19:0] addr);
    // assign the tag bits to the addr[19:12]
    // choose random tag from the tag_pull
    logic [7:0] rand_num;
    rand_num = $urandom_range(0, local_num_tag_pull - 1);
    addr[19:12] = tag_pull[rand_num];
    // assign the set bits for the addr[11:4]
    // choose random set from the set_pull
    rand_num = $urandom_range(0, local_num_set_pull - 1);
    addr[11:4] = set_pull[rand_num];
    // assign random offset bits for the addr[3:0]
    addr[3:2] = $urandom_range(0, 3);
    addr[1:0] = 2'b0;
endtask

//=======================================================
//=======================================================
task random_wr(input int local_min_req_delay = V_MIN_REQ_DELAY, // default values
               input int local_max_req_delay = V_MAX_REQ_DELAY, // default values
               input int local_num_tag_pull  = V_NUM_TAG_PULL, // default values
               input int local_num_set_pull  = V_NUM_SET_PULL  // default values
              ); 
    logic [19:0] addr;
    logic [31:0] data;
    logic [4:0]  id;
    int i;
    create_addrs(.local_num_tag_pull(local_num_tag_pull), 
                 .local_num_set_pull(local_num_set_pull), 
                 .addr(addr)
                 );
    data = $urandom_range(0, 32'hFFFFFFFF);
    id = $urandom_range(0, 5'd31);
    wr_req(addr, data, id);
    i = $urandom_range(local_min_req_delay, local_max_req_delay);
    delay(i);
endtask

//=======================================================
//=======================================================
task random_rd(
                input int local_min_req_delay = V_MIN_REQ_DELAY, // default values
                input int local_max_req_delay = V_MAX_REQ_DELAY, // default values
                input int local_num_tag_pull  = V_NUM_TAG_PULL, // default values
                input int local_num_set_pull  = V_NUM_SET_PULL  // default values
              ); 
    logic [19:0] addr;
    logic [4:0]  id;
    int i;
    create_addrs(.local_num_tag_pull(local_num_tag_pull), 
                 .local_num_set_pull(local_num_set_pull), 
                 .addr(addr)
                 );
    id = $urandom_range(0, 5'd31);
    rd_req(addr, id);
    i = $urandom_range(local_min_req_delay, local_max_req_delay);
    delay(i);
endtask
