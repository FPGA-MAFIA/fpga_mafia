//-----------------------------------------------------------------------------
// Title            : fabric reference model per tile trackers
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : fabric_ref_trk.vh
// Original Author  : Noam Rahat
// Code Owner       : Noam Rahat
// Created          : 10/2026
//-----------------------------------------------------------------------------
// Description :
// Per tile trackers for fabric_ref_top_tb, in the style of rv32i_ref_trk.vh.
// Every tile gets two logs under target/fabric_ref/tests/<test>/ :
//
//   trk_tile_<id>_instret.log     one line per retired instruction
//   trk_tile_<id>_mem_access.log  one line per data access leaving the core
//
// The memory log prints the address the core issued next to where va2pa sent
// it, so a tile field of 0x00 can be seen resolving to the issuing tile, and a
// cross region access can be seen landing in another tile's slice.
//
// WHO_AM_I is answered inside the core and never reaches the memory, so it
// shows up in the instret log but not in the memory log.
//
// Only signals on the core to memory interface of fabric_ref_top are probed,
// never anything inside the cores. Reaching into gen_tile[t].core made the
// simulator keep the cores unoptimized and cost about ten times the run time.
// The PC is the fetch address and INSTRET the fetched word; the disassembly
// for a PC is in the test's gcc_files/*_elf.txt.
//-----------------------------------------------------------------------------

genvar trk_t;
generate
for (trk_t = 0; trk_t < N_TILES; trk_t++) begin : gen_trk
    localparam t_tile_id TRK_ID = tile_id_from_idx(trk_t);

    integer   trk_instret;
    integer   trk_mem_access;
    t_ref_pa  trk_pa;

    initial begin: trk_open
        #1
        trk_instret = $fopen($sformatf("../../../target/fabric_ref/tests/%s/trk_tile_%02h_instret.log",
                                       test_name, TRK_ID), "w");
        $fwrite(trk_instret, "---------------------------------------------------------\n");
        $fwrite(trk_instret, " Tile 0x%02h\n", TRK_ID);
        $fwrite(trk_instret, "  Time   |    PC    | INSTRET\n");
        $fwrite(trk_instret, "---------------------------------------------------------\n");

        trk_mem_access = $fopen($sformatf("../../../target/fabric_ref/tests/%s/trk_tile_%02h_mem_access.log",
                                          test_name, TRK_ID), "w");
        $fwrite(trk_mem_access, "------------------------------------------------------------------------------------------\n");
        $fwrite(trk_mem_access, " Tile 0x%02h\n", TRK_ID);
        $fwrite(trk_mem_access, "  Time   |    PC    | Op    |    VA    | BE   |   Data   | Region          | Tile | Offset\n");
        $fwrite(trk_mem_access, "------------------------------------------------------------------------------------------\n");
    end

    always @(posedge clk) begin : trk_instret_print
        if (run && !tile_done[trk_t]) begin
            $fwrite(trk_instret, "%8d | %8h | %8h\n",
                    $time,
                    dut.fetch_addr[trk_t],
                    dut.fetch_data[trk_t]);
        end
    end

    always @(posedge clk) begin : trk_mem_access_print
        if (dut.req_valid[trk_t]) begin
            trk_pa = va2pa(TRK_ID, dut.req_address[trk_t]);
            $fwrite(trk_mem_access, "%8d | %8h | %s | %8h | %4b | %8h | %-15s | 0x%02h | 0x%04h%s%s\n",
                    $time,
                    dut.fetch_addr[trk_t],
                    dut.req_wr_en[trk_t] ? "write" : "read ",
                    dut.req_address[trk_t],
                    dut.req_byte_en[trk_t],
                    dut.req_wr_en[trk_t] ? dut.req_wr_data[trk_t] : dut.rsp_rd_data[trk_t],
                    trk_pa.region.name(),
                    trk_pa.tile_id,
                    trk_pa.offset,
                    trk_pa.rsvd_error ? " RSVD_ERR" : "",
                    trk_pa.tile_error ? " TILE_ERR" : "");
        end
    end
end
endgenerate
