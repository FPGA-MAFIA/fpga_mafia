
`include "macros.vh"

module fabric_rv32i_ref_top
import fabric_rv32i_ref_pkg::*;
(
    input logic clk,
    input logic rst,
    input logic run

);


//-----------------
//     fabric 0
//-----------------
fabric_rv32i_ref
#(  
    //we need 2KB for each mem of fabric is measured in bytes and 2KB = 2048 bytes 2048 = 2^11, so we need 11 bits to address the memory 
    // 0x000 is the start address of the instruction memory for fabric 0
    // The instruction memory is 2KB, so the end address is 0x7FF (0 is included, so 0x800 - 1)
    .I_MEM_LSB('h0_000),         
    .I_MEM_MSB('h0_800 - 1'h1),
    // 0x800 is the start address of the data memory for fabric 0
    // The data memory is 2KB, so the end address is 0xFFFF (0x800 is included, so 0x1000 - 1)
    .D_MEM_LSB('h0_800),
    .D_MEM_MSB('h1_000 - 1'h1) 
) 
fabric_rv32i_ref_0
(
    .clk(clk),
    .rst(rst),
    .run(run),
    .core2mem_req(),
    .core2mem_req.Data(),
    .core2mem_req.WrEn(),
    .core2mem_req.RdEn(),
    .core2mem_req.Address(),
    .core2mem_req.ByteEn(),
    .core2mem_req.TileId()
);

//-----------------
//     fabric 1
//-----------------
fabric_rv32i_ref
#(  
    .I_MEM_LSB('h0_000),
    .I_MEM_MSB('h1_000 - 1'h1),  
    .D_MEM_LSB('h1_000),
    .D_MEM_MSB('h2_000 - 1'h1) 
) 
fabric_rv32i_ref_1

(
    .clk(clk),
    .rst(rst),
    .run(run),
    .core2mem_req(),
    .core2mem_req.Data(),
    .core2mem_req.WrEn(),
    .core2mem_req.RdEn(),
    .core2mem_req.Address(),
    .core2mem_req.ByteEn(),
    .core2mem_req.TileId()
);

//-----------------
//     fabric 2
//-----------------
fabric_rv32i_ref
#(  
    .I_MEM_LSB('h0_0000),
    .I_MEM_MSB('h1_0000 - 1'h1),  
    .D_MEM_LSB('h1_0000),
    .D_MEM_MSB('h2_0000 - 1'h1) 
) 
fabric_rv32i_ref_2

(
    .clk(clk),
    .rst(rst),
    .run(run),
    .core2mem_req(),
    .core2mem_req.Data(),
    .core2mem_req.WrEn(),
    .core2mem_req.RdEn(),
    .core2mem_req.Address(),
    .core2mem_req.ByteEn(),
    .core2mem_req.TileId()
);

//-----------------
//     fabric 3
//-----------------
fabric_rv32i_ref
#(  
    .I_MEM_LSB('h0_0000),
    .I_MEM_MSB('h1_0000 - 1'h1),
    .D_MEM_LSB('h1_0000),
    .D_MEM_MSB('h2_0000 - 1'h1) 
) 
fabric_rv32i_ref_3

(
    .clk(clk),
    .rst(rst),
    .run(run),
    .core2mem_req(),
    .core2mem_req.Data(),
    .core2mem_req.WrEn(),
    .core2mem_req.RdEn(),
    .core2mem_req.Address(),
    .core2mem_req.ByteEn(),
    .core2mem_req.TileId()
);

//-----------------
//     fabric 4
//-----------------
fabric_rv32i_ref
#(  
    .I_MEM_LSB('h0_0000),
    .I_MEM_MSB('h1_0000 - 1'h1),
    .D_MEM_LSB('h1_0000),
    .D_MEM_MSB('h2_0000 - 1'h1) 
) 
fabric_rv32i_ref_4

(
    .clk(clk),
    .rst(rst),
    .run(run),
    .core2mem_req(),
    .core2mem_req.Data(),
    .core2mem_req.WrEn(),
    .core2mem_req.RdEn(),
    .core2mem_req.Address(),
    .core2mem_req.ByteEn(),
    .core2mem_req.TileId()
);

//-----------------
//     fabric 5 
//-----------------
fabric_rv32i_ref
#(  
    .I_MEM_LSB('h0_0000),
    .I_MEM_MSB('h1_0000 - 1'h1),
    .D_MEM_LSB('h1_0000),
    .D_MEM_MSB('h2_0000 - 1'h1) 
)
fabric_rv32i_ref_5
(
    .clk(clk),
    .rst(rst),
    .run(run),
    .core2mem_req(),
    .core2mem_req.Data(),
    .core2mem_req.WrEn(),
    .core2mem_req.RdEn(),
    .core2mem_req.Address(),
    .core2mem_req.ByteEn(),
    .core2mem_req.TileId()
);
//-----------------
//     fabric 6     
//-----------------
fabric_rv32i_ref
#(  
    .I_MEM_LSB('h0_0000),
    .I_MEM_MSB('h1_0000 - 1'h1),
    .D_MEM_LSB('h1_0000),
    .D_MEM_MSB('h2_0000 - 1'h1) 
)
fabric_rv32i_ref_6
(
    .clk(clk),
    .rst(rst),
    .run(run),
    .core2mem_req(),
    .core2mem_req.Data(),
    .core2mem_req.WrEn(),
    .core2mem_req.RdEn(),
    .core2mem_req.Address(),
    .core2mem_req.ByteEn(),
    .core2mem_req.TileId()
);
//-----------------
//     fabric 7
//-----------------
fabric_rv32i_ref
#(
    .I_MEM_LSB('h0_0000),
    .I_MEM_MSB('h1_0000 - 1'h1),
    .D_MEM_LSB('h1_0000),
    .D_MEM_MSB('h2_0000 - 1'h1) 
)
fabric_rv32i_ref_7
(
    .clk(clk),
    .rst(rst),
    .run(run),
    .core2mem_req(),
    .core2mem_req.Data(),
    .core2mem_req.WrEn(),
    .core2mem_req.RdEn(),
    .core2mem_req.Address(),
    .core2mem_req.ByteEn(),
    .core2mem_req.TileId()
);

//-----------------
//     fabric 8
//-----------------
fabric_rv32i_ref
#(
    .I_MEM_LSB('h0_0000),
    .I_MEM_MSB('h1_0000 - 1'h1),
    .D_MEM_LSB('h1_0000),
    .D_MEM_MSB('h2_0000 - 1'h1)
)
fabric_rv32i_ref_8
(
    .clk(clk),
    .rst(rst),
    .run(run),
    .core2mem_req(),
    .core2mem_req.Data(),
    .core2mem_req.WrEn(),
    .core2mem_req.RdEn(),
    .core2mem_req.Address(),
    .core2mem_req.ByteEn(),
    .core2mem_req.TileId()
);

// create a unified flat memory for all fabrics
fabric_rv32i_ref_flat_mem  fabric_rv32i_ref_flat_mem_inst
(
    .clk(clk),
    .rst(rst),
    .run(run),
    .core2mem_req()
    .core2mem_req.Data(),
    .core2mem_req.WrEn(),
    .core2mem_req.RdEn(),
    .core2mem_req.Address(),
    .core2mem_req.ByteEn(),
    .core2mem_req.TileId()
);
endmodule
