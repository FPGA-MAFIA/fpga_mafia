`include "macros.vh"

// ./build.py -dut mini_core_accel -hw -sim -top booth_multiplier_tb -clean 

module booth_multiplier_tb;
import mini_core_pkg::*;
import mini_core_accel_pkg::*;

logic clk;
logic rst;
t_mul_input_req   input_req;
t_mul_output_rsp  output_rsp;

// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 clk = 1'b0;
        #5 clk = 1'b1;
    end // forever
end // initial clock_gen

booth_multiplier booth_multiplier (
    .clock(clk),
    .rst(rst),
    .input_req(input_req),
    .output_rsp(output_rsp)
    );

task check_result;
    input signed [7:0] multiplicand;
    input signed [7:0] multiplier;
    input signed [15:0] expected;
    begin
        // Wait for busy to go low indicating Booth multiplier is ready
        wait (output_rsp.busy == 1'b0);
        // Send the input request
        input_req.valid = 1'b1;
        input_req.multiplicand = multiplicand;
        input_req.multiplier  = multiplier;

        // Wait for busy to go high indicating operation started
        wait (output_rsp.busy == 1'b1);
        // Wait for output_rsp.valid to go high indicating operation complete
        wait (output_rsp.valid == 1'b1);
        #1
        input_req.valid = 1'b0;
        #50
        input_req.valid = 1'b0;
        // Compare the results
        if (output_rsp.result == expected) begin
            $display("Test passed: %0d * %0d = %0d", multiplicand, multiplier, expected);
        end else begin
            $display("Test failed: %0d * %0d. Expected %0d, got %0d", multiplicand, multiplier, expected, output_rsp.result);
        end
        #10; // Small delay to avoid race conditions
    end
endtask

initial begin: main_tb
    // reset
    rst = 1'b1;
    input_req.valid = 1'b0;
    #20
    rst = 1'b0;
    #20

    // Test cases
    check_result(-8'd7, 8'd3, -16'd21 );
    check_result(8'd7, 8'd7, 16'd49);
    check_result(-8'd8, -8'd8, 16'd64);
    check_result(8'd0, 8'd0, 16'd0);
    check_result(8'd1, 8'd1, 16'd1);
    check_result(-8'd1, -8'd1, 16'd1);
    check_result(-8'd1, 8'd1, -16'd1);
    check_result(8'd2, 8'd2, 16'd4);
    check_result(-8'd2, 8'd2, -16'd4);
    check_result(-8'd6, 8'd4, -16'd24);
    check_result(8'd5, -8'd5, -16'd25);
    check_result(-8'd4, -8'd3, 16'd12);
    check_result(8'd3, 8'd3, 16'd9);
    check_result(-8'd3, -8'd2, 16'd6);
    check_result(8'd2, -8'd2, -16'd4);
    check_result(-8'd5, 8'd2, -16'd10);
    check_result(8'd6, 8'd6, 16'd36);
    check_result(-8'd7, -8'd2, 16'd14);
    check_result(8'd8, 8'd8, 16'd64);
    check_result(-8'd8, 8'd7, -16'd56);
    check_result(8'd0, -8'd7, 16'd0);
    check_result(-8'd6, 8'd1, -16'd6);
    check_result(8'd5, 8'd0, 16'd0);
    check_result(-8'd4, 8'd4, -16'd16);
    check_result(8'd3, -8'd1, -16'd3);
    check_result(-8'd2, 8'd3, -16'd6);
    check_result(8'd1, -8'd4, -16'd4);
    check_result(-8'd1, 8'd5, -16'd5);
    check_result(8'd7, -8'd3, -16'd21);

    // Additional test cases with bigger numbers
    check_result(-8'd50, 8'd2, -16'd100);
    check_result(8'd40, -8'd3, -16'd120);
    check_result(-8'd25, -8'd4, 16'd100);
    check_result(8'd60, 8'd5, 16'd300);
    check_result(-8'd30, 8'd6, -16'd180);
    check_result(8'd70, -8'd7, -16'd490);
    check_result(-8'd80, 8'd8, -16'd640);
    check_result(8'd90, -8'd9, -16'd810);
    check_result(-8'd100, 8'd10, -16'd1000);
    check_result(8'd127, 8'd127, 16'd16129);
    check_result(-8'd128, -8'd128, 16'd16384);
    check_result(-8'd128, 8'd127, -16'd16256);
    check_result(8'd127, -8'd128, -16'd16256);
    check_result(-8'd128, 8'd3, -16'd384);
    check_result(8'd3, -8'd128, -16'd384);
    check_result(-8'd127, 8'd127, -16'd16129);
    check_result(-8'd125, 8'd127, -16'd15875);
    check_result(8'd100, 8'd100, 16'd10000);
    check_result(-8'd100, 8'd50, -16'd5000);
    check_result(8'd64, -8'd64, -16'd4096);
    check_result(-8'd32, 8'd32, -16'd1024);
    check_result(8'd16, -8'd16, -16'd256);
    check_result(-8'd12, 8'd12, -16'd144);
    check_result(8'd8, 8'd15, 16'd120);
    check_result(-8'd10, -8'd10, 16'd100);
    check_result(8'd127, 8'd1, 16'd127);
    check_result(8'd127, -8'd1, -16'd127);
    check_result(-8'd127, 8'd1, -16'd127);
    check_result(-8'd127, -8'd1, 16'd127);
    check_result(8'd127, 8'd2, 16'd254);
    check_result(8'd127, -8'd2, -16'd254);
    check_result(-8'd127, 8'd2, -16'd254);
    check_result(-8'd127, -8'd2, 16'd254);
    check_result(8'd127, 8'd127, 16'd16129);
    check_result(-8'd127, -8'd127, 16'd16129);
    check_result(8'd64, 8'd64, 16'd4096);
    check_result(-8'd64, -8'd64, 16'd4096);
    check_result(8'd32, 8'd32, 16'd1024);
    check_result(-8'd32, -8'd32, 16'd1024);
    check_result(8'd16, 8'd16, 16'd256);
    check_result(-8'd16, -8'd16, 16'd256);
    check_result(8'd8, 8'd8, 16'd64);
    check_result(-8'd8, -8'd8, 16'd64);
    check_result(8'd4, 8'd4, 16'd16);
    check_result(-8'd4, -8'd4, 16'd16);
    check_result(8'd2, 8'd2, 16'd4);
    check_result(-8'd2, -8'd2, 16'd4);
    check_result(8'd1, 8'd1, 16'd1);
    check_result(-8'd1, -8'd1, 16'd1);
    check_result(8'd127, 8'd0, 16'd0);
    check_result(-8'd127, 8'd0, 16'd0);
    check_result(8'd0, 8'd127, 16'd0);
    check_result(8'd0, -8'd127, 16'd0);
    check_result(8'd100, 8'd25, 16'd2500);
    check_result(-8'd100, -8'd25, 16'd2500);
    check_result(8'd50, 8'd50, 16'd2500);
    check_result(-8'd50, -8'd50, 16'd2500);
    check_result(8'd20, 8'd5, 16'd100);
    check_result(-8'd20, -8'd5, 16'd100);
    check_result(8'd15, 8'd10, 16'd150);
    check_result(-8'd15, -8'd10, 16'd150);
    check_result(8'd10, 8'd20, 16'd200);
    check_result(-8'd10, -8'd20, 16'd200);
    check_result(8'd9, 8'd9, 16'd81);
    check_result(-8'd9, -8'd9, 16'd81);
    check_result(8'd7, 8'd8, 16'd56);
    check_result(-8'd7, -8'd8, 16'd56);
    check_result(8'd6, 8'd6, 16'd36);
    check_result(-8'd6, -8'd6, 16'd36);
    check_result(8'd5, 8'd5, 16'd25);
    check_result(-8'd5, -8'd5, 16'd25);
    check_result(8'd4, 8'd10, 16'd40);
    check_result(-8'd4, -8'd10, 16'd40);
    check_result(8'd3, 8'd7, 16'd21);
    check_result(-8'd3, -8'd7, 16'd21);
    check_result(8'd2, 8'd9, 16'd18);
    check_result(-8'd2, -8'd9, 16'd18);
    check_result(8'd1, 8'd8, 16'd8);
    check_result(-8'd1, -8'd8, 16'd8);
    check_result(8'd127, 8'd127, 16'd16129);
    check_result(-8'd128, -8'd128, 16'd16384);

    $finish();
end

parameter V_TIMEOUT = 30000;
initial begin : time_out
    #V_TIMEOUT
    $error("Time out reached");
    $finish();
end

endmodule
