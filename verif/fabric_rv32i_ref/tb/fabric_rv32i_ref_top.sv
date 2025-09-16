//=============================================================
// fabric_rv32i_ref_top.sv
//
// 9-core RV32I reference model with shared memory
// - All 9 cores can read simultaneously
// - Some core can read and some can write simultaneously
// - Only one core can write to specific memory per cycle (priority: lowest index wins)
// - Byte-enable supported for writes (per 8-bit lane)
//
// DATA_WIDTH = 32 bits → byteena = 4 bits
//   byteena[0] → enable write to bits [7:0]
//   byteena[1] → enable write to bits [15:8]
//   byteena[2] → enable write to bits [23:16]
//   byteena[3] → enable write to bits [31:24]
//
//=============================================================

`include "macros.vh"

module fabric_rv32i_ref_top
import fabric_rv32i_ref_pkg::*;
(
    input  logic clk,   // system clock
    input  logic rst,   // synchronous reset
    input  logic run    // run enable for all cores
);

    // -------------------------------
    // PARAMETERS
    // -------------------------------
    localparam int N_CORES    = 9;    // number of cores
    localparam int GRID_ROWS  = 3;    // 3x3 mesh
    localparam int GRID_COLS  = 3;
    localparam int ADRS_WIDTH = 29;   // address width
    localparam int DATA_WIDTH = 32;   // memory word width

    localparam int PER_TILE_SIZE = (1 << ADRS_WIDTH) / N_CORES;

    // -------------------------------
    // PER-CORE SIGNALS
    // -------------------------------
    logic [N_CORES-1:0]                 wr_en, rd_en;
    logic [N_CORES-1:0][ADRS_WIDTH-1:0] address_local;
    logic [N_CORES-1:0][DATA_WIDTH-1:0] wdata, rdata;
    logic [N_CORES-1:0][3:0]            byteena;   // one nibble per byte
    logic [N_CORES-1:0][7:0]            tileId;    // {row, col}

    // Global addresses for all cores
    logic [N_CORES-1:0][ADRS_WIDTH-1:0] address_global;

    // -------------------------------
    // TILE-ID TO GLOBAL ADDRESS
    // -------------------------------
    always_comb begin
        for (int i = 0; i < N_CORES; i++) begin
            logic [3:0] row = tileId[i][7:4];   // Tile row
            logic [3:0] col = tileId[i][3:0];   // Tile column
            logic [3:0] tile_index = row * GRID_COLS + col;

            // Each tile gets a disjoint memory slice
            address_global[i] = tile_index * PER_TILE_SIZE + address_local[i];
        end
    end

    // -------------------------------
    // INSTANTIATE CORES
    // -------------------------------
    genvar i;
    generate
        for (i = 0; i < N_CORES; i++) begin : gen_cores
            fabric_rv32i_ref core_i (
                .clk(clk),
                .rst(rst),
                .run(run),
                .core2mem_req.WrEn   (wr_en[i]),
                .core2mem_req.RdEn   (rd_en[i]),
                .core2mem_req.Address(address_local[i]),
                .core2mem_req.Data   (wdata[i]),
                .core2mem_req.ByteEn (byteena[i]),
                .core2mem_req.TileId (tileId[i]),
                .mem_rdata           (rdata[i])
            );
        end
    endgenerate

    // -------------------------------
    // SHARED MEMORY MODEL
    // -------------------------------
    logic [DATA_WIDTH-1:0] mem_array [0:(1<<ADRS_WIDTH)-1];

    // ---- WRITE PORT ----
// Shared memory: one port for write
always_ff @(posedge clk) begin
    if (wren_mux) begin
        for (int b=0; b<4; b++) begin
            if (byteena_mux[b]) begin
                shared_mem[address_mux][8*b +: 8] <= wdata_mux[8*b +: 8];
            end
        end
    end
end



    // ---- READ PORTS ----
    always_comb begin
        for (int c = 0; c < N_CORES; c++) begin
            if (rd_en[c])
                rdata[c] = mem_array[address_global[c]]; // parallel read
            else
                rdata[c] = '0; // no read → return 0
        end
    end

endmodule
