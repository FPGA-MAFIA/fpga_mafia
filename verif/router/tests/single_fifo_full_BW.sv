parameter REQUESTS = 10;
parameter PUSHED_FIFO = 0;
for(int i=0;i<REQUESTS; i++)begin
    gen_trans(PUSHED_FIFO);
    $display("item number: %d",i);
end