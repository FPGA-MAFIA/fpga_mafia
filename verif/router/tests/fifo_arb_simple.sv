//parameter V_NUM_FIFO=4;
$display("V_NUM_FIFO=%0d",V_NUM_FIFO);
for (int i = 0; i<V_NUM_FIFO; i++)begin
    fifo_arb_gen_trans(i);
    delay(3);
end
