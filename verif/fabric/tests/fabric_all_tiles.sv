$display("Finished elaborating the design...");
  for(int i = 1; i<= V_COL; i++) begin
    for(int j = 1; j<= V_ROW; j++) begin
         automatic int col = i;
         automatic int row = j;
         fork begin
            t_tile_id source;
            int rand_cycles;
            source[7:4] = col;
            source[3:0] = row;
            for(int i=0; i< V_REQUESTS; i++) begin
                wait(tile_ready[col][row] == 5'b11111);// naive implementation only when all ready are 1 we can insert a new trans.
                rand_cycles = $urandom_range(10,V_NUM_CYCLES+10);//TODO - need to see how to implement stress mode, for now not working very good. 
                //if WR and RD_RSP are coming together at the same time the checker dont know how to handle it very well.
                send_rand_req_from_tile(source);
                delay(rand_cycles);
            end
         end  join
    end
  end
  delay(100);