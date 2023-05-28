$display("Finished elaborating the design...");
for(int i=0; i< 10; i++) begin
    do begin 
        `RAND_EP(rand_source)
        `RAND_EP(rand_target)
    end while (rand_source == rand_target);
    send_rand_req(.source_id(rand_source), .target_id(rand_target));
    delay(10);
end