$display("Finished elaborating the design...");

//delay(10);
//send_rand_req(.source_id(8'h1_1), .target_id(8'h3_3));
//delay(10);
//send_rand_req(.source_id(8'h1_2), .target_id(8'h3_3));
//delay(10);
//send_rand_req(.source_id(8'h2_1), .target_id(8'h3_3));
//delay(10);
//send_rand_req(.source_id(8'h3_3), .target_id(8'h1_1));
//delay(10);
//send_rand_req(.source_id(8'h1_3), .target_id(8'h3_1));
//delay(10);


for(int i=0; i< 10; i++) begin
    do begin 
        `RAND_EP(rand_source)
        `RAND_EP(rand_target)
    end while (rand_source == rand_target);
    send_rand_req(.source_id(rand_source), .target_id(rand_target));
    delay(10);
end