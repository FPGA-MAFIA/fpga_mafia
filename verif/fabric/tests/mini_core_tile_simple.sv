gen_rand_data(); // TODO - make it generic for all sides.
delay(10);
in_north_req_valid = 1'b1;
delay(5);
in_north_req_valid = '0;
delay(5);
$display("DONE SIMPLE MINI_CORE_TILE_TEST");
