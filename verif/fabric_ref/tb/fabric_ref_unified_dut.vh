//-----------------------------------------------------------------------------
// Title            : fabric reference model unified memory DUT instance
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : fabric_ref_unified_dut.vh
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 8/2026
//-----------------------------------------------------------------------------
// Description :
// Instantiates the unified memory and declares the signals the test bench
// drives it with. Included from inside fabric_ref_tb, same convention as
// fabric_ref_mem_dut.vh.
//
// Here the test bench plays the part of the nine cores: one instruction fetch
// and at most one data access per tile, all presented in the same cycle.
//-----------------------------------------------------------------------------

logic                         uni_assert_en;

logic [N_TILES-1:0][31:0]     uni_fetch_addr;
logic [N_TILES-1:0][31:0]     uni_fetch_data;

logic [N_TILES-1:0]           uni_req_valid;
logic [N_TILES-1:0]           uni_req_wr_en;
logic [N_TILES-1:0][3:0]      uni_req_byte_en;
logic [N_TILES-1:0][31:0]     uni_req_address;
logic [N_TILES-1:0][31:0]     uni_req_wr_data;
logic [N_TILES-1:0][31:0]     uni_rsp_rd_data;

fabric_ref_mem u_unified_mem (
    .clk           (clk),
    .rst           (rst),
    .assert_en     (uni_assert_en),
    .i_fetch_addr  (uni_fetch_addr),
    .o_fetch_data  (uni_fetch_data),
    .i_req_valid   (uni_req_valid),
    .i_req_wr_en   (uni_req_wr_en),
    .i_req_byte_en (uni_req_byte_en),
    .i_req_address (uni_req_address),
    .i_req_wr_data (uni_req_wr_data),
    .o_rsp_rd_data (uni_rsp_rd_data)
);
