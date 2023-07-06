$display("Finished elaborating the design...");
// Starting the Back pressure test by forcing mini_core_ready to 0 at the End-Point
repeat(num_cycles)begin
  flg = '0;
  do begin 
      `RAND_EP(m_source)
      `RAND_EP(m_target)
  end while(m_source == m_target);
  force_target(m_target);
  $display("send force at time %0t to target [%0d,%0d]",$time,m_target[7:4],m_target[3:0]);
  for(int i=0; i< V_REQUESTS; i++) begin
    fork : mini_ready
      // ============================================================================
      // The fork has 2 branches - if any of them is done, we join_any and exit the fork
      // ============================================================================
      // 1. dont send a new request until the tile_ready is 5'b11111 again
      wait(tile_ready[m_source[7:4]][m_source[3:0]] == 5'b11111);
      // 2. in parallel, wait 100 cycles and then set the flg to 1'b1
      begin : time_out_mechanism_detect_back_pressure
        delay(100);
        flg = 1;
      end
    join_any
    disable mini_ready; // must disable the fork or it will keep running in BG
    //
    if(flg == 1'b1) begin 
      $display("full fabric for path [%0d,%0d] -> [%0d,%0d] at time %0t with %0d req in pipe",m_source[7:4],m_source[3:0],m_target[7:4],m_target[3:0],$time,i);
      break;
    end
    send_req(.source_id(m_source), .target_id(m_target), .opcode(WR));
    delay(10);
  end
  delay(10);
  release_target(m_target);
  $display("release force at time %0t \n",$time);
  delay(100);
end // repeat
delay(100);