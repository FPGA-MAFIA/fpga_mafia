$display("Finished elaborating the design...");
  for(int i = 1; i<= V_COL; i++) begin
    for(int j = 1; j<= V_ROW; j++) begin
         automatic int col = i;
         automatic int row = j;
         fork begin
            t_tile_id source;
            int rand_cycles;
            rand_cycles = $urandom_range(0,V_NUM_CYCLES);
            source[7:4] = col;
            source[3:0] = row;
            for(int i=0; i< V_REQUESTS; i++) begin
                //if($bits(target_trans[col][row]) === '0 || $bits(target_trans[col][row]) === 'x )begin
                send_rand_req_from_tile(source);
                delay(rand_cycles);
                //end
            end
         end  join
    end
  end