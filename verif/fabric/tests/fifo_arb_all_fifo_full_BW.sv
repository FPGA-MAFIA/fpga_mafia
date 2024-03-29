//parameter V_REQUESTS = 1;
//parameter V_NUM_FIFO  = 4;
int cycle_delay;
int cycle_delay_arb;
int delay_test;
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
  fifo_finish = fifo_finish + 1;
  $display("############# this is FIFO_FINISH %0d in fifo %0d at time %t",fifo_finish,fifo,$time);

  end 
  join_none
end
fork : in_ready_arb_fifo_fork
    begin
    forever begin
    cycle_delay_arb = $urandom_range(2, V_MAX_DELAY + 15);// dont change to less than 2, it will stuck the simulation.
    rand_in_ready = $urandom_range(0,15);
    delay(cycle_delay_arb);
    in_ready_arb_fifo = {5{rand_in_ready}};// casting to 4 bit logic data type.
    //$display("^^^^^^^^^^^^^^^^ this is rand_in_ready %0d and casting rand_bit ready %0d , %b", rand_in_ready,in_ready_arb_fifo,in_ready_arb_fifo);
    end
  end
  begin
    delay_test = V_REQUESTS/V_NUM_FIFO;
    delay(delay_test);
  end
join_any

disable in_ready_arb_fifo_fork; // this will make the valid direct again so the test could finished properley.
in_ready_arb_fifo = 5'b11111;

//fork

wait(fifo_finish == (V_NUM_FIFO));
$display("############# this is empty %4b at time %t befote wait",fifo_arb_ins.empty,$time);
wait(fifo_arb_ins.empty == 4'b1111);
//join
$display("############# after wait FIFO_FINISH %0d at time %0t",fifo_finish,$time);
$display("############# this is empty %4b at time %t after wait",fifo_arb_ins.empty,$time);