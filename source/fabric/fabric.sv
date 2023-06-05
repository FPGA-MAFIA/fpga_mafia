//The fabric will instantiate a 3x3 mini_core_tile grid


module fabric
import common_pkg::*;
(
    input logic clk,
    input logic rst
);
// all north:
logic           [4:0] [4:0] in_north_req_valid, out_north_req_valid;
t_tile_trans    [4:0] [4:0] in_north_req,       out_north_req;
t_fab_ready     [4:0] [4:0] in_north_ready,     out_north_ready;
// all east:                                   
logic           [4:0] [4:0] in_east_req_valid,  out_east_req_valid;
t_tile_trans    [4:0] [4:0] in_east_req,        out_east_req;
t_fab_ready     [4:0] [4:0] in_east_ready,      out_east_ready;
// all west:                                   
logic           [4:0] [4:0] in_west_req_valid,  out_west_req_valid;
t_tile_trans    [4:0] [4:0] in_west_req,        out_west_req;
t_fab_ready     [4:0] [4:0] in_west_ready,      out_west_ready;
// all south:                                  
logic           [4:0] [4:0] in_south_req_valid, out_south_req_valid;
t_tile_trans    [4:0] [4:0] in_south_req,       out_south_req;
t_fab_ready     [4:0] [4:0] in_south_ready,     out_south_ready;

//==============================
//  overriding next t_tile_ID
//|=======|=======|=======|
//| [1,1] | [2,1] | [3,1] |
//|=======|=======|=======|
//| [1,2] | [2,2] | [3,2] |
//|=======|=======|=======|
//| [1,3] | [2,3] | [3,3] |
//|=======|=======|=======|

//TODO FIXME - connect the READY signal
always_comb begin : assign_the_grid_to_tiles
    //default assign to all fabric

    for(int row =0 ; row< 5; row++) begin
        for(int col =0 ; col< 5; col++) begin
            in_south_req_valid[col][row] = 1'b0;
            in_north_req_valid[col][row] = 1'b0;
            in_east_req_valid [col][row] = 1'b0;
            in_west_req_valid [col][row] = 1'b0;
        end//col
    end//row

    for(int row =1 ; row< 4; row++) begin
        for(int col =1 ; col< 4; col++) begin
            // connect the in_south to the out_north
            in_south_req_valid[col][row] = out_north_req_valid[col][row+1];
            in_south_req      [col][row] = out_north_req      [col][row+1];
            // connect the in_north to the out_south
            in_north_req_valid[col][row] = out_south_req_valid[col][row-1];
            in_north_req      [col][row] = out_south_req      [col][row-1];
            // connect the in_east to the out_west
            in_east_req_valid [col][row] = out_west_req_valid[col+1][row];
            in_east_req       [col][row] = out_west_req      [col+1][row];
            // connect the in_west to the out_east
            in_west_req_valid [col][row] = out_east_req_valid[col-1][row];
            in_west_req       [col][row] = out_east_req      [col-1][row];
        end
    end
end

// assign the un-used edges to 0
always_comb begin 
    for(int row =0; row< 5; row++) begin
        //The first column strap the valid to 0
        out_north_req_valid[0][row] = '0;
        out_south_req_valid[0][row] = '0;
        out_east_req_valid[0][row] = '0;
        out_west_req_valid[0][row] = '0;
        //The last column strap the valid to 0
        out_north_req_valid[4][row] = '0;
        out_south_req_valid[4][row] = '0;
        out_east_req_valid[4][row] = '0;
        out_west_req_valid[4][row] = '0;
    end
    for(int col =0; col< 5; col++) begin
        //The first row strap the valid to 0
        out_north_req_valid[col][0] = '0;
        out_south_req_valid[col][0] = '0;
        out_east_req_valid[col][0] = '0;
        out_west_req_valid[col][0] = '0;
        //The last row strap the valid to 0
        out_north_req_valid[col][4] = '0;
        out_south_req_valid[col][4] = '0;
        out_east_req_valid[col][4] = '0;
        out_west_req_valid[col][4] = '0;
    end

//TODO FIXME - connect the READY signal correctly
for(int col =0; col< 5; col++) begin
    for(int row =0; row< 5; row++) begin
        in_north_ready [col][row] =  5'b11111;//out_south_ready[col]  [row-1];
        in_east_ready  [col][row] =  5'b11111;//out_west_ready [col+1][row];
        in_west_ready  [col][row] =  5'b11111;//out_east_ready [col-1][row];
        in_south_ready [col][row] =  5'b11111;//out_north_ready[col]  [row+1];
        out_north_ready[col][row] =  5'b11111;//in_south_ready [col]  [row-1];
        out_east_ready [col][row] =  5'b11111;//in_west_ready  [col+1][row];
        out_west_ready [col][row] =  5'b11111;//in_east_ready  [col-1][row];
        out_south_ready[col][row] =  5'b11111;//in_north_ready [col]  [row+1];
    end // row
    end // col
end


genvar ROW;
genvar COL;

t_tile_id [3:1] [3:1] local_tile_id;
logic [3:1] [3:1] [3:0] local_tile_id_row;
logic [3:1] [3:1] [3:0] local_tile_id_col;
generate
for(COL = 1; COL<4; COL++) begin : col
for(ROW = 1; ROW<4; ROW++) begin : row
// generate the local_tile_id
assign local_tile_id_row[COL][ROW] = ROW;
assign local_tile_id_col[COL][ROW] = COL;
assign local_tile_id[COL][ROW] = {local_tile_id_col[COL][ROW],local_tile_id_row[COL][ROW]};
mini_core_tile mini_core_tile_ins (
    .clk                 (clk),
    .rst                 (rst),
    .local_tile_id       (local_tile_id[COL][ROW]),
    // North IO
    .in_north_req_valid  (in_north_req_valid   [COL][ROW]),
    .in_north_req        (in_north_req         [COL][ROW]),
    .out_north_ready     (out_north_ready      [COL][ROW]),
    .out_north_req_valid (out_north_req_valid  [COL][ROW]),
    .out_north_req       (out_north_req        [COL][ROW]),
    .in_north_ready      (in_north_ready       [COL][ROW]),
    // East IO
    .in_east_req_valid   (in_east_req_valid    [COL][ROW]),
    .in_east_req         (in_east_req          [COL][ROW]),
    .out_east_ready      (out_east_ready       [COL][ROW]),
    .out_east_req_valid  (out_east_req_valid   [COL][ROW]),
    .out_east_req        (out_east_req         [COL][ROW]),
    .in_east_ready       (in_east_ready        [COL][ROW]),
    // West IO
    .in_west_req_valid   (in_west_req_valid    [COL][ROW]),
    .in_west_req         (in_west_req          [COL][ROW]),
    .out_west_ready      (out_west_ready       [COL][ROW]),
    .out_west_req_valid  (out_west_req_valid   [COL][ROW]),
    .out_west_req        (out_west_req         [COL][ROW]),
    .in_west_ready       (in_west_ready        [COL][ROW]),
    // South IO
    .in_south_req_valid  (in_south_req_valid   [COL][ROW]),
    .in_south_req        (in_south_req         [COL][ROW]),
    .out_south_ready     (out_south_ready      [COL][ROW]),
    .out_south_req_valid (out_south_req_valid  [COL][ROW]),
    .out_south_req       (out_south_req        [COL][ROW]),
    .in_south_ready      (in_south_ready       [COL][ROW])
  );
end // row
end // col
endgenerate // row

endmodule


