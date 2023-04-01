delay(1);  backdoor_fm_load();
//==========================================================
//  Randomly generate read/write requests
//==========================================================
// in this test will start with many write request to a small pull of addresses
// with a small delay between each request
// then will start with many read request to a small pull of addresses
// with a a big delay between each request - due to our missing stall functinality in the cache (after read miss)

MAX_REQ_DELAY = 2; 
MIN_REQ_DELAY = 0;
NUM_REQ       = 50;
NUM_SET_PULL  = 1;
NUM_TAG_PULL  = 10;
create_addrs_pull(tag_pull, set_pull);

// send wr request
for(int i = 0; i<NUM_REQ; i++) begin
    random_wr();
end

MAX_REQ_DELAY = 16; 
MIN_REQ_DELAY = 15;
NUM_REQ       = 50;
// send rd request
for(int i = 0; i<NUM_REQ; i++) begin
        random_rd();
end
