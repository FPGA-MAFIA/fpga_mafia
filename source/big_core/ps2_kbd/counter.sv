module counter(

    input logic clk,
    input logic rst,
    output logic [3:0] count,
    output logic count_end

);


always_ff @( posedge clk or negedge rst ) begin 

    if (!rst) begin
        count <= 4'd0;
        count_end <= 1'd0;
    end

    else if (count == 4'd10) begin

    count <= 4'd0;
    count_end <= 1'd1;

    end

    else
    count <= count + 4'd1;

    
end




endmodule