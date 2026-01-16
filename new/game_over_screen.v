`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2025 09:33:29 PM
// Design Name: 
// Module Name: game_over_screen
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


module game_over_screen(
    input clk, reset,
    input [12:0] pixel_idx,
    output reg [15:0] oled_data
);

    // Define color constants
    reg [15:0] background_colour = 16'b00000_000000_00000; // Black
    reg [15:0] border_colour = 16'b00000_111000_00000; // Medium green border
    reg [15:0] pink_colour = 16'b11111_000000_11111;
    reg [15:0] red_colour = 16'b11111_000000_00000;
    reg [15:0] orange_colour = 16'b11111_100000_00000;
    reg [15:0] yellow_colour = 16'b11111_111111_00000;
    reg [15:0] green_colour = 16'b00000_111111_00000;
    reg [15:0] l_blue_colour = 16'b00000_111111_11111;
    reg [15:0] d_blue_colour = 16'b00000_000000_11111;
    reg [15:0] white_colour = 16'b11111_111111_11111;
    
    // Define the letter data array
    reg [99:0] letters [0:25];
    
    // Letter indices for "GAME"
    reg [4:0] word_game [0:3]; // "GAME"
    
    // Letter indices for "OVER"
    reg [4:0] word_over [0:3]; // "OVER"
    
    initial begin
        // Initialize letter data
        letters[0] = 100'b0011111100001111110001110011100110000110011000011001111111100111111110011000011001100001100110000110; // 'A'
        letters[1] = 100'b0111111000011111110001100011100110001110011111111001111111000110001110011000111001111111100111111100; // 'B'
        letters[2] = 100'b0011111100011111111001100000100110000000011000000001100000000110000000011000001001111111100011111100; // 'C'
        letters[3] = 100'b0111111000011111110001100011100110000110011000011001100001100110000110011000111001111111000111111000; // 'D'
        letters[4] = 100'b0111111110011111111001100000000110000000011111100001111110000110000000011000000001111111100111111110; // 'E'
        letters[5] = 100'b0111111110011111111001100000000110000000011111100001111110000110000000011000000001100000000110000000; // 'F'
        letters[6] = 100'b0011111100011111111001100000100110000000011000000001100111100110011110011000011001111111100011111100; // 'G'
        letters[7] = 100'b0110000110011000011001100001100111111110011111111001100001100110000110011000011001100001100110000110; // 'H'
        letters[8] = 100'b0111111110011111111000001100000000110000000011000000001100000000110000000011000001111111100111111110; // 'I'
        letters[9] = 100'b0111111110011111111000000110000000011000000001100000000110000110011000011001100001111110000011111000; // 'J'
        letters[10] = 100'b0110001110011001110001101110000111100000011110000001111100000110111000011001110001100011100110001110; // 'K'
        letters[11] = 100'b0110000000011000000001100000000110000000011000000001100000000110000000011000000001111111100111111110; // 'L'
        letters[12] = 100'b0110000110011100111001111111100111111110011111111001101101100110000110011000011001100001100110000110; // 'M'
        letters[13] = 100'b0110000110011100011001111001100111110110011111111001101111100110011110011000111001100001100110000110; // 'N'
        letters[14] = 100'b0011111100011111111001100001100110000110011000011001100001100110000110011000011001111111100011111100; // 'O'
        letters[15] = 100'b0111111100011111111001100001100110000110011111111001111111000110000000011000000001100000000110000000; // 'P'
        letters[16] = 100'b0011111100011111111001100001100110000110011000011001100001100110001110011111111000111111100000000010; // 'Q'
        letters[17] = 100'b0111111100011111111001100001100110000110011111111001111111000110111000011001110001100011100110000110; // 'R'
        letters[18] = 100'b0011111100011111111001100001100110000000001111110000011111100000000110011000011001111111100011111100; // 'S'
        letters[19] = 100'b0111111110011111111000001100000000110000000011000000001100000000110000000011000000001100000000110000; // 'T'
        letters[20] = 100'b0110000110011000011001100001100110000110011000011001100001100110000110011000011001111111100011111100; // 'U'
        letters[21] = 100'b0110000110011000011001100001100110000110011000011001100001100011001100001100110000011110000000110000; // 'V'
        letters[22] = 100'b0110000110011000011001100001100110000110011011011001111111100111111110011111111001110011100110000110; // 'W'
        letters[23] = 100'b0110000110011000011000110011000001111000000111100000110011000110000110011000011001100001100110000110; // 'X'
        letters[24] = 100'b0110000110011000011000110011000011111100000111100000001100000000110000000011000000001100000000110000; // 'Y'
        letters[25] = 100'b0111111110011111111000000011100000011100000011100000011100000011100000011100000001111111100111111110; // 'Z'
        
        // Set word "GAME" (G=6, A=0, M=12, E=4)
        word_game[0] = 6;  // 'G'
        word_game[1] = 0;  // 'A'
        word_game[2] = 12; // 'M'
        word_game[3] = 4;  // 'E'
        
        // Set word "OVER" (O=14, V=21, E=4, R=17)
        word_over[0] = 14; // 'O'
        word_over[1] = 21; // 'V'
        word_over[2] = 4;  // 'E'
        word_over[3] = 17; // 'R'
    end

    // Constants for OLED display
    localparam LETTER_WIDTH = 10;
    localparam SPACING = 3;
    localparam OLED_WIDTH = 96;
    localparam OLED_HEIGHT = 64;
    
    // Y positions
    localparam GAME_Y_POS = 20; // Position for "GAME"
    localparam OVER_Y_POS = 35; // Position for "OVER"
    
    // Calculate starting X positions to center words
    // "GAME" is 4 letters, total width = 4*10 + 3*3 = 49 pixels
    // Center of screen is 96/2 = 48, so GAME starts at 48 - 49/2 = 23.5 ? 24
    localparam GAME_X_START = 24;
    
    // "OVER" is 4 letters, total width = 4*10 + 3*3 = 49 pixels
    // Center of screen is 96/2 = 48, so OVER starts at 48 - 49/2 = 23.5 ? 24
    localparam OVER_X_START = 24;
    
    // Border constants
    localparam BORDER_WIDTH = 3;
    localparam BORDER_OFFSET = 2;
    
    // X, Y coordinates for OLED (96 x 64 OLED display)
    wire [6:0] x = pixel_idx % OLED_WIDTH;
    wire [5:0] y = pixel_idx / OLED_WIDTH;

    // Render logic
    reg [99:0] letter_data;
    reg [6:0] pixel_pos;
    reg is_within_letter;
    reg [3:0] i; // Loop variable (4 bits for 4 letters)
    reg [6:0] letter_x_pos;
    reg [15:0] current_letter_color; // Variable to hold current letter color

    always @(*) begin
        oled_data = background_colour; // Default background
        
        // Draw border
        if ((x >= BORDER_OFFSET && x < OLED_WIDTH - BORDER_OFFSET) && 
            (y >= BORDER_OFFSET && y < OLED_HEIGHT - BORDER_OFFSET) && 
            !((x >= BORDER_OFFSET + BORDER_WIDTH && x < OLED_WIDTH - BORDER_OFFSET - BORDER_WIDTH) && 
              (y >= BORDER_OFFSET + BORDER_WIDTH && y < OLED_HEIGHT - BORDER_OFFSET - BORDER_WIDTH))) 
        begin
            oled_data = border_colour;
        end
        
        // Process "GAME" word with different colors
        for (i = 0; i < 4; i = i + 1) begin
            letter_x_pos = GAME_X_START + i * (LETTER_WIDTH + SPACING);
            letter_data = letters[word_game[i]];
            pixel_pos = (y - GAME_Y_POS) * LETTER_WIDTH + (x - letter_x_pos);
            is_within_letter = (x >= letter_x_pos && x < letter_x_pos + LETTER_WIDTH) && (y >= GAME_Y_POS && y < GAME_Y_POS + LETTER_WIDTH);
        
            // Choose color based on letter position
            case(i)
                0: current_letter_color = red_colour;     // G - red
                1: current_letter_color = orange_colour;  // A - orange
                2: current_letter_color = yellow_colour;  // M - yellow
                3: current_letter_color = green_colour;   // E - green
                default: current_letter_color = white_colour;
            endcase
        
            if (is_within_letter && letter_data[99 - pixel_pos]) begin
                oled_data = current_letter_color;
            end
        end
        
        // Process "OVER" word with different colors
        for (i = 0; i < 4; i = i + 1) begin
            letter_x_pos = OVER_X_START + i * (LETTER_WIDTH + SPACING);
            letter_data = letters[word_over[i]];
            pixel_pos = (y - OVER_Y_POS) * LETTER_WIDTH + (x - letter_x_pos);
            is_within_letter = (x >= letter_x_pos && x < letter_x_pos + LETTER_WIDTH) && (y >= OVER_Y_POS && y < OVER_Y_POS + LETTER_WIDTH);
        
            // Choose color based on letter position
            case(i)
                0: current_letter_color = l_blue_colour;  // O - light blue
                1: current_letter_color = d_blue_colour;  // V - dark blue
                2: current_letter_color = pink_colour;    // E - pink
                3: current_letter_color = white_colour;   // R - white
                default: current_letter_color = white_colour;
            endcase
        
            if (is_within_letter && letter_data[99 - pixel_pos]) begin
                oled_data = current_letter_color;
            end
        end
    end
endmodule