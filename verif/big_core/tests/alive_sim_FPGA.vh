Button_0 = 1'b0;
Button_1 = 1'b0;
for(int i=0;i<1000;i=i+1) begin
   //random delay between 1 and 10
   delay($urandom_range(1,10));
   Switch[9:0]   = $urandom_range(1,1023);
end