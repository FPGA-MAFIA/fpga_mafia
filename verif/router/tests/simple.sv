//var t_tile_trans simple_trans [3:0];
//automatic randomize(seed = $random);
//for (int i = 0; i<4; i++)begin
//    randomize(simple_trans[i]);
//    push_fifo(i);
//    delay(3);
//end
for (int i = 0; i<4; i++)begin
    gen_trans(i);
    delay(3);
end
