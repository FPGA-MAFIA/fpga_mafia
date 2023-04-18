delay(1);  backdoor_fm_load();
//==========================================================
//  Randomly generate read/write requests
//==========================================================
// in this test will start with many write request to a small pull of addresses
// with a small delay between each request
// then will start with many read request to a small pull of addresses
// with a a big delay between each request - due to our missing stall functinality in the cache (after read miss)

LOCAL_NUM_TAG_PULL = 10;
LOCAL_NUM_SET_PULL = 1;
create_addrs_pull(.local_num_tag_pull(LOCAL_NUM_TAG_PULL),//input
                  .local_num_set_pull(LOCAL_NUM_SET_PULL),//input
                  .tag_pull(tag_pull),  //output
                  .set_pull(set_pull)   //output
                  );

// send 50 wr request (Low Latency - B2B)
for(int i = 0; i<50; i++) begin
    random_wr(  .local_min_req_delay(0), 
                .local_max_req_delay(2),
                .local_num_tag_pull(LOCAL_NUM_TAG_PULL),   //input
                .local_num_set_pull(LOCAL_NUM_SET_PULL)    //input
                );
end

// send 50 rd request (High Latency)
for(int i = 0; i<50; i++) begin
    random_rd(  .local_min_req_delay(15), 
                .local_max_req_delay(16),
                .local_num_tag_pull(LOCAL_NUM_TAG_PULL),   //input
                .local_num_set_pull(LOCAL_NUM_SET_PULL)    //input
                );
end
