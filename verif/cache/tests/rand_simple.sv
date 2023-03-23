delay(1);  backdoor_fm_load();
create_addrs_pull(tag_pull, set_pull);


// send rd/wr request according to the RD_RATIO parameter
for(int i = 0; i<NUM_REQ; i++) begin
    if(RD_RATIO > $urandom_range(0, 100)) begin
        random_rd();
    end else begin
        random_wr();
    end
end
