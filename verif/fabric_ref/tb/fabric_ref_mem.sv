//-----------------------------------------------------------------------------
// Title            : fabric reference model unified memory
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : fabric_ref_mem.sv
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 8/2026
//-----------------------------------------------------------------------------
// Description :
// The unified memory of the fabric reference model (github issue #454).
//
// This is the module that turns the separate memory blocks from
// fabric_ref_mem_block.sv into the single memory that every core sees. It does
// three things and nothing else:
//
//   1. Translates each core's virtual address with va2pa(), using that core's
//      own hardware tile id, so a tile id of 0x00 means "my own memory".
//   2. Steers the request to the block that owns the resolved region.
//   3. Muxes the read data back to the requesting core.
//
// Every core is served in the same cycle. There is no arbitration, no
// stalling and no ordering between cores, which is exactly what issue #454
// asks for. The blocks themselves detect the cases where that freedom is
// abused, for example two cores writing the same byte in the same cycle.
//
// Why the memory is split into blocks rather than one big array:
//   IMEM - instruction fetch, one 64KB slice per tile
//   DMEM - data, one 64KB slice per tile
//   VGA  - a single frame buffer shared by the whole fabric
//   CR   - memory mapped control registers, one 64KB slice per tile
// Fetch therefore never contends with data, and the shared frame buffer is
// the only place where cores deliberately meet.
//
// Each core drives two independent things: an instruction fetch, which is
// always active, and at most one data access. The IMEM block is given two
// ports per tile so that a core reading its own code as data cannot collide
// with its own fetch.
//-----------------------------------------------------------------------------

`include "macros.vh"

module fabric_ref_mem
import fabric_ref_pkg::*;
(
    input  logic                          clk,
    input  logic                          rst,
    // Lowered by a test bench that deliberately provokes an illegal access.
    // Normal users tie this high. Same idea as en_assert in d_cache_tq.sv.
    input  logic                          assert_en,
    //=======================================================
    // Instruction fetch, one per tile, always active
    //=======================================================
    input  var logic [N_TILES-1:0][31:0]  i_fetch_addr,
    output var logic [N_TILES-1:0][31:0]  o_fetch_data,
    //=======================================================
    // Data access, one per tile
    //=======================================================
    input  var logic [N_TILES-1:0]        i_req_valid,
    input  var logic [N_TILES-1:0]        i_req_wr_en,
    input  var logic [N_TILES-1:0][3:0]   i_req_byte_en,
    input  var logic [N_TILES-1:0][31:0]  i_req_address,
    input  var logic [N_TILES-1:0][31:0]  i_req_wr_data,
    output var logic [N_TILES-1:0][31:0]  o_rsp_rd_data
);

// The IMEM block carries the data ports first and the fetch ports second.
localparam N_IMEM_PORTS = 2 * N_TILES;
localparam CR_BLOCK_SIZE = CR_MEM_REGION_ROOF - CR_MEM_REGION_FLOOR + 1; // 64KB

//=======================================================
// Address translation
// Each core's hardware tile id is a fixed function of its index, the same
// mapping the fabric generate loop uses, so it does not need to be a port.
//=======================================================
t_ref_pa data_pa  [N_TILES-1:0];
t_ref_pa fetch_pa [N_TILES-1:0];

always_comb begin
    for (int p = 0; p < N_TILES; p++) begin
        data_pa [p] = va2pa(tile_id_from_idx(p), i_req_address[p]);
        fetch_pa[p] = va2pa(tile_id_from_idx(p), i_fetch_addr [p]);
    end
end

//=======================================================
// Per region request steering
//=======================================================
logic [N_IMEM_PORTS-1:0]        imem_valid, imem_wr_en;
logic [N_IMEM_PORTS-1:0][3:0]   imem_byte_en;
logic [N_IMEM_PORTS-1:0][3:0]   imem_block_idx;
logic [N_IMEM_PORTS-1:0][15:0]  imem_offset;
logic [N_IMEM_PORTS-1:0][31:0]  imem_wr_data;
logic [N_IMEM_PORTS-1:0][31:0]  imem_rd_data;

logic [N_TILES-1:0]        dmem_valid, dmem_wr_en;
logic [N_TILES-1:0][3:0]   dmem_byte_en;
logic [N_TILES-1:0][3:0]   dmem_block_idx;
logic [N_TILES-1:0][15:0]  dmem_offset;
logic [N_TILES-1:0][31:0]  dmem_wr_data;
logic [N_TILES-1:0][31:0]  dmem_rd_data;

logic [N_TILES-1:0]        vga_valid, vga_wr_en;
logic [N_TILES-1:0][3:0]   vga_byte_en;
logic [N_TILES-1:0][3:0]   vga_block_idx;
logic [N_TILES-1:0][15:0]  vga_offset;
logic [N_TILES-1:0][31:0]  vga_wr_data;
logic [N_TILES-1:0][31:0]  vga_rd_data;

logic [N_TILES-1:0]        cr_valid, cr_wr_en;
logic [N_TILES-1:0][3:0]   cr_byte_en;
logic [N_TILES-1:0][3:0]   cr_block_idx;
logic [N_TILES-1:0][15:0]  cr_offset;
logic [N_TILES-1:0][31:0]  cr_wr_data;
logic [N_TILES-1:0][31:0]  cr_rd_data;

// Error flags, collected for the assertions below
logic [N_TILES-1:0] req_rsvd_error;
logic [N_TILES-1:0] req_tile_error;
logic [N_TILES-1:0] req_who_am_i;
logic [N_TILES-1:0] fetch_region_error;

always_comb begin
    imem_valid = '0; imem_wr_en = '0; imem_byte_en = '0;
    imem_block_idx = '0; imem_offset = '0; imem_wr_data = '0;
    dmem_valid = '0; dmem_wr_en = '0; dmem_byte_en = '0;
    dmem_block_idx = '0; dmem_offset = '0; dmem_wr_data = '0;
    vga_valid  = '0; vga_wr_en  = '0; vga_byte_en  = '0;
    vga_block_idx  = '0; vga_offset  = '0; vga_wr_data  = '0;
    cr_valid   = '0; cr_wr_en   = '0; cr_byte_en   = '0;
    cr_block_idx   = '0; cr_offset   = '0; cr_wr_data   = '0;
    req_rsvd_error     = '0;
    req_tile_error     = '0;
    req_who_am_i       = '0;
    fetch_region_error = '0;

    //---------------------------------------------------
    // Data accesses land on ports 0..N_TILES-1
    //---------------------------------------------------
    for (int p = 0; p < N_TILES; p++) begin
        if (i_req_valid[p]) begin
            req_rsvd_error[p] = data_pa[p].rsvd_error;
            req_tile_error[p] = data_pa[p].tile_error;
            req_who_am_i  [p] = (data_pa[p].region == REGION_WHO_AM_I);
            // A broken address is reported, never forwarded. Forwarding it
            // would corrupt whatever block it happened to alias onto.
            if (!data_pa[p].rsvd_error && !data_pa[p].tile_error) begin
                case (data_pa[p].region)
                    REGION_IMEM: begin
                        imem_valid    [p] = 1'b1;
                        imem_wr_en    [p] = i_req_wr_en  [p];
                        imem_byte_en  [p] = i_req_byte_en[p];
                        imem_block_idx[p] = data_pa[p].tile_idx;
                        imem_offset   [p] = data_pa[p].offset;
                        imem_wr_data  [p] = i_req_wr_data[p];
                    end
                    REGION_DMEM: begin
                        dmem_valid    [p] = 1'b1;
                        dmem_wr_en    [p] = i_req_wr_en  [p];
                        dmem_byte_en  [p] = i_req_byte_en[p];
                        dmem_block_idx[p] = data_pa[p].tile_idx;
                        dmem_offset   [p] = data_pa[p].offset;
                        dmem_wr_data  [p] = i_req_wr_data[p];
                    end
                    REGION_VGA: begin
                        // one frame buffer for the whole fabric, slice 0
                        vga_valid    [p] = 1'b1;
                        vga_wr_en    [p] = i_req_wr_en  [p];
                        vga_byte_en  [p] = i_req_byte_en[p];
                        vga_block_idx[p] = 4'b0;
                        vga_offset   [p] = data_pa[p].offset;
                        vga_wr_data  [p] = i_req_wr_data[p];
                    end
                    REGION_CR: begin
                        cr_valid    [p] = 1'b1;
                        cr_wr_en    [p] = i_req_wr_en  [p];
                        cr_byte_en  [p] = i_req_byte_en[p];
                        cr_block_idx[p] = data_pa[p].tile_idx;
                        cr_offset   [p] = data_pa[p].offset;
                        cr_wr_data  [p] = i_req_wr_data[p];
                    end
                    default: ; // WhoAmI is answered by the core, NONE is an error
                endcase
            end
        end
    end

    //---------------------------------------------------
    // Instruction fetches land on ports N_TILES..2*N_TILES-1.
    // A fetch is always a read of a full word from IMEM.
    //---------------------------------------------------
    // Nothing fetches during reset, when the cores' PCs are not yet valid.
    for (int p = 0; p < N_TILES; p++) begin
        fetch_region_error[p] = !rst && ((fetch_pa[p].region != REGION_IMEM) ||
                                          fetch_pa[p].rsvd_error || fetch_pa[p].tile_error);
        if (!rst && !fetch_region_error[p]) begin
            imem_valid    [N_TILES + p] = 1'b1;
            imem_wr_en    [N_TILES + p] = 1'b0;
            imem_byte_en  [N_TILES + p] = 4'hF;
            imem_block_idx[N_TILES + p] = fetch_pa[p].tile_idx;
            imem_offset   [N_TILES + p] = fetch_pa[p].offset;
        end
    end
end

//=======================================================
// The memory blocks
//=======================================================
fabric_ref_mem_block #(
    .N_BLOCKS         (N_TILES),
    .BLOCK_SIZE       (MEM_BLOCK_SIZE),
    .N_PORTS          (N_IMEM_PORTS),
    .BLOCK_IDX_WIDTH  (TILE_IDX_WIDTH),
    .PORT_OFFSET_WIDTH(OFFSET_WIDTH),
    .CLEAR_ON_RST     (0),
    .BLOCK_NAME       ("IMEM")
) imem_block (
    .clk           (clk),
    .rst           (rst),
    .assert_en     (assert_en),
    .port_valid    (imem_valid),
    .port_wr_en    (imem_wr_en),
    .port_byte_en  (imem_byte_en),
    .port_block_idx(imem_block_idx),
    .port_offset   (imem_offset),
    .port_wr_data  (imem_wr_data),
    .port_rd_data  (imem_rd_data)
);

fabric_ref_mem_block #(
    .N_BLOCKS         (N_TILES),
    .BLOCK_SIZE       (MEM_BLOCK_SIZE),
    .N_PORTS          (N_TILES),
    .BLOCK_IDX_WIDTH  (TILE_IDX_WIDTH),
    .PORT_OFFSET_WIDTH(OFFSET_WIDTH),
    .CLEAR_ON_RST     (0),
    .BLOCK_NAME       ("DMEM")
) dmem_block (
    .clk           (clk),
    .rst           (rst),
    .assert_en     (assert_en),
    .port_valid    (dmem_valid),
    .port_wr_en    (dmem_wr_en),
    .port_byte_en  (dmem_byte_en),
    .port_block_idx(dmem_block_idx),
    .port_offset   (dmem_offset),
    .port_wr_data  (dmem_wr_data),
    .port_rd_data  (dmem_rd_data)
);

fabric_ref_mem_block #(
    .N_BLOCKS         (1),
    .BLOCK_SIZE       (SIZE_VGA_MEM),
    .N_PORTS          (N_TILES),
    .BLOCK_IDX_WIDTH  (TILE_IDX_WIDTH),
    .PORT_OFFSET_WIDTH(OFFSET_WIDTH),
    .CLEAR_ON_RST     (1),
    .BLOCK_NAME       ("VGA")
) vga_block (
    .clk           (clk),
    .rst           (rst),
    .assert_en     (assert_en),
    .port_valid    (vga_valid),
    .port_wr_en    (vga_wr_en),
    .port_byte_en  (vga_byte_en),
    .port_block_idx(vga_block_idx),
    .port_offset   (vga_offset),
    .port_wr_data  (vga_wr_data),
    .port_rd_data  (vga_rd_data)
);

fabric_ref_mem_block #(
    .N_BLOCKS         (N_TILES),
    .BLOCK_SIZE       (CR_BLOCK_SIZE),
    .N_PORTS          (N_TILES),
    .BLOCK_IDX_WIDTH  (TILE_IDX_WIDTH),
    .PORT_OFFSET_WIDTH(OFFSET_WIDTH),
    .CLEAR_ON_RST     (1),
    .BLOCK_NAME       ("CR")
) cr_block (
    .clk           (clk),
    .rst           (rst),
    .assert_en     (assert_en),
    .port_valid    (cr_valid),
    .port_wr_en    (cr_wr_en),
    .port_byte_en  (cr_byte_en),
    .port_block_idx(cr_block_idx),
    .port_offset   (cr_offset),
    .port_wr_data  (cr_wr_data),
    .port_rd_data  (cr_rd_data)
);

//=======================================================
// Response mux
//=======================================================
always_comb begin
    for (int p = 0; p < N_TILES; p++) begin
        case (data_pa[p].region)
            REGION_IMEM: o_rsp_rd_data[p] = imem_rd_data[p];
            REGION_DMEM: o_rsp_rd_data[p] = dmem_rd_data[p];
            REGION_VGA : o_rsp_rd_data[p] = vga_rd_data [p];
            REGION_CR  : o_rsp_rd_data[p] = cr_rd_data  [p];
            default    : o_rsp_rd_data[p] = 32'b0;
        endcase
        o_fetch_data[p] = imem_rd_data[N_TILES + p];
    end
end

//=======================================================
// Assertions
// A reference model should stop on a bad address instead of quietly
// returning zero, which is the kind of bug that costs days to find.
//=======================================================
`MAFIA_ASSERT("fabric_ref_mem_rsvd_error", (|req_rsvd_error), assert_en,
              $sformatf("address bits [%0d:%0d] must be zero, offending tiles = 0b%b",
                        RSVD_MSB, RSVD_LSB, req_rsvd_error))

`MAFIA_ASSERT("fabric_ref_mem_tile_error", (|req_tile_error), assert_en,
              $sformatf("access to a tile id that does not exist in the %0dx%0d mesh, offending tiles = 0b%b",
                        N_COL, N_ROW, req_tile_error))

`MAFIA_ASSERT("fabric_ref_mem_who_am_i", (|req_who_am_i), assert_en,
              $sformatf("WhoAmI must be answered by the core itself and never reach memory, offending tiles = 0b%b",
                        req_who_am_i))

`MAFIA_ASSERT("fabric_ref_mem_fetch_error", (|fetch_region_error), assert_en,
              $sformatf("instruction fetch outside of the IMEM region, offending tiles = 0b%b",
                        fetch_region_error))

endmodule
