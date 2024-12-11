
`include "macros.vh"

module ifu_cache(

// Inputs
input logic Clock,
input logic Rst,
input logic [31:0] pc,

// Outputs
output logic [127:0] insLine,
output logic insLineValid

);

tag_arr_t tagArray [NUM_TAGS];
data_arr_t dataArray [NUM_LINES];
logic [TAG_WIDTH - OFFSET_WIDTH - 1 ] pcTag;

assign pcTag = pc[TAG_WIDTH-1:OFFSET]

`MAFIA_DFF_RST(tagArray.Valid,tagArray.Valid,Clock,Rst) // initiate Valid bits to 0 on Rst


always_ff@(posedge clk) begin

    insLineValid <= 0;
    for (int i = 0 ; i < NUM_TAGS ; i++) begin
        if(!tagArray[i].Valid) begin
            tagArray[i].evacuation <= 1;
        end else begin
            if(tagArray[i].tag == pcTag) begin
                insLineValid <= 1;
                insLine <= dataArray[i];
                break;
            end
        end
    end
end



endmodule