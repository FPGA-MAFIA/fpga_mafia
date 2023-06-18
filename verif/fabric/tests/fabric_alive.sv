$display("Finished elaborating the design...");

//sending direct requests
send_req(.source_id(8'h1_1), .target_id(8'h3_3), .opcode(WR));
delay(20);
send_req(.source_id(8'h1_1), .target_id(8'h3_3), .opcode(RD));
delay(20);

//sending random requests
for(int i=0; i< V_REQUESTS; i++) begin
    send_rand_req_from_tile(.source(8'h3_3));
    delay(10);
end
delay(500);