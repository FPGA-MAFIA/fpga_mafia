
// TODO  - create thread so that we can have multiple requests at the same time

for(int i = 0; i < V_REQUESTS; i++) begin
    delay(($urandom_range(0, V_MAX_DELAY)));
    random_gen_req(.input_card(t_cardinal'($urandom_range(1, 5))));
end

    delay(10);
fork 
    random_gen_req(.input_card(t_cardinal'(NORTH)));
    //random_gen_req(.input_card(t_cardinal'(EAST)));
    //random_gen_req(.input_card(t_cardinal'(WEST)));
    //random_gen_req(.input_card(t_cardinal'(SOUTH)));
    //random_gen_req(.input_card(t_cardinal'(LOCAL)));
    delay(10);
join_any