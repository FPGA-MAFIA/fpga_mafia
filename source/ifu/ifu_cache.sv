
`include "macros.vh"

module ifu_cache(

// Inputs
input logic Clock,
input logic Rst,
input logic [31:0] pc,
input logic insLineIn,
input logic insLineValidIn,

// Outputs
output logic [127:0] insLineOut,
output logic insLineValidOut

);

tag_arr_t tagArray [NUM_TAGS];
data_arr_t dataArray [NUM_LINES];
logic [TAG_WIDTH - OFFSET_WIDTH - 1 ] pcTag;

assign pcTag = pc[TAG_WIDTH-1:OFFSET];

always_comb@ begin
    if(Rst) begin
        tagArray.Valid = '0;
    end
end

always_ff(posedge Clock) begin
    
    if (!insLineValidOut && insLineValidIn) begin
        for (int i = 0 ; i < NUM_TAGS ; i++) begin
            if (!tagArray[i].valid) begin    
                dataArray[i] <= insLineIn;
                tagArray[i].valid <= 1b'1;
                tagArray[i].tag <= pcTag;
                insLineValidOut <= 1b'1;
                insLineOut <= insLineIn;
            end
        end
    end  
end

always_ff@(posedge Clock) begin

    insLineValidOut <= 0;
    for (int i = 0 ; i < NUM_TAGS ; i++) begin
        if(tagArray[i].tag == pcTag) 
            insLineValidOut <= tagArray[i].Valid;
            insLineOut <= dataArray[i];
        end
    end
end



endmodule