`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2025 10:49:57
// Design Name: 
// Module Name: letter_drawer
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


module letter_drawer(
    input clk, reset, 
    input [12:0] pixel_idx,
    input [4:0] target_letter0, target_letter1, target_letter2, target_letter3, target_letter4,
    output reg [15:0] oled_data
);

    // Define color for letters (White) and background (Black)
    reg [15:0] letter_colour = 16'b11111_111111_11111; // White
    reg [15:0] background_colour = 16'b00000_000000_00000; // Black
    reg [15:0] border_colour = 16'b00000_111111_00000; // Green
    
    // Define the letter data array
    reg [99:0] letters [0:25];

    // 5-letter array for display
    reg [4:0] word [0:4];
    
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
        
        // Initialize word with target word
        word[0] = target_letter0;  
        word[1] = target_letter1; 
        word[2] = target_letter2;  
        word[3] = target_letter3;
        word[4] = target_letter4; 
        
    end

    // Letter selection logic
    reg [99:0] current_letter_data;
    reg [4:0] current_letter = 0; // 5-bit since we have 26 letters (0 to 25)
    
    always @(*) begin
        current_letter_data = letters[current_letter];
        
        // Set the target word from input parameters
        word[0] = target_letter0;  
        word[1] = target_letter1; 
        word[2] = target_letter2;  
        word[3] = target_letter3;
        word[4] = target_letter4;
    end

    // X Position Constants (Spacing = 3 pixels)
    localparam LETTER_WIDTH = 10;
    localparam SPACING = 3;
    localparam LETTER_Y_START = 27;
    localparam UNDERLINE_Y = 39;
    localparam OLED_WIDTH = 96;
    localparam OLED_HEIGHT = 64;
    localparam LETTER_X_CENTER = 43;
    localparam LETTER_HEIGHT = 10;
    
    // Border constants
    localparam BORDER_WIDTH = 2;
    localparam BORDER_OFFSET = 3;
    

    // Compute X Positions for Each Letter
    wire [6:0] letter_x [0:4]; // 5 letters and x up to 96 (needs 7 bits)
    assign letter_x[2] = LETTER_X_CENTER;
    assign letter_x[1] = letter_x[2] - (LETTER_WIDTH + SPACING);
    assign letter_x[0] = letter_x[1] - (LETTER_WIDTH + SPACING);
    assign letter_x[3] = letter_x[2] + (LETTER_WIDTH + SPACING);
    assign letter_x[4] = letter_x[3] + (LETTER_WIDTH + SPACING);
    
    // Debounce and state variables
    reg [23:0] debounce_u = 0, debounce_d = 0, debounce_l = 0, debounce_r = 0;
    reg prev_btnU = 0, prev_btnD = 0, prev_btnL = 0, prev_btnR = 0;
    reg update_flag = 1;  // Initialize update_flag to allow immediate update
    reg prev_hint_level = 0;

    // X, Y coordinates for OLED (96 x 64 OLED display)
    wire [6:0] x = pixel_idx % OLED_WIDTH;
    wire [5:0] y = pixel_idx / OLED_WIDTH;
   

    reg [99:0] letter_data;
    reg [6:0] pixel_pos;
    reg is_within_letter;
    reg [2:0] i; // Loop variable

    // Update OLED Display
    always @(*) begin
                
        oled_data = background_colour;
    
        // Draw 2-pixel wide green border as a solid rectangle with 4 pixel spacing from edges
        if ((x >= BORDER_OFFSET && x < OLED_WIDTH - BORDER_OFFSET) && 
                (y >= BORDER_OFFSET && y < OLED_HEIGHT - BORDER_OFFSET) && 
                !((x >= BORDER_OFFSET + BORDER_WIDTH && x < OLED_WIDTH - BORDER_OFFSET - BORDER_WIDTH) && 
                  (y >= BORDER_OFFSET + BORDER_WIDTH && y < OLED_HEIGHT - BORDER_OFFSET - BORDER_WIDTH))) 
            begin
                oled_data = border_colour;
            end
    
        // Draw Letters
        for (i = 0; i < 5; i = i + 1) begin
            letter_data = letters[word[i]];
            pixel_pos = (y - LETTER_Y_START) * LETTER_WIDTH + (x - letter_x[i]);
            is_within_letter = (x >= letter_x[i] && x < letter_x[i] + LETTER_WIDTH) && (y >= LETTER_Y_START && y < LETTER_Y_START + LETTER_WIDTH);
            
            if (is_within_letter && letter_data[99 - pixel_pos])  
                oled_data = letter_colour;
                
        end
    end
endmodule
