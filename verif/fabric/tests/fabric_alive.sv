$display("Finished elaborating the design...");

delay(10);
send_rand_req(.source_id(8'h1_1), .target_id(8'h3_3));
delay(10);
send_rand_req(.source_id(8'h2_2), .target_id(8'h3_3));
delay(10);
send_rand_req(.source_id(8'h2_1), .target_id(8'h3_3));
delay(10);
send_rand_req(.source_id(8'h1_2), .target_id(8'h3_3));
delay(10);
send_rand_req(.source_id(8'h3_1), .target_id(8'h3_3));
