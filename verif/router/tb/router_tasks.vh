
task run_router_test(input string test);
  delay(30);
  // ====================
  // router tests:
  // ====================
  if(test == "router_alive")begin
    `include "router_alive.sv"
  end else if(test == "router_1_req_per_io")begin
   // `include "router_1_req_per_io.sv"
  end else begin
    $error(" [ERROR] : test %s not found",test);
  end
endtask

