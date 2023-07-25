//add here the alive tasks that you want to run
delay(20);   
create_dmem_addrs_pull();


for(int i = 0; i<V_NUM_REQ/2; i++) begin
        dmem_random_wr(); //using parameter default values (set_pull, tag_pull, delay)
end
// send rd/wr request according to the RD_RATIO parameter
for(int i = 0; i<V_NUM_REQ/2; i++) begin
    if(V_RD_RATIO > $urandom_range(0, 100)) begin
        dmem_random_wr(); //using parameter default values (set_pull, tag_pull, delay)
    end else begin
        dmem_random_rd(); //using parameter default values (set_pull, tag_pull, delay)
    end
end

delay(30);   