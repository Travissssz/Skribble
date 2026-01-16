`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2025 02:19:52 PM
// Design Name: 
// Module Name: hint_level_randomizer
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


module hint_level_randomizer(
    input clk,
    input rst,
    input enable,         // Enable signal to trigger a new hint level
    output reg [2:0] hint_level // Randomly selected hint level (0 to 3)
);

    reg [4:0] lfsr = 5'b01101; // Different seed from other LFSRs
    reg prev_enable = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            hint_level <= 3'b000;
            lfsr <= 5'b01101; // Reset seed
            prev_enable <= 0;
        end 
        else begin
            // Shift LFSR on every clock for better randomness
            lfsr <= {lfsr[3] ^ lfsr[0], lfsr[4:1]}; 
            
            // Detect enable rising edge
            if (enable && !prev_enable) begin
                // Map LFSR bits to hint levels (0-3)
                case (lfsr[2:0])
                    3'b000: hint_level = 3'd0; 
                    3'b001: hint_level = 3'd1;
                    3'b010: hint_level = 3'd2;
                    3'b011: hint_level = 3'd3;
                    3'b100: hint_level = 3'd0; // Distribute remaining values
                    3'b101: hint_level = 3'd1;
                    3'b110: hint_level = 3'd2;
                    3'b111: hint_level = 3'd3;
                    default: hint_level = 3'd0;
                endcase
            end
            
            prev_enable <= enable;
        end
    end
endmodule