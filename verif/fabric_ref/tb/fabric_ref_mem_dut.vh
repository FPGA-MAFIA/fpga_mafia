//-----------------------------------------------------------------------------
// Title            : fabric reference model memory block DUT instances
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : fabric_ref_mem_dut.vh
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 8/2026
//-----------------------------------------------------------------------------
// Description :
// Port signals and the three memory block instances of the unified memory,
// included from fabric_ref_tb. Same convention as
// verif/fabric/tb/router/router_dut.vh
//
//   imem_block : one 64KB slice per tile
//   dmem_block : one 64KB slice per tile
//   vga_block  : a single 38400 byte frame buffer shared by the whole fabric
//-----------------------------------------------------------------------------

// Assertion enable shared by the three blocks. Held high for normal traffic,
// lowered only while the test deliberately provokes an illegal access.
logic                                     mem_assert_en;

//=======================================================
// IMEM block ports
//=======================================================
logic [N_TILES-1:0]                       imem_valid;
logic [N_TILES-1:0]                       imem_wr_en;
logic [N_TILES-1:0][3:0]                  imem_byte_en;
logic [N_TILES-1:0][TILE_IDX_WIDTH-1:0]   imem_block_idx;
logic [N_TILES-1:0][OFFSET_WIDTH-1:0]     imem_offset;
logic [N_TILES-1:0][31:0]                 imem_wr_data;
logic [N_TILES-1:0][31:0]                 imem_rd_data;

//=======================================================
// DMEM block ports
//=======================================================
logic [N_TILES-1:0]                       dmem_valid;
logic [N_TILES-1:0]                       dmem_wr_en;
logic [N_TILES-1:0][3:0]                  dmem_byte_en;
logic [N_TILES-1:0][TILE_IDX_WIDTH-1:0]   dmem_block_idx;
logic [N_TILES-1:0][OFFSET_WIDTH-1:0]     dmem_offset;
logic [N_TILES-1:0][31:0]                 dmem_wr_data;
logic [N_TILES-1:0][31:0]                 dmem_rd_data;

//=======================================================
// VGA block ports - a single shared slice, so block_idx is always 0
//=======================================================
logic [N_TILES-1:0]                       vga_valid;
logic [N_TILES-1:0]                       vga_wr_en;
logic [N_TILES-1:0][3:0]                  vga_byte_en;
logic [N_TILES-1:0][0:0]                  vga_block_idx;
logic [N_TILES-1:0][OFFSET_WIDTH-1:0]     vga_offset;
logic [N_TILES-1:0][31:0]                 vga_wr_data;
logic [N_TILES-1:0][31:0]                 vga_rd_data;

//=======================================================
// Instances
//=======================================================
fabric_ref_mem_block #(
    .N_BLOCKS          (N_TILES),
    .BLOCK_SIZE        (MEM_BLOCK_SIZE),
    .N_PORTS           (N_TILES),
    .BLOCK_IDX_WIDTH   (TILE_IDX_WIDTH),
    .PORT_OFFSET_WIDTH (OFFSET_WIDTH),
    .CLEAR_ON_RST      (0),
    .BLOCK_NAME        ("IMEM")
) imem_block (
    .clk            (clk),
    .rst            (rst),
    .assert_en      (mem_assert_en),
    .port_valid     (imem_valid),
    .port_wr_en     (imem_wr_en),
    .port_byte_en   (imem_byte_en),
    .port_block_idx (imem_block_idx),
    .port_offset    (imem_offset),
    .port_wr_data   (imem_wr_data),
    .port_rd_data   (imem_rd_data)
);

fabric_ref_mem_block #(
    .N_BLOCKS          (N_TILES),
    .BLOCK_SIZE        (MEM_BLOCK_SIZE),
    .N_PORTS           (N_TILES),
    .BLOCK_IDX_WIDTH   (TILE_IDX_WIDTH),
    .PORT_OFFSET_WIDTH (OFFSET_WIDTH),
    .CLEAR_ON_RST      (0),
    .BLOCK_NAME        ("DMEM")
) dmem_block (
    .clk            (clk),
    .rst            (rst),
    .assert_en      (mem_assert_en),
    .port_valid     (dmem_valid),
    .port_wr_en     (dmem_wr_en),
    .port_byte_en   (dmem_byte_en),
    .port_block_idx (dmem_block_idx),
    .port_offset    (dmem_offset),
    .port_wr_data   (dmem_wr_data),
    .port_rd_data   (dmem_rd_data)
);

fabric_ref_mem_block #(
    .N_BLOCKS          (1),
    .BLOCK_SIZE        (SIZE_VGA_MEM),
    .N_PORTS           (N_TILES),
    .BLOCK_IDX_WIDTH   (1),
    .PORT_OFFSET_WIDTH (OFFSET_WIDTH),
    .CLEAR_ON_RST      (1),
    .BLOCK_NAME        ("VGA")
) vga_block (
    .clk            (clk),
    .rst            (rst),
    .assert_en      (mem_assert_en),
    .port_valid     (vga_valid),
    .port_wr_en     (vga_wr_en),
    .port_byte_en   (vga_byte_en),
    .port_block_idx (vga_block_idx),
    .port_offset    (vga_offset),
    .port_wr_data   (vga_wr_data),
    .port_rd_data   (vga_rd_data)
);
