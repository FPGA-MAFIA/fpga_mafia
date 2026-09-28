//-----------------------------------------------------------------------------
// Title            : fabric reference model top
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : fabric_ref_top.sv
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 8/2026
//-----------------------------------------------------------------------------
// Description :
// The fabric reference model of github issue #454: N_TILES RV32I cores sharing
// one unified memory.
//
// Each core is an rv32i_ref built with EXTERNAL_MEM = 1, so it has no private
// memory at all. Its instruction fetch and its data accesses both leave the
// core and are answered by fabric_ref_mem in the same cycle.
//
// The only thing that makes one core different from another is its TILE_ID,
// fixed here by the generate loop. That is what lets all nine cores run the
// very same binary: an address with a tile field of 0x00 is resolved against
// whichever core issued it, so "my scratch pad" means nine different places.
//
// There are no routers and no mesh here. This is a reference model, and its
// job is to define what the software should observe, not how the real fabric
// moves packets around to achieve it.
//-----------------------------------------------------------------------------

`include "macros.vh"

module fabric_ref_top
import fabric_ref_pkg::*;
(
    input  logic                clk,
    input  logic                rst,
    // Held low while the test bench loads the program, then raised to let all
    // of the cores go at once.
    input  logic                run,
    // Per tile status, collected here because a generate block cannot be
    // indexed with a variable from the test bench's procedural code.
    output logic [N_TILES-1:0]  o_tile_done,
    output logic [N_TILES-1:0]  o_tile_ebreak,
    output logic [N_TILES-1:0]  o_tile_ecall,
    output logic [N_TILES-1:0]  o_tile_illegal
);

//=======================================================
// Core to memory wiring
//=======================================================
logic [N_TILES-1:0][31:0] fetch_addr;
logic [N_TILES-1:0][31:0] fetch_data;
logic [N_TILES-1:0]       req_valid;
logic [N_TILES-1:0]       req_wr_en;
logic [N_TILES-1:0][3:0]  req_byte_en;
logic [N_TILES-1:0][31:0] req_address;
logic [N_TILES-1:0][31:0] req_wr_data;
logic [N_TILES-1:0][31:0] rsp_rd_data;

//=======================================================
// The cores
//=======================================================
genvar t;
generate
for (t = 0; t < N_TILES; t++) begin : gen_tile
    rv32i_ref #(
        .EXTERNAL_MEM (1),
        .TILE_ID      (tile_id_from_idx(t))
    ) core (
        .clk               (clk),
        .rst               (rst),
        .run               (run),
        .i_instruction     (fetch_data [t]),
        .i_mem_rd_data     (rsp_rd_data[t]),
        .o_imem_addr       (fetch_addr [t]),
        .o_mem_req_valid   (req_valid  [t]),
        .o_mem_req_wr_en   (req_wr_en  [t]),
        .o_mem_req_byte_en (req_byte_en[t]),
        .o_mem_req_address (req_address[t]),
        .o_mem_req_wr_data (req_wr_data[t])
    );

    // These are not module ports of rv32i_ref, so they are picked up
    // hierarchically. It is legal here because t is a genvar.
    assign o_tile_done   [t] = core.end_of_simulation;
    assign o_tile_ebreak [t] = core.ebreak_was_called;
    assign o_tile_ecall  [t] = core.ecall_was_called;
    assign o_tile_illegal[t] = core.illegal_instruction;
end
endgenerate

//=======================================================
// The unified memory
//=======================================================
fabric_ref_mem u_mem (
    .clk           (clk),
    .rst           (rst),
    .assert_en     (1'b1),
    .i_fetch_addr  (fetch_addr),
    .o_fetch_data  (fetch_data),
    .i_req_valid   (req_valid),
    .i_req_wr_en   (req_wr_en),
    .i_req_byte_en (req_byte_en),
    .i_req_address (req_address),
    .i_req_wr_data (req_wr_data),
    .o_rsp_rd_data (rsp_rd_data)
);

endmodule
