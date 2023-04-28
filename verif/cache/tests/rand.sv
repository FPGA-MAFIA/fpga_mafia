delay(1);  backdoor_fm_load();
//==========================================================
//  Randomly generate read/write requests
//==========================================================
// see default parameter values in the module cache_tb - the may be overridden by the cmd line using -pvalue/-gPARAM_NAME=value

create_addrs_pull(.local_num_tag_pull(V_MAX_NUM_TAG_PULL),//input
                  .local_num_set_pull(V_MAX_NUM_SET_PULL),//input
                  .tag_pull(tag_pull),  //output
                  .set_pull(set_pull)   //output
                  );
// print the generated addresses
$display("======================================\n     Generated addresses \n======================================\n");
for(int i = 0; i<V_NUM_TAG_PULL; i++) begin
    $display("tag_pull[%0d] = %0h", i, tag_pull[i]);
end
for(int i = 0; i<V_NUM_SET_PULL; i++) begin
    $display("set_pull[%0d] = %0h", i, set_pull[i]);
end

// send rd/wr request according to the RD_RATIO parameter
for(int i = 0; i<V_NUM_REQ; i++) begin
    if(V_RD_RATIO > $urandom_range(0, 100)) begin
        random_rd(); //using parameter default values (set_pull, tag_pull, delay)
    end else begin
        random_wr(); //using parameter default values (set_pull, tag_pull, delay)
    end
end



$display("======================================\n     EOT : End-Of-Test \n======================================\n");
//EOT: end of test
// Go over all the potential address in the test, read it all out
// The Reference model will compare it to all the data that was written
read_all_tag_set_pull(.local_num_tag_pull(V_NUM_TAG_PULL), // default values
                      .local_num_set_pull(V_NUM_SET_PULL), // default values
                      .tag_pull(tag_pull),  // input
                      .set_pull(set_pull)  // input
                     );
