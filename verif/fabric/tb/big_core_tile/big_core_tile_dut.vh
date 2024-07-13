  t_tile_id local_tile_id;
  
  // North Interface
  logic in_north_req_valid;
  t_tile_trans in_north_req;
  t_fab_ready out_north_ready;
  logic out_north_req_valid;
  t_tile_trans out_north_req;
  t_fab_ready in_north_ready;
  
  // East Interface
  logic in_east_req_valid;
  t_tile_trans in_east_req;
  t_fab_ready out_east_ready;
  logic out_east_req_valid;
  t_tile_trans out_east_req;
  t_fab_ready in_east_ready;
  
  // West Interface
  logic in_west_req_valid;
  t_tile_trans in_west_req;
  t_fab_ready out_west_ready;
  logic out_west_req_valid;
  t_tile_trans out_west_req;
  t_fab_ready in_west_ready;
  
  // South Interface
  logic in_south_req_valid;
  t_tile_trans in_south_req;
  t_fab_ready out_south_ready;
  logic out_south_req_valid;
  t_tile_trans out_south_req;
  t_fab_ready in_south_ready;
  
  big_core_tile big_core_tile_ins (
    .clk(clk),
    .rst(rst),
    .local_tile_id(local_tile_id),
    .in_north_req_valid(in_north_req_valid),
    .in_north_req(in_north_req),
    .out_north_ready(out_north_ready),
    .out_north_req_valid(out_north_req_valid),
    .out_north_req(out_north_req),
    .in_north_ready(in_north_ready),
    .in_east_req_valid(in_east_req_valid),
    .in_east_req(in_east_req),
    .out_east_ready(out_east_ready),
    .out_east_req_valid(out_east_req_valid),
    .out_east_req(out_east_req),
    .in_east_ready(in_east_ready),
    .in_west_req_valid(in_west_req_valid),
    .in_west_req(in_west_req),
    .out_west_ready(out_west_ready),
    .out_west_req_valid(out_west_req_valid),
    .out_west_req(out_west_req),
    .in_west_ready(in_west_ready),
    .in_south_req_valid(in_south_req_valid),
    .in_south_req(in_south_req),
    .out_south_ready(out_south_ready),
    .out_south_req_valid(out_south_req_valid),
    .out_south_req(out_south_req),
    .in_south_ready(in_south_ready)
  );


