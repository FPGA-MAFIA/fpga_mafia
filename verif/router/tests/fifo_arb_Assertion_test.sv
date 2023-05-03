//parameter V_REQUESTS = 20;
//parameter V_NUM_FIFO  = 4;
int cycle_delay;
for(int i = 0; i<V_NUM_FIFO; i++) begin
  automatic int fifo = i;
  fork begin 
    $display("this is fifo %d at time %t",fifo,$time);
    for(int j = 0; j < 30; j++)begin
        cycle_delay = $urandom_range(0, V_MAX_DELAY);
        //delay(cycle_delay);  
        $display("fifo %d and request %d at time: %t",fifo,j,$time);
        fifo_arb_gen_trans(fifo);
    end
  end join_none
end