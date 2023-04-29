//First request
delay(10);
input_gen_valid[NORTH] = 1'b1;
gen_req(.address({4'h4,4'h4,24'h0}) , 
        .local_card(SOUTH),
        .trans(input_gen[NORTH]));
delay(1);
input_gen_valid[NORTH] = 1'b0;
delay(10);

//second request
delay(10);
input_gen_valid[WEST] = 1'b1;
gen_req(.address({4'h4,4'h4,24'h0}) , 
        .local_card(SOUTH),
        .trans(input_gen[WEST]));
delay(1);
input_gen_valid[WEST] = 1'b0;
delay(10);

//Third request
delay(10);
input_gen_valid[LOCAL] = 1'b1;
gen_req(.address({4'h4,4'h4,24'h0}) , 
        .local_card(SOUTH),
        .trans(input_gen[LOCAL]));
delay(1);
input_gen_valid[LOCAL] = 1'b0;
delay(10);

//forth request
delay(10);
input_gen_valid[EAST] = 1'b1;
gen_req(.address({4'h5,4'h4,24'h0}) , 
        .local_card(SOUTH),
        .trans(input_gen[EAST]));
delay(1);
input_gen_valid[EAST] = 1'b0;
delay(10);
