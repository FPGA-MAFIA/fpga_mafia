
logic           [4:0] [4:0] v_in_north_valid;
logic           [4:0] [4:0] v_in_south_valid;
logic           [4:0] [4:0] v_in_east_valid;
logic           [4:0] [4:0] v_in_west_valid;
t_tile_trans    [4:0] [4:0] v_in_north_req;
t_tile_trans    [4:0] [4:0] v_in_south_req;
t_tile_trans    [4:0] [4:0] v_in_east_req;
t_tile_trans    [4:0] [4:0] v_in_west_req;
// TODO - ADD READY.
fabric fabric (
.clk(clk),
.rst(rst)
);

always_comb begin
    for(int i = 1 ; i<4 ;i++)begin
       for(int j = 1 ; j<4 ;j++)begin
        fabric.in_north_req_valid[i][j] = v_in_north_valid[i][j];
        fabric.in_south_req_valid[i][j] = v_in_south_valid[i][j];
        fabric.in_east_req_valid [i][j] = v_in_east_valid[i][j];
        fabric.in_west_req_valid [i][j] = v_in_west_valid[i][j];


        fabric.in_north_req[i][j] = v_in_north_req[i][j]; 
        fabric.in_south_req[i][j] = v_in_south_req[i][j];
        fabric.in_east_req [i][j] = v_in_east_req[i][j] ;
        fabric.in_west_req [i][j] = v_in_west_req[i][j] ;
      end
   end
end
