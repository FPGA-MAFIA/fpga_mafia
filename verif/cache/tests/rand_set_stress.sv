delay(1);  backdoor_fm_load();
//==========================================================
//  Randomly generate read/write requests
//==========================================================

LOCAL_NUM_TAG_PULL = 9;
LOCAL_NUM_SET_PULL = 1;
// simple:
// New request is generated every 20-15 cycles
create_addrs_pull(.local_num_tag_pull(LOCAL_NUM_TAG_PULL),//input
                  .local_num_set_pull(LOCAL_NUM_SET_PULL),//input
                  .tag_pull(tag_pull),  //output
                  .set_pull(set_pull)   //output
                  );

// send 50 rd/wr request according to the RD_RATIO parameter
for(int i = 0; i<50; i++) begin
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
