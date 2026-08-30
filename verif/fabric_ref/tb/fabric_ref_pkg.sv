//-----------------------------------------------------------------------------
// Title            : fabric reference model package
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : fabric_ref_pkg.sv
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 8/2026
//-----------------------------------------------------------------------------
// Description :
// Types, parameters and the VA->PA translation used by the fabric reference
// model (github issue #454).
//
// The fabric reference model does not recreate the routers or the mesh.
// Instead every core reaches every tile's memory in a single cycle, and the
// address translation below is what decides which physical block and offset a
// given virtual address lands on.
//
// Address structure:
//
//   31    28 27    24 23      17   16    15               0
//  +--------+--------+-----------+-----+------------------+
//  | column |  row   | reserved  | I/D |      offset      |
//  +--------+--------+-----------+-----+------------------+
//       tile ID (8b)      = 0     0=I   16b into a 64KB block
//                                 1=D
//
// - The tile ID nibble order is {col,row}, matching the way the real fabric
//   builds local_tile_id in source/fabric/fabric.sv and the way the router
//   compares address[31:28] against a column in next_tile_fifo_arb.sv.
// - A tile ID of 0x00 is a VIRTUAL (local) access: it is translated to the
//   requesting core's OWN physical block using its hardware tile ID. This is
//   what lets a single binary run on all tiles.
// - A non zero tile ID is a physical cross region access, mapped directly to
//   the target core's block.
// - Bit [16] selects IMEM (0) or DMEM (1). This keeps the model compatible
//   with app/cfg/default.json (D_MEM_OFFSET = 65536) and with the scratch
//   addresses in app/defines/fabric_defines.h (offset 0x01F000).
// - Bits [23:17] are reserved and must be zero. A non zero value is reported
//   through rsvd_error so the model can fail loudly on a rogue pointer
//   instead of silently aliasing into another region.
// - The VGA / CR / WhoAmI windows legitimately use bits [23:16] and are
//   therefore decoded BEFORE the reserved bits check.
//-----------------------------------------------------------------------------

`ifndef FABRIC_REF_PKG_SV
`define FABRIC_REF_PKG_SV

package fabric_ref_pkg;

`include "common_pkg.vh"

//=======================================================
// Mesh geometry
//=======================================================
parameter N_ROW   = 3;
parameter N_COL   = 3;
parameter N_TILES = N_ROW * N_COL;

parameter TILE_IDX_WIDTH = 4; // enough to hold 0..N_TILES-1

//=======================================================
// Address field boundaries
//=======================================================
parameter COL_MSB      = 31;
parameter COL_LSB      = 28;
parameter ROW_MSB      = 27;
parameter ROW_LSB      = 24;
parameter RSVD_MSB     = 23;
parameter RSVD_LSB     = 17;
parameter ID_SEL_BIT   = 16; // 0 = IMEM, 1 = DMEM
parameter OFFSET_MSB   = 15;
parameter OFFSET_LSB   = 0;

parameter OFFSET_WIDTH   = OFFSET_MSB - OFFSET_LSB + 1; // 16
parameter MEM_BLOCK_SIZE = 1 << OFFSET_WIDTH;           // 64KB per block per tile

//=======================================================
// Special windows, decoded on the tile local address [23:0]
// Values match the ones already used by rv32i_ref and big_core_pkg
//=======================================================
parameter SIZE_VGA_MEM         = 38400;
parameter VGA_MEM_REGION_FLOOR = 24'hFF_0000;
parameter VGA_MEM_REGION_ROOF  = VGA_MEM_REGION_FLOOR + SIZE_VGA_MEM - 1;
parameter CR_MEM_REGION_FLOOR  = 24'hFE_0000;
parameter CR_MEM_REGION_ROOF   = 24'hFE_FFFF;
parameter WHO_AM_I_ADDRESS     = 24'hFF_FFFF;

//=======================================================
// Types
//=======================================================
typedef enum logic [2:0] {
    REGION_NONE     = 3'd0,
    REGION_IMEM     = 3'd1,
    REGION_DMEM     = 3'd2,
    REGION_VGA      = 3'd3,
    REGION_CR       = 3'd4,
    REGION_WHO_AM_I = 3'd5
} t_ref_region;

// A single core memory request. Byte enables follow the same convention as
// source/common/mem.sv - one bit per 8 bit lane of the 32 bit data word.
typedef struct packed {
    logic                    valid;
    logic                    wr_en;   // 1 = write, 0 = read
    logic [3:0]              byte_en;
    logic [31:0]             address; // virtual address as seen by the core
    logic [31:0]             data;    // write data
    t_tile_id                requestor_id;
} t_ref_mem_req;

typedef struct packed {
    logic [31:0]             data;
} t_ref_mem_rsp;

// The result of the VA->PA translation.
typedef struct packed {
    t_ref_region                region;
    t_tile_id                   tile_id;    // resolved tile id, after local aliasing
    logic [TILE_IDX_WIDTH-1:0]  tile_idx;   // flat index 0..N_TILES-1 into a memory block
    logic [OFFSET_WIDTH-1:0]    offset;     // byte offset inside the selected block
    logic                       rsvd_error; // reserved bits [23:17] were not zero
    logic                       tile_error; // resolved tile id is not present in the mesh
} t_ref_pa;

//=======================================================
// Tile id helpers
// col and row are 1 based, exactly like the generate loops in fabric.sv
//=======================================================
function automatic logic tile_id_is_legal(input t_tile_id id);
    logic [3:0] col;
    logic [3:0] row;
    col = id[7:4];
    row = id[3:0];
    return (col >= 4'd1) && (col <= N_COL) && (row >= 4'd1) && (row <= N_ROW);
endfunction

function automatic logic [TILE_IDX_WIDTH-1:0] tile_idx_from_id(input t_tile_id id);
    int col;
    int row;
    if (!tile_id_is_legal(id)) return '0; // caller must look at tile_error
    col = int'(id[7:4]);
    row = int'(id[3:0]);
    return TILE_IDX_WIDTH'(((col - 1) * N_ROW) + (row - 1));
endfunction

function automatic t_tile_id tile_id_from_idx(input int idx);
    int col;
    int row;
    col = (idx / N_ROW) + 1;
    row = (idx % N_ROW) + 1;
    return {4'(col), 4'(row)};
endfunction

//=======================================================
// VA -> PA translation
//=======================================================
function automatic t_ref_pa va2pa(input t_tile_id requestor_id, input logic [31:0] va);
    t_ref_pa     pa;
    logic [7:0]  tile_field;
    logic [23:0] tile_offset;

    tile_field  = va[31:24];
    tile_offset = va[23:0];

    // tile id 0x00 means "my own tile" -> virtual access resolved against the
    // requesting core's hardware id.
    pa.tile_id    = (tile_field == 8'h00) ? requestor_id : tile_field;
    pa.tile_idx   = tile_idx_from_id(pa.tile_id);
    pa.tile_error = !tile_id_is_legal(pa.tile_id);
    pa.rsvd_error = 1'b0;
    pa.region     = REGION_NONE;
    pa.offset     = '0;

    if (tile_offset == WHO_AM_I_ADDRESS) begin
        pa.region = REGION_WHO_AM_I;
    end
    else if ((tile_offset >= VGA_MEM_REGION_FLOOR) && (tile_offset <= VGA_MEM_REGION_ROOF)) begin
        // one VGA frame buffer is shared by the whole fabric, tile_idx is unused
        pa.region = REGION_VGA;
        pa.offset = OFFSET_WIDTH'(tile_offset - VGA_MEM_REGION_FLOOR);
    end
    else if ((tile_offset >= CR_MEM_REGION_FLOOR) && (tile_offset <= CR_MEM_REGION_ROOF)) begin
        pa.region = REGION_CR;
        pa.offset = tile_offset[OFFSET_MSB:OFFSET_LSB];
    end
    else if (tile_offset[RSVD_MSB:RSVD_LSB] != '0) begin
        // rogue pointer - do NOT alias it into some other tile's memory
        pa.region     = REGION_NONE;
        pa.rsvd_error = 1'b1;
    end
    else begin
        pa.region = tile_offset[ID_SEL_BIT] ? REGION_DMEM : REGION_IMEM;
        pa.offset = tile_offset[OFFSET_MSB:OFFSET_LSB];
    end

    return pa;
endfunction

endpackage

`endif //FABRIC_REF_PKG_SV
