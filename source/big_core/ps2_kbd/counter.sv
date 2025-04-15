module counter(

    input logic clk,
    input logic rst,
   //  input  logic count_enable,
    output logic [3:0] count,
    output logic count_end

);

logic init = 0;
always_ff @( posedge clk or negedge rst ) begin 

    if (!rst) begin
        count <= 4'd0;
        count_end <= 1'd0;
    end

    else if (!init) begin
        count<=4'd0;
        count_end<=1'd0;
        init = 1'd1;
    end

    
     else if (count == 4'd9) begin  // 0 to 9 = 10 cycles
        count <= 4'd0;
          count_end <= 1'd1;
         end
    else begin
         count <= count + 4'd1;
         count_end <= 1'd0;
         end

    end


   
    





endmodule