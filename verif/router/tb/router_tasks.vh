
task run_fifo_arb_test(input string test);
  delay(30);
  // ====================
  // router tests:
  // ====================
  if(test == "alive_router")begin
    `include "alive_router.sv"
  end else if(test == "router_1_req_per_io")begin
    `include "router_1_req_per_io.sv"
  end else begin
    $error(" [ERROR] : test %s not found",test);
  end
endtask

