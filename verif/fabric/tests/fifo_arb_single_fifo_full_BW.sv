for(int i=0;i<V_REQUESTS; i++)begin
    fifo_arb_gen_trans(0);
    $display("item number: %d",i);
end