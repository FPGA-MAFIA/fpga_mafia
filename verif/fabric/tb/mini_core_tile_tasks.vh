task mini_core_tile_test(input string test);
  delay(30);
  // ====================
  // mini_core_tile tests:
  // ====================
  if (test == "mini_core_tile_simple") begin
     `include "mini_core_tile_simple.sv"
  end else begin
    $error(" [ERROR] : test %s not found",test);
  end
endtask