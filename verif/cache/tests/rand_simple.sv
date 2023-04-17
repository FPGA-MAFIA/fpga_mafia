delay(1);  backdoor_fm_load();
//==========================================================
//  Randomly generate read/write requests
//==========================================================
// simple:
// New request is generated every 20-15 cycles
// 25% read, 75% write
// 2 sets , 2 tags 
// default parameter values V_MAX_REQ_DELAY = 16; 
// default parameter values V_MIN_REQ_DELAY = 15;
// default parameter values V_NUM_REQ       = 50;
// default parameter values V_RD_RATIO      = 25; //25% read , 75% write
// default parameter values V_NUM_SET_PULL  = 2;
// default parameter values V_NUM_TAG_PULL  = 2;

LOCAL_NUM_TAG_PULL = V_NUM_TAG_PULL;
LOCAL_NUM_SET_PULL = V_NUM_SET_PULL;

create_addrs_pull(.local_num_tag_pull(V_MAX_NUM_TAG_PULL),//input
                  .local_num_set_pull(V_MAX_NUM_SET_PULL),//input
                  .tag_pull(tag_pull),  //output
                  .set_pull(set_pull)   //output
                  );
// send rd/wr request according to the RD_RATIO parameter
for(int i = 0; i<V_NUM_REQ; i++) begin
    if(V_RD_RATIO > $urandom_range(0, 100)) begin
        random_rd(.local_min_req_delay(15), //input
                  .local_max_req_delay(16), //input
                  .local_num_tag_pull(LOCAL_NUM_TAG_PULL),   //input
                  .local_num_set_pull(LOCAL_NUM_SET_PULL)    //input
                  );
    end else begin
        random_wr(.local_min_req_delay(15),  //input
                  .local_max_req_delay(16),  //input
                  .local_num_tag_pull(LOCAL_NUM_TAG_PULL),    //input
                  .local_num_set_pull(LOCAL_NUM_SET_PULL)     //input
                  );
    end
end
