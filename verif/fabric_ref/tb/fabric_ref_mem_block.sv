//-----------------------------------------------------------------------------
// Title            : fabric reference model memory block
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : fabric_ref_mem_block.sv
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 8/2026
//-----------------------------------------------------------------------------
// Description :
// One memory block of the fabric reference model unified memory (issue #454).
//
// The unified memory is deliberately NOT one massive array. It is split by
// kind into separate blocks, and this module is instantiated once per kind:
//
//   IMEM : N_BLOCKS = N_TILES, BLOCK_SIZE = 64KB  - one slice per tile
//   DMEM : N_BLOCKS = N_TILES, BLOCK_SIZE = 64KB  - one slice per tile
//   VGA  : N_BLOCKS = 1      , BLOCK_SIZE = 38400 - one frame buffer shared
//                                                   by the whole fabric
//
// Splitting this way means an instruction fetch never contends with a data
// access, and every core still reaches every tile's slice.
//
// Every port is served in the SAME cycle, with no arbitration and no stalls,
// which is what issue #454 asks for ("using a single cycle, it will read/write
// local and non-local memory"). Reads are combinational and therefore see the
// value from before the current clock edge, matching the next_dmem / DFF
// behaviour of the existing rv32i_ref model.
//
// Note on style: source/common/mem.sv writes memory with a full
// "next_mem = mem" array copy plus MAFIA_DFF. That costs a copy of the whole
// array every cycle, which at 9 tiles x 64KB x 2 blocks is over a megabyte per
// cycle and is far too slow for ModelSim ASE. This module therefore writes
// only the addressed bytes.
//-----------------------------------------------------------------------------

`include "macros.vh"

module fabric_ref_mem_block
import fabric_ref_pkg::*;
#(
    parameter N_BLOCKS         = 9,        // independent slices inside this block
    parameter BLOCK_SIZE       = 65536,    // bytes per slice
    parameter N_PORTS          = 9,        // one port per core
    parameter BLOCK_IDX_WIDTH  = 4,
    parameter PORT_OFFSET_WIDTH= 16,
    parameter CLEAR_ON_RST     = 0,        // used by the VGA frame buffer
    parameter BLOCK_NAME       = "MEM"     // for assertion messages only
) (
    input  logic                                       clk,
    input  logic                                       rst,
    // assertion enable, same idea as en_assert in d_cache_tq.sv. Normal users
    // tie this to 1'b1. The test bench lowers it only when it deliberately
    // provokes an illegal access to prove the detection logic works.
    input  logic                                       assert_en,
    // one request port per core, all served in the same cycle
    input  var logic [N_PORTS-1:0]                         port_valid,
    input  var logic [N_PORTS-1:0]                         port_wr_en,
    input  var logic [N_PORTS-1:0][3:0]                    port_byte_en,
    input  var logic [N_PORTS-1:0][BLOCK_IDX_WIDTH-1:0]    port_block_idx,
    input  var logic [N_PORTS-1:0][PORT_OFFSET_WIDTH-1:0]  port_offset,
    input  var logic [N_PORTS-1:0][31:0]                   port_wr_data,
    output var logic [N_PORTS-1:0][31:0]                   port_rd_data
);

//=======================================================
// The memory array - [slice][byte]
//=======================================================
logic [7:0] mem [N_BLOCKS-1:0][BLOCK_SIZE-1:0];

logic [N_PORTS-1:0] port_rd_active;
logic [N_PORTS-1:0] port_wr_active;
logic [N_PORTS-1:0] port_range_error;
logic [N_PORTS-1:0] port_block_error;

//=======================================================
// Request qualification and bounds checking
// A reference model should fail loudly on a rogue access instead of
// silently reading or corrupting an unrelated location.
//=======================================================
always_comb begin
    for (int p = 0; p < N_PORTS; p++) begin
        port_rd_active  [p] = port_valid[p] && !port_wr_en[p];
        port_wr_active  [p] = port_valid[p] &&  port_wr_en[p];
        port_block_error[p] = port_valid[p] && (int'(port_block_idx[p]) >= N_BLOCKS);
        // a 32 bit access touches offset..offset+3, so the last legal offset
        // is BLOCK_SIZE-4
        port_range_error[p] = port_valid[p] && ((int'(port_offset[p]) + 3) >= BLOCK_SIZE);
    end
end

//=======================================================
// Read - combinational, every port in the same cycle
//=======================================================
always_comb begin
    for (int p = 0; p < N_PORTS; p++) begin
        port_rd_data[p] = 32'b0;
        if (port_rd_active[p] && !port_range_error[p] && !port_block_error[p]) begin
            for (int b = 0; b < 4; b++) begin
                port_rd_data[p][8*b +: 8] = mem[int'(port_block_idx[p])][int'(port_offset[p]) + b];
            end
        end
    end
end

//=======================================================
// Write - only the addressed bytes are touched
//=======================================================
always_ff @(posedge clk) begin
    if (rst && (CLEAR_ON_RST != 0)) begin
        for (int n = 0; n < N_BLOCKS; n++) begin
            for (int a = 0; a < BLOCK_SIZE; a++) begin
                mem[n][a] <= 8'b0;
            end
        end
    end
    for (int p = 0; p < N_PORTS; p++) begin
        if (port_wr_active[p] && !port_range_error[p] && !port_block_error[p]) begin
            for (int b = 0; b < 4; b++) begin
                if (port_byte_en[p][b]) begin
                    mem[int'(port_block_idx[p])][int'(port_offset[p]) + b] <= port_wr_data[p][8*b +: 8];
                end
            end
        end
    end
end

//=======================================================
// Write collision detection
// Two cores writing different bytes in the same cycle is legal and is the
// whole point of splitting the memory. Two cores writing the SAME byte in the
// same cycle is a real race in the software, so report it loudly.
//=======================================================
logic       wr_collision;
int         collision_port_a;
int         collision_port_b;
int         collision_block;
int         collision_byte;

always_comb begin
    wr_collision     = 1'b0;
    collision_port_a = 0;
    collision_port_b = 0;
    collision_block  = 0;
    collision_byte   = 0;
    for (int a = 0; a < N_PORTS; a++) begin
        for (int b = a + 1; b < N_PORTS; b++) begin
            if (port_wr_active[a] && port_wr_active[b] &&
                (port_block_idx[a] == port_block_idx[b])) begin
                for (int i = 0; i < 4; i++) begin
                    for (int j = 0; j < 4; j++) begin
                        if (port_byte_en[a][i] && port_byte_en[b][j] &&
                            ((int'(port_offset[a]) + i) == (int'(port_offset[b]) + j))) begin
                            wr_collision     = 1'b1;
                            collision_port_a = a;
                            collision_port_b = b;
                            collision_block  = int'(port_block_idx[a]);
                            collision_byte   = int'(port_offset[a]) + i;
                        end
                    end
                end
            end
        end
    end
end

//=======================================================
// Assertions
//=======================================================
`MAFIA_ASSERT("fabric_ref_mem_wr_collision", wr_collision, assert_en,
              $sformatf("%s: ports %0d and %0d both wrote slice %0d byte 0x%0h in the same cycle",
                        BLOCK_NAME, collision_port_a, collision_port_b, collision_block, collision_byte))

`MAFIA_ASSERT("fabric_ref_mem_range_error", (|port_range_error), assert_en,
              $sformatf("%s: access past the end of a %0d byte slice, port_range_error = 0b%b",
                        BLOCK_NAME, BLOCK_SIZE, port_range_error))

`MAFIA_ASSERT("fabric_ref_mem_block_error", (|port_block_error), assert_en,
              $sformatf("%s: slice index out of range, only %0d slices exist, port_block_error = 0b%b",
                        BLOCK_NAME, N_BLOCKS, port_block_error))

endmodule
