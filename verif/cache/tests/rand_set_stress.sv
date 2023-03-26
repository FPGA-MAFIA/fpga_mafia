delay(1);  backdoor_fm_load();
//==========================================================
//  Randomly generate read/write requests
//==========================================================
// simple:
// New request is generated every 20-15 cycles
// 25% read, 75% write
// 2 sets , 2 tags 
MAX_REQ_DELAY = 16; 
MIN_REQ_DELAY = 15;
NUM_REQ       = 50;
RD_RATIO      = 25; //25% read , 75% write
NUM_SET_PULL  = 1;
NUM_TAG_PULL  = 9;

create_addrs_pull(tag_pull, set_pull);

// send rd/wr request according to the RD_RATIO parameter
for(int i = 0; i<NUM_REQ; i++) begin
    if(RD_RATIO > $urandom_range(0, 100)) begin
        random_rd();
    end else begin
        random_wr();
    end
end
