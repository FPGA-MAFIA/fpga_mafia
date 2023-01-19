//-----------------------------------------------------------------------------
// Title            : common param packag
// Project          : many core project
//-----------------------------------------------------------------------------
// File             : common_pkg.sv
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Created          : 02/02/2023
//-----------------------------------------------------------------------------
// Description :
// This file contains common parameters, structs, enums and functions used in the many_core_project
//-----------------------------------------------------------------------------
// Modification History:
// Date        Author      Version    Description
// 02/02/2023  Amichai     1.0        Initial version
//-----------------------------------------------------------------------------

package common_pkg;
// RV32I common parameters
parameter XLEN       = 32;
parameter XLEN_BYTES = XLEN/8;
parameter MSB_XLEN   = XLEN-1;



endpackage