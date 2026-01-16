`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2025 12:30:31 PM
// Design Name: 
// Module Name: game_start_menu
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


module game_start_menu(
    input clk, btnC, reset,
    input [12:0] pixel_idx,
    output reg [15:0] oled_data,
    output reg game_start
);

    // Define colour for letters (White) and background (Black)
    reg [15:0] letter_colour = 16'b11111_111111_11111; // White
    reg [15:0] background_colour = 16'b00000_000000_00000; // Black
    reg [15:0] pencil_colour = 16'b11111_110000_00000; // Yellow-orange for pencil body
    reg [15:0] eraser_colour = 16'b11111_000000_11111; // Pink for eraser
    reg [15:0] lead_colour = 16'b01000_010000_01000; // Dark gray for pencil lead
    reg [15:0] red_colour = 16'b11111_000000_00000; // Red
    reg [15:0] orange_colour = 16'b11111_100000_00000; // Orange
    reg [15:0] yellow_colour = 16'b11111_111111_00000; // Yellow
    reg [15:0] green_colour = 16'b00000_111111_00000; // Green
    reg [15:0] l_blue_colour = 16'b00000_111111_11111; // Light blue
    reg [15:0] d_blue_colour = 16'b00000_000000_11111; // Dark blue

    // Define the letter data array
    reg [99:0] letters [0:25];
    
    // Letter indices for game title "SKRIBBLE"
    reg [4:0] word_title [0:7]; // "SKRIBBLE"
    
    // Letter indices for "GAME START"
    reg [4:0] word_game [0:3]; // "GAME"
    reg [4:0] word_start [0:4]; // "START"
    
    // Button press detection
    reg prev_btnC = 0;
    
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
        
        // Set word "SKRIBBLE" (S=18, K=10, R=17, I=8, B=1, B=1, L=11, E=4)
        word_title[0] = 18; // 'S'
        word_title[1] = 10; // 'K'
        word_title[2] = 17; // 'R'
        word_title[3] = 8;  // 'I'
        word_title[4] = 1;  // 'B'
        word_title[5] = 1;  // 'B'
        word_title[6] = 11; // 'L'
        word_title[7] = 4;  // 'E'
        
        // Set word "GAME" (G=6, A=0, M=12, E=4)
        word_game[0] = 6;  // 'G'
        word_game[1] = 0;  // 'A'
        word_game[2] = 12; // 'M'
        word_game[3] = 4;  // 'E'
        
        // Set word "START" (S=18, T=19, A=0, R=17, T=19)
        word_start[0] = 18; // 'S'
        word_start[1] = 19; // 'T'
        word_start[2] = 0;  // 'A'
        word_start[3] = 17; // 'R'
        word_start[4] = 19; // 'T'
        
    end

    // Constants for OLED display
    localparam LETTER_WIDTH = 10;
    localparam SPACING = 3;
    localparam OLED_WIDTH = 96;
    localparam OLED_HEIGHT = 64;
    
    // Y positions
    localparam TITLE_Y_POS = 4; // Position for SKRIBBLE
    localparam PENCIL_Y_POS = 21; 
    localparam GAME_Y_POS = 34; 
    localparam START_Y_POS = 49; 
    
    // Calculate starting X positions to center words
    // "SKRIBBLE" is 8 letters, total width = 8*10 + 7*3 = 101 pixels (too wide, need to adjust)
    // Use smaller spacing: 8*10 + 7*2 = 94 pixels
    localparam TITLE_SPACING = 2;
    localparam TITLE_X_START = 1; // Start at position 1
    
    // "GAME" is 4 letters, total width = 4*10 + 3*3 = 49 pixels
    // Center of screen is 96/2 = 48, so GAME starts at 48 - 49/2 = 23.5 ? 24
    localparam GAME_X_START = 24;
    
    // "START" is 5 letters, total width = 5*10 + 4*3 = 62 pixels
    // Center of screen is 96/2 = 48, so START starts at 48 - 62/2 = 17
    localparam START_X_START = 17;
    
    // Pencil parameters
    localparam PENCIL_HEIGHT = 6;
    localparam PENCIL_WIDTH = 49; // Same width as GAME word
    localparam PENCIL_X_START = 24; // Same starting position as GAME word
    localparam ERASER_WIDTH = 8;
    localparam TIP_WIDTH = 7;
    
    // X, Y coordinates for OLED (96 x 64 OLED display)
    wire [6:0] x = pixel_idx % OLED_WIDTH;
    wire [5:0] y = pixel_idx / OLED_WIDTH;

    // Render logic
    reg [99:0] letter_data;
    reg [6:0] pixel_pos;
    reg is_within_letter;
    reg [3:0] i; // Loop variable (4 bits for 8 letters in SKRIBBLE)
    reg [6:0] letter_x_pos;
    reg [2:0] tip_y_pos;
    reg [15:0] current_letter_color; // Variable to hold current letter color

    always @(*) begin
        oled_data = background_colour; // Default background
        
        // Process "SKRIBBLE" title with different colors for each letter
        for (i = 0; i < 8; i = i + 1) begin
            letter_x_pos = TITLE_X_START + i * (LETTER_WIDTH + TITLE_SPACING);
            letter_data = letters[word_title[i]];
            pixel_pos = (y - TITLE_Y_POS) * LETTER_WIDTH + (x - letter_x_pos);
            is_within_letter = (x >= letter_x_pos && x < letter_x_pos + LETTER_WIDTH) && (y >= TITLE_Y_POS && y < TITLE_Y_POS + LETTER_WIDTH);
        
            // Choose color based on letter position
            case(i)
                0: current_letter_color = red_colour;     // S - red
                1: current_letter_color = orange_colour;  // K - orange
                2: current_letter_color = yellow_colour;  // R - yellow
                3: current_letter_color = green_colour;   // I - green
                4: current_letter_color = l_blue_colour;  // B - light blue
                5: current_letter_color = d_blue_colour;  // B - dark blue
                6: current_letter_color = lead_colour;  // L - pink
                7: current_letter_color = letter_colour;   // E - white
                default: current_letter_color = letter_colour;
            endcase
        
            if (is_within_letter && letter_data[99 - pixel_pos]) begin
                oled_data = current_letter_color;
            end
        end
        
        // Draw the pencil
        if (y >= PENCIL_Y_POS && y < PENCIL_Y_POS + PENCIL_HEIGHT) begin
                
            // Eraser part (right end)
            if (x >= PENCIL_X_START + PENCIL_WIDTH - ERASER_WIDTH && x < PENCIL_X_START + PENCIL_WIDTH) begin
                oled_data = eraser_colour;
            end
                    
            // Pencil body
            else if (x >= PENCIL_X_START + TIP_WIDTH && x < PENCIL_X_START + PENCIL_WIDTH - ERASER_WIDTH) begin
                oled_data = pencil_colour;
            end
                    
            // Pencil tip (left end) - Triangle shape with width 7 at the middle, tapering to 3 at edges
            else if (x >= PENCIL_X_START && x < PENCIL_X_START + TIP_WIDTH) begin
                    
                // Calculate the y position relative to the pencil
                tip_y_pos = y - PENCIL_Y_POS;
                        
                // Create a triangular shape with varying widths
                case(tip_y_pos)
                    3'd0: if (x >= PENCIL_X_START + TIP_WIDTH - 3) oled_data = lead_colour; // Width 3 at top
                    3'd1: if (x >= PENCIL_X_START + TIP_WIDTH - 5) oled_data = lead_colour; // Width 5
                    3'd2: if (x >= PENCIL_X_START + TIP_WIDTH - 7) oled_data = lead_colour; // Width 7 (full width)
                    3'd3: if (x >= PENCIL_X_START + TIP_WIDTH - 7) oled_data = lead_colour; // Width 7 (full width)
                    3'd4: if (x >= PENCIL_X_START + TIP_WIDTH - 5) oled_data = lead_colour; // Width 5
                    3'd5: if (x >= PENCIL_X_START + TIP_WIDTH - 3) oled_data = lead_colour; // Width 3 at bottom
                    default: ; // Do nothing for other y positions
                endcase
            end
        end
        
        // Process "GAME" word
        for (i = 0; i < 4; i = i + 1) begin
            letter_x_pos = GAME_X_START + i * (LETTER_WIDTH + SPACING);
            letter_data = letters[word_game[i]];
            pixel_pos = (y - GAME_Y_POS) * LETTER_WIDTH + (x - letter_x_pos);
            is_within_letter = (x >= letter_x_pos && x < letter_x_pos + LETTER_WIDTH) && (y >= GAME_Y_POS && y < GAME_Y_POS + LETTER_WIDTH);
        
            if (is_within_letter && letter_data[99 - pixel_pos]) begin
                oled_data = letter_colour;
            end
        end
        
        // Process "START" word
        for (i = 0; i < 5; i = i + 1) begin
            letter_x_pos = START_X_START + i * (LETTER_WIDTH + SPACING);
            letter_data = letters[word_start[i]];
            pixel_pos = (y - START_Y_POS) * LETTER_WIDTH + (x - letter_x_pos);
            is_within_letter = (x >= letter_x_pos && x < letter_x_pos + LETTER_WIDTH) && (y >= START_Y_POS && y < START_Y_POS + LETTER_WIDTH);
        
            if (is_within_letter && letter_data[99 - pixel_pos]) begin
                oled_data = letter_colour;
            end
        end
    end
endmodule
