parameter V_NUM_OF_FIFO_ACTIVE = 1;
parameter V_RANDOM_TEST = 0;
parameter V_ROUNDS = 4;
int num_fifo_active; 

if(V_RANDOM_TEST) num_fifo_active = $urandom_range(1,4); // 4 fifo for now.
else            num_fifo_active = V_NUM_OF_FIFO_ACTIVE;

$display("num_fifo_active id %0d",num_fifo_active);

if(V_RANDOM_TEST) num_fifo_active = $urandom_range(1,4); // 4 fifo for now.
else            num_fifo_active = V_NUM_OF_FIFO_ACTIVE;

for(int j = 0; j<V_ROUNDS; j++)   begin
    for (int i=0; i<num_fifo_active; i++) begin
        push_fifo(i);
        delay(100);
    end
end
