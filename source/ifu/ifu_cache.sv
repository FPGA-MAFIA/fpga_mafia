
`include "macros.vh"



module ifu_cache
import ifu_pkg::*;
#( 
    parameter NUM_TAGS,      // Number of tags
    parameter NUM_LINES,     // Number of lines: should be equal to number of tags
    parameter TAG_WIDTH,     // Width of each tag: evacuation_bit + valid_bit + tag_bits = 1 + 1 + 28
    parameter LINE_WIDTH,    // Width of each cache line
    parameter OFFSET_WIDTH
)
(
// Inputs
input logic Clock,
input logic Rst,
input logic [31:0] pc,
input logic [127:0] insLineIn,
input logic insLineValidIn,

// Outputs
output logic [127:0] insLineOut,
output logic insLineValidOut

);

tag_arr_t tagArray [NUM_TAGS];
data_arr_t dataArray [NUM_LINES];
logic [TAG_WIDTH - OFFSET_WIDTH - 1 : 0 ] pcTag;

assign pcTag = pc[TAG_WIDTH-1:OFFSET_WIDTH];

always_ff@(posedge Rst) begin
    if (Rst) begin
        for (int i = 0 ; i < NUM_TAGS ; i++) begin
            tagArray[i] <= 0;
        end
    end
end

always_ff@(posedge Clock) begin
    
    if (!insLineValidOut && insLineValidIn) begin
        for (int i = 0 ; i < NUM_TAGS ; i++) begin
            if (!tagArray[i].valid) begin    
                dataArray[i] <= insLineIn;
                tagArray[i].valid <= 1'b1;
                tagArray[i].tag <= pcTag;
                insLineValidOut <= 1'b1;
                insLineOut <= insLineIn;
            end
        end
    end 
end

always_ff@(posedge Clock) begin
    
    insLineValidOut <= 0;
    for (int i = 0 ; i < NUM_TAGS ; i++) begin
        if(tagArray[i].tag == pcTag) begin
            insLineValidOut <= tagArray[i].valid;
            insLineOut <= dataArray[i];
        end
    end
end 



endmodule