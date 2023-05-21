$display("Finished elaborating the design...");

//sending direct requests
send_req(.source_id(8'h1_1), .target_id(8'h3_3), .opcode(WR));
delay(20);
send_req(.source_id(8'h3_3), .target_id(8'h1_1), .opcode(WR));
delay(20);

//sending random requests
for(int i=0; i< 10; i++) begin
    send_rand_req();
    delay(10);
end