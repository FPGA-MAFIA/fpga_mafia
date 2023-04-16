parameter REQUESTS = 1;
parameter NUM_FIFO  = 4;
int delay_ps;
for(int i = 0; i<NUM_FIFO; i++) begin
  automatic int fifo = i;
  fork begin 
    $display("this is fifo %d at time %t",fifo,$time);
    for(int j = 0; j < REQUESTS; j++)begin
        delay_ps = $urandom_range(0, 100)/10;
        #(delay_ps);   
        $display("fifo %d and request %d at time: %t",fifo,j,$time);
        gen_trans(fifo);
    end
  end join_none
end