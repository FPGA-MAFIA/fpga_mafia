module state_machine(

    input logic clk,
    input logic rst,
    output logic red,
    output logic yellow,
    output logic green
);


typedef enum logic[1:0]{
    RED =    2'b00,
    YELLOW = 2'b01,
    GREEN =  2'b10
}colours;

 logic [3:0] count;
 logic count_end;


colours current_colour,next_colour;
counter timer(

    .clk(clk),
    .rst(rst),
 //   .count_enable(1'b1),   // always count when FSM is active
    .count (count),
    .count_end(count_end)
);


always_ff @(posedge clk or negedge rst) begin

  if (!rst)
        current_colour <= RED;
 else if (count_end)
         current_colour <= next_colour;

end


always_comb begin

         red    = 0;
        yellow = 0;
        green  = 0;
        next_colour = current_colour;

    case(current_colour)

        RED: begin
          red = 1;
          if (count_end)  
          next_colour = YELLOW;
          
        end
        YELLOW: begin
          yellow = 1;
          if (count_end)  
          next_colour = GREEN;
          
        end

        GREEN: begin
          green = 1;
          if (count_end)  
          next_colour = RED;
          
        end

        default:begin
            red = 1;
            next_colour = RED;
        end

    endcase

end

endmodule