parameter V_REQUESTS = 1;
parameter V_NUM_FIFO  = 4;
int delay_ps;
for(int i = 0; i<V_NUM_FIFO; i++) begin
  automatic int fifo = i;
  fork begin 
    $display("this is fifo %d at time %t",fifo,$time);
    for(int j = 0; j < V_REQUESTS; j++)begin
        delay_ps = $urandom_range(0, 100)/10;
        #(delay_ps);   
        $display("fifo %d and request %d at time: %t",fifo,j,$time);
        fifo_arb_gen_trans(fifo);
    end
  end join_none
end