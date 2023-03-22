delay(1);  backdoor_fm_load();

//send 2 read requests different CL B2B, first one should miss send fill and activate stall
delay(0); rd_req(20'h10_1_0, 5'd1); // read miss - send fill
delay(0); rd_req(20'h10_6_0, 5'd2); //not suppose to happen, re-issue buffer, until stall disable

