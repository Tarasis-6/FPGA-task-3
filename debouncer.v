`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2026 02:48:14 PM
// Design Name: 
// Module Name: debouncer
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


module debouncer#(

    parameter WIDTH = 1
    
)

(
    input clk, rst,
    
    input [WIDTH-1:0] in_signal,

    output [WIDTH-1:0] debounced_signal

);


   reg [2:0] debounce_reg;

   always @(posedge clk or posedge rst)
      if (rst == 1)
        debounce_reg <= {WIDTH{1'b0}};
      else
         debounce_reg <= {debounce_reg[1:0],in_signal};

   assign debounced_signal = debounce_reg[0] && debounce_reg[1] && ~debounce_reg[2];



endmodule
