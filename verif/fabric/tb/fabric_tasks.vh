task run_fabric_test(input string test);
  delay(30);
  // ====================
  // mini_core_tile tests:
  // ====================
  if (test == "fabric_alive") begin
     `include "fabric_alive.sv"
  end else begin
    $error(" [ERROR] : test %s not found",test);
  end
endtask


// XMR to drive a request from one local core in the fabric to another
task send_rand_req(input t_tile_id source_id, input t_tile_id target_id);
int source_row, source_col;
assign source_row = source_id[7:4];
assign source_col = source_id[3:0];

assign fabric.instance_tile_col_loop[1].instance_tile_row_loop[1].mini_core_tile_ins.in_local_req_valid    = 1'b1;
assign fabric.instance_tile_col_loop[1].instance_tile_row_loop[1].mini_core_tile_ins.in_local_req.data     = 32'hdeadbeef;  // $urandom_range(0,2^32-1);
assign fabric.instance_tile_col_loop[1].instance_tile_row_loop[1].mini_core_tile_ins.in_local_req.address  = {target_id, 24'h0};
assign fabric.instance_tile_col_loop[1].instance_tile_row_loop[1].mini_core_tile_ins.in_local_req.opcode   = WR; // $urandom_range(0,3);
delay(1);
assign fabric.instance_tile_col_loop[1].instance_tile_row_loop[1].mini_core_tile_ins.in_local_req_valid    = 1'b0;

endtask
