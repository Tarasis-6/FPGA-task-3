`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/11/2026 08:58:51 PM
// Design Name: 
// Module Name: lock_controller_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lock_controller_tb();

  reg        clk;
  reg        rst;
  reg  [3:0] digit_in;
  wire       unlocked_led;



initial begin
        clk 		     = 0;
        rst 	         = 0;     
        digit_in         = 0;
end
   
   
   
    always #5 clk = ~clk;

    // ---- Self-checking task: apply one digit, check the resulting state ----
    task automatic check_transition;
        input [3:0] digit_val;
        input [1:0] expected_state;
        input [8*40-1:0] step_name;  // fixed-width "string" (classic Verilog has no string type)
        begin
            digit_in = digit_val;
            @(posedge clk); #1;
            if (dut.state === expected_state)
                $display("[%0t ns] PASS: %0s -> state=%0d", $time, step_name, dut.state);
            else
                $display("[%0t ns] FAIL: %0s -> expected %0d, got %0d", $time, step_name, expected_state, dut.state);
        end
    endtask

    initial begin

        rst = 1; digit_in = 4'd0;
        @(negedge clk); 
        rst = 0;
        $display("[%0t ps] after reset: state=%0d (expect LOCKED=0)", $time, dut.state);

        // ---- Scenario 1: correct sequence -> UNLOCKED ----
        check_transition(dut.CODE0, dut.WAIT_D2,  "digit1 correct");
        check_transition(dut.CODE1, dut.WAIT_D3,  "digit2 correct");
        check_transition(dut.CODE2, dut.UNLOCKED, "digit3 correct");

        // ---- Reset before the error scenario ----
        @(negedge clk);@(negedge clk);
                if (unlocked_led === 1'b1)
            $display("[%0t ns] PASS: unlocked_led=1 after correct sequence", $time);
        else
            $display("[%0t ns] FAIL: unlocked_led expected 1, got %0b", $time, unlocked_led);

        rst = 1; digit_in = 4'd0;
        @(negedge clk);@(negedge clk);@(negedge clk);
        rst = 0;

        // ---- Scenario 2: error on the second digit -> back to LOCKED ----
        check_transition(dut.CODE0,     dut.WAIT_D2, "digit1 correct");
        check_transition(dut.CODE1,     dut.WAIT_D3, "digit2 correct");
        check_transition(dut.CODE1 + 3, dut.LOCKED,  "digit2 WRONG -> reset to LOCKED");
        check_transition(dut.CODE0,     dut.WAIT_D2, "digit1 correct");
        check_transition(dut.CODE1,     dut.WAIT_D3, "digit2 correct");
        check_transition(dut.CODE2+4,   dut.WAIT_D3, "digit2 WRONG -> reset to LOCKED");

        $display("[%0t ps] Simulation finished", $time);
        $finish;
    end
    
    
    lock_controller dut (
        .clk            (clk        ),
        .rst            (rst        ),
        .digit_in       (digit_in   ),
        .unlocked_led   (unlocked_led)
    );
    
        debouncer dut_debouncer (
        .clk              (clk         ),
        .rst              (rst         ),
        .in_signal        (digit_in[0] ),
        .debounced_signal (            )
    );


endmodule
