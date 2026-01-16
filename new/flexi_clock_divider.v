`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.03.2025 09:27:22
// Design Name: 
// Module Name: flexi_clock_divider
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


module flexi_clock_divider(
    input basys_clk,
    input [31:0] divisor,
    output reg my_clk = 0
    );
    
    reg [31:0] counter = 0;
    
    always @(posedge basys_clk) begin
        counter <= (counter == divisor)? 0 : counter + 1;
        my_clk <= (counter == 0)? ~my_clk : my_clk; 
    end
endmodule
