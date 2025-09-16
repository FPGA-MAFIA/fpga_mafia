                +----------------------------+
                |        Shared Memory       |
                |    32-bit word array       |
                |                            |
                |   +--------------------+   |
                |   |   Byte 3 (31:24)  |<-- wdata[31:24] if BE[3]=1
 address_mux --->|   |   Byte 2 (23:16)  |<-- wdata[23:16] if BE[2]=1
                |   |   Byte 1 (15:8)   |<-- wdata[15:8]  if BE[1]=1
                |   |   Byte 0 (7:0)    |<-- wdata[7:0]  if BE[0]=1
                |   +--------------------+   |
                +----------------------------+
                          ^
                          |
         +--------------------------------------+
         |         Write MUX (active core)      |
         |                                      |
         |  addr = address_global[core_id]      |
         |  wdata= wdata[core_id]               |
         |  BE   = byteena[core_id]             |
         +--------------------------------------+
                          ^
                          |
              +---------------------------+
              |         9 Cores           |
              |   (each provides Addr,    |
              |    WData, BE, WriteEn)    |
              +---------------------------+
