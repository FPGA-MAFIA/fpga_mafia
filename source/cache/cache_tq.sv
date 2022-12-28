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
    input   t_req           core2cache_req,
    output  logic           stall,
    output  t_rd_rsp        cache2core_rsp,
    //FM Inteface
    input   t_fm_rd_rsp     fm2cache_rd_rsp,
    output 
    //Pipe Interface
    output  t_lu_req        pipe_lu_req_q1,
    input   t_lu_rsp        pipe_lu_rsp_q3
);

    assign stall            = '0;
    assign cache2core_rsp   = '0;

assign pipe_lu_req_q1.valid   = core2cache_req.valid;
assign pipe_lu_req_q1.lu_op   = (core2cache_req.opcode == WR_OP) ? WR_LU :
                                (core2cache_req.opcode == RD_OP) ? RD_LU :
                                                                   NO_LU ;
assign pipe_lu_req_q1.address = core2cache_req.address;
assign pipe_lu_req_q1.cl_data    = core2cache_req.data;



assign cache2core_rsp.valid = pipe_lu_rsp_q3.valid
//take the relevant word from cacheline
assign cache2core_rsp.data    = pipe_lu_rsp_q3.address[3:2] == 2'b00 ?  pipe_lu_rsp_q3.data[31:0]  : 
                                pipe_lu_rsp_q3.address[3:2] == 2'b01 ?  pipe_lu_rsp_q3.data[63:32] : 
                                pipe_lu_rsp_q3.address[3:2] == 2'b10 ?  pipe_lu_rsp_q3.data[95:64] :
                                                                        pipe_lu_rsp_q3.data[127:96];
assign cache2core_rsp.address = pipe_lu_rsp_q3.address
assign cache2core_rsp.reg_id = '0; //FIXME



always_comb begin
    for (int i=0; i<NUM_TQ_ENTRY; ++i) begin
        next_tq_state = t_tq_state;
        unique casez (t_tq_state)
            IDLE                : 

            CORE_WR_REQ         :
            
            LU_CORE_WR_REQ      :

            CORE_RD_REQ         :

            LU_CORE_RD_REQ      :

            CORE_RD_RSP         :

            WAIT_FILL           :

            FILL                :

            LU_FILL             :

            ERROR               :

            default: begin
                next_tq_state = t_tq_state;
            end

        endcase //casez
    end //for loop   
end //always_comb


endmodule
