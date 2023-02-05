//-----------------------------------------------------------------------------
// Title            : 
// Project          : 
//-----------------------------------------------------------------------------
// File             : <TODO>
// Original Author  : 
// Code Owner       : 
// Created          : 
//-----------------------------------------------------------------------------
// Description : 
//
//
//-----------------------------------------------------------------------------
`include "macros.sv"

module  cache_tq 
    import cache_param_pkg::*;  
(
    input   logic           clk,        
    input   logic           rst,        
    //core Interface
    input   var t_req       core2cache_req,
    output  logic           stall,
    output  t_rd_rsp        cache2core_rsp,
    //FM Interface
    input   var t_fm_rd_rsp fm2cache_rd_rsp,
    //output 
    //Pipe Interface
    output  t_lu_req        pipe_lu_req_q1,
    input   var t_lu_rsp    pipe_lu_rsp_q3
);
t_tq_state tq_state;
t_tq_state next_tq_state;
assign stall            = '0;

assign pipe_lu_req_q1.valid   = core2cache_req.valid;
assign pipe_lu_req_q1.lu_op   = (core2cache_req.opcode == WR_OP) ? WR_LU :
                                (core2cache_req.opcode == RD_OP) ? RD_LU :
                                                                   NO_LU ;
assign pipe_lu_req_q1.address = core2cache_req.address;
assign pipe_lu_req_q1.cl_data = '0;
assign pipe_lu_req_q1.data    = core2cache_req.data;
assign pipe_lu_req_q1.tq_id   = 5'd3;//FIXME



assign cache2core_rsp.valid =   pipe_lu_rsp_q3.valid                && 
                                (pipe_lu_rsp_q3.lu_opcode == RD_LU) &&
                                (pipe_lu_rsp_q3.lu_result == HIT);
//take the relevant word from cacheline
assign cache2core_rsp.data    = pipe_lu_rsp_q3.address[3:2] == 2'b00 ?  pipe_lu_rsp_q3.data[31:0]  : 
                                pipe_lu_rsp_q3.address[3:2] == 2'b01 ?  pipe_lu_rsp_q3.data[63:32] : 
                                pipe_lu_rsp_q3.address[3:2] == 2'b10 ?  pipe_lu_rsp_q3.data[95:64] :
                                                                        pipe_lu_rsp_q3.data[127:96];
assign cache2core_rsp.address = pipe_lu_rsp_q3.address; //FIXME: adress should come from tq_entry
assign cache2core_rsp.reg_id = '0; //FIXME



always_comb begin
    for (int i=0; i<NUM_TQ_ENTRY; ++i) begin
        next_tq_state = tq_state;
        unique casez (tq_state)
            S_IDLE                : 
                //if core_req && tq_entry_winner : next_state == LU_CORE_WR/RD_REQ 
                if (1'b1) begin
                    next_tq_state[i] =   (core2cache_req.opcode == RD_OP)     ?     S_LU_CORE_RD_REQ  :
                                         (core2cache_req.opcode == RD_OP)     ?     S_LU_CORE_WR_REQ  :
                                                                                    S_ERROR           ;
                end
            S_LU_CORE_WR_REQ              : 
                //if Cache_hit : nex_state == IDLE
                //if Cache_miss : next_state == MB_WAIT_FILL
                if ((pipe_lu_rsp_q3.tq_id == i) && (pipe_lu_rsp_q3.valid)) begin  
                    next_tq_state[i]=   (pipe_lu_rsp_q3.lu_result == HIT)     ?   S_IDLE            :
                                        (pipe_lu_rsp_q3.lu_result == MISS)    ?   S_MB_WAIT_FILL    :
                                        /*(pipe_lu_rsp_q3.lu_result == REJECT)*/  S_ERROR           ;
                end                    
               

            S_LU_CORE_RD_REQ              :
                //if Cache_hit : nex_state == IDLE
                //if Cache_miss : next_state == MB_WAIT_FILL
               if ((pipe_lu_rsp_q3.tq_id == i) && (pipe_lu_rsp_q3.valid)) begin  
                    next_tq_state[i]=   (pipe_lu_rsp_q3.lu_result == HIT)     ?   S_IDLE            :
                                        (pipe_lu_rsp_q3.lu_result == MISS)    ?   S_MB_WAIT_FILL    :
                                        /*(pipe_lu_rsp_q3.lu_result == REJECT)*/  S_ERROR           ;
                end                

            S_MB_WAIT_FILL                :
                next_tq_state = tq_state;
                //if fm_fill_rsp : nex_state == MB_FILL_READY


            S_MB_FILL_READY               :
                next_tq_state = tq_state;
                //if fill_winner : next_state == FILL_LU

            S_FILL_LU                     :
                next_tq_state = tq_state;
                //next_state == IDLE

            S_ERROR                       :
                next_tq_state = tq_state;

            default: begin
                next_tq_state = tq_state;
            end

        endcase //casez
    end //for loop   
end //always_comb


endmodule
