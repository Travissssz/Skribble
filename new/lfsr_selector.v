`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2025 10:47:20 AM
// Design Name: 
// Module Name: lfsr_selector
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


module lfsr_selector(
    input clk,
    input rst,
    input new_game,
    output reg [2:0] word_index // Randomly selected index (0 to 4)
);

    reg [4:0] lfsr = 5'b10101; // 5-bit LFSR with a nonzero seed

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            word_index <= 3'b000;
            lfsr <= 5'b10101; // Reset seeds
        end 
        else begin
            // Detect a new game started
            if (new_game) begin
                lfsr <= {lfsr[3] ^ lfsr[0], lfsr[4:1]}; // 5-bit LFSR feedback
                case (lfsr) // Map LFSR bits more evenly
                    7,  28, 16, 21: word_index = 3'd0; 
                    10, 2, 0, 31: word_index = 3'd1; 
                    5, 12, 23, 14: word_index = 3'd2; 
                    19,  27, 11, 25: word_index = 3'd3; 
                    6,  3, 15,  8 : word_index = 3'd4; 
                    18, 29,  9, 20: word_index = 3'd5;                   
                    24, 26,  4,  1: word_index = 3'd6;
                    30, 13, 22, 17: word_index = 3'd7;
                    default: word_index = 3'd0; // Fallback
                endcase
            end
        end
    end
endmodule
