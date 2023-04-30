//parameter V_REQUESTS = 1;
//parameter V_NUM_FIFO  = 4;
int cycle_delay;
static int fifo_finish;
for(int i = 0; i<V_NUM_FIFO; i++) begin
  automatic int fifo = i;
  fork begin 
    $display("this is fifo %d at time %t",fifo,$time);
    for(int j = 0; j < V_REQUESTS; j++)begin
        wait(fifo_arb_ins.full[fifo] == '0);
        cycle_delay = $urandom_range(0, V_MAX_DELAY);
        delay(cycle_delay);  
        $display("fifo %d and request %0d at time: %0t and full[%0d] is %0b and full is %4b",fifo,j,$time,fifo,fifo_arb_ins.full[fifo],fifo_arb_ins.full );
        fifo_arb_gen_trans(fifo);
    end
 // end join_none
  fifo_finish = fifo_finish + 1;
  $display("############# this is FIFO_FINISH %0d in fifo %0d at time %t",fifo_finish,fifo,$time);

  end join_none
end
//fork

wait(fifo_finish == (V_NUM_FIFO));
$display("############# this is empty %4b at time %t befote wait",fifo_arb_ins.empty,$time);
wait(fifo_arb_ins.empty == 4'b1111);
//join
$display("############# after wait FIFO_FINISH %0d at time %0t",fifo_finish,$time);
$display("############# this is empty %4b at time %t after wait",fifo_arb_ins.empty,$time);