parameter V_REQUESTS = 10;
parameter V_PUSHED_FIFO = 0;
for(int i=0;i<V_REQUESTS; i++)begin
    fifo_arb_gen_trans(V_PUSHED_FIFO);
    $display("item number: %d",i);
end