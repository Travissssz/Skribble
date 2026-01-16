`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2025 12:23:55 AM
// Design Name: 
// Module Name: letter_cycler
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


module letter_cycler(
    input clk, btnU, btnD, btnL, btnR, btnC, reset, new_round,
    input [12:0] pixel_idx,
    input [4:0] target_letter0, target_letter1, target_letter2, target_letter3, target_letter4,
    input [2:0] hint_level,
    input hint_active,
    output reg [15:0] oled_data,
    output reg word_correct // Output flag indicating if word is correct
);

    // Define color for letters (White) and background (Black)
    reg [15:0] letter_colour = 16'b11111_111111_11111; // White
    reg [15:0] background_colour = 16'b00000_000000_00000; // Black
    reg [15:0] correct_colour = 16'b00000_111111_00000; // Green
    reg [15:0] wrong_colour = 16'b11111_000000_00000; // Red
    reg [15:0] current_colour;
    reg [15:0] d_blue_colour = 16'b00000_000000_11111; // Dark blue
    reg [15:0] pencil_colour = 16'b11111_110000_00000; // Yellow-orange for pencil body
    reg [15:0] eraser_colour = 16'b11111_000000_11111; // Pink for eraser
    reg [15:0] lead_colour = 16'b01000_010000_01000; // Dark gray for pencil lead
    reg [15:0] yellow_colour = 16'b11111_111111_00000; // Yellow for hints

    // Define the letter data array
    reg [99:0] letters [0:25];

    // 5-letter array for display
    reg [4:0] word [0:4];
    reg [4:0] actual_word [0:4];
    
    // Selection & Correctness flags
    reg [2:0] selected_letter_idx = 0; // Start selection at first letter
    reg is_correct = 0; // Flag for correctness check
    reg [15:0] display_colour;
    
    // Hint-locked letters tracking
    reg [4:0] hint_locked; // One bit for each letter position
    reg [4:0] all_locked = 5'b00000; // Track if all letters are locked due to correct word
    
    // LFSR for randomized hints
    reg [4:0] hint_lfsr = 5'b10101; // 5-bit LFSR
    reg [4:0] hint_order [0:4]; // Ordered array of hint positions
    
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
        
        // Initialize word with "AAAAA"
        word[0] = 0;  // 'A'
        word[1] = 0;  // 'A'
        word[2] = 0;  // 'A'
        word[3] = 0;  // 'A'
        word[4] = 0;  // 'A'
        
        // Initialize correctness flag
        word_correct = 0;
        
        // Initialize hint_locked (no letters locked initially)
        hint_locked = 5'b00000;
        all_locked = 5'b00000;
        
        // Initialize hint order array - default sequence
        hint_order[0] = 0;
        hint_order[1] = 1;
        hint_order[2] = 2;
        hint_order[3] = 3;
        hint_order[4] = 4;
    end

    // Letter selection logic
    reg [99:0] current_letter_data;
    reg [4:0] current_letter = 0; // 5-bit since we have 26 letters (0 to 25)
    
    always @(*) begin
        current_letter_data = letters[current_letter];
        
        // Set the target word from input parameters
        actual_word[0] = target_letter0;
        actual_word[1] = target_letter1;
        actual_word[2] = target_letter2;
        actual_word[3] = target_letter3;
        actual_word[4] = target_letter4;
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
    
    // Pencil constants
    localparam PENCIL_Y_START = 16;
    localparam PENCIL_HEIGHT = 8;
    localparam PENCIL_WIDTH = 4;

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
    
    reg [4:0] persistent_hint_locked = 5'b00000;
    
    // Generate randomized hint order on reset
    always @(posedge clk) begin
        if (reset || new_round) begin
        
            // Reset LFSR and shuffle the hint order
            hint_lfsr <= 5'b10101;
            hint_order[0] <= 0;
            hint_order[1] <= 1;
            hint_order[2] <= 2;
            hint_order[3] <= 3;
            hint_order[4] <= 4;
            
            // Perform a few LFSR shifts to randomize
            repeat (5) begin
                hint_lfsr <= {hint_lfsr[3] ^ hint_lfsr[0], hint_lfsr[4:1]};
            end
            
            // Use LFSR bits to generate a pseudo-random order
            if (hint_lfsr[1:0] == 2'b00) begin
                // Swap positions 0 and 1
                hint_order[0] <= 1;
                hint_order[1] <= 0;
            end
            
            if (hint_lfsr[2:1] == 2'b01) begin
                // Swap positions 1 and 2
                hint_order[1] <= 2;
                hint_order[2] <= 1;  
            end
            
            if (hint_lfsr[3:2] == 2'b10) begin
                // Swap positions 2 and 3
                hint_order[2] <= 3;
                hint_order[3] <= 2;
            end
            
            if (hint_lfsr[4:3] == 2'b11) begin
                // Swap positions 3 and 4
                hint_order[3] <= 4;
                hint_order[4] <= 3;
            end
        end
    end
    
    // Update hint_locked based on hint_level
    always @(*) begin
        hint_locked = persistent_hint_locked;
        if (!hint_active) begin
            hint_locked = 5'b00000; // No hints when not active
        end else begin
            case (hint_level)
                3'd0: hint_locked = 5'b00000; // No hints
                3'd1: begin // One letter revealed
                    hint_locked = 5'b00000; // Start fresh for this level
                    hint_locked[hint_order[0]] = 1'b1;
                end
                3'd2: begin // Two letters revealed
                    hint_locked = 5'b00000; // Start fresh for this level
                    hint_locked[hint_order[0]] = 1'b1;
                    hint_locked[hint_order[1]] = 1'b1;
                end
                3'd3: begin // Three letters revealed
                    hint_locked = 5'b00000; // Start fresh for this level
                    hint_locked[hint_order[0]] = 1'b1;
                    hint_locked[hint_order[1]] = 1'b1;
                    hint_locked[hint_order[2]] = 1'b1;
                end
                3'd4: begin // Four letters revealed
                    hint_locked = 5'b00000; // Start fresh for this level
                    hint_locked[hint_order[0]] = 1'b1;
                    hint_locked[hint_order[1]] = 1'b1;
                    hint_locked[hint_order[2]] = 1'b1;
                    hint_locked[hint_order[3]] = 1'b1;
                end
                default: hint_locked = persistent_hint_locked;
            endcase
        end
    end
    
    // Slow update flag logic: control the update rate of letters
    always @(posedge clk) begin
        if (reset || new_round) begin
            // Reset to "AAAAA"
            word[0] <= 0;
            word[1] <= 0;
            word[2] <= 0;
            word[3] <= 0;
            word[4] <= 0;
            selected_letter_idx <= 0; // Set selection to first letter
            is_correct <= 0;
            word_correct <= 0;
            debounce_u <= 0;
            debounce_d <= 0;
            debounce_l <= 0;
            debounce_r <= 0;
            prev_btnU <= 0;
            prev_btnD <= 0;
            prev_btnL <= 0;
            prev_btnR <= 0;
            update_flag <= 1;  // Allow immediate update after reset
            all_locked <= 5'b00000; // Reset all_locked state
            prev_hint_level <= 0;
            persistent_hint_locked <= 5'b00000;
        end else begin
        
            // Update persistent hints when hint level changes
            if (hint_level != prev_hint_level && hint_active) begin
                case (hint_level)
                    3'd0: persistent_hint_locked <= 5'b00000; // Reset all hints
                    3'd1: persistent_hint_locked[hint_order[0]] <= 1'b1; // First hint
                    3'd2: begin
                        persistent_hint_locked[hint_order[0]] <= 1'b1;
                        persistent_hint_locked[hint_order[1]] <= 1'b1;
                    end
                    3'd3: begin
                        persistent_hint_locked[hint_order[0]] <= 1'b1;
                        persistent_hint_locked[hint_order[1]] <= 1'b1;
                        persistent_hint_locked[hint_order[2]] <= 1'b1;
                    end
                    3'd4: begin
                        persistent_hint_locked[hint_order[0]] <= 1'b1;
                        persistent_hint_locked[hint_order[1]] <= 1'b1;
                        persistent_hint_locked[hint_order[2]] <= 1'b1;
                        persistent_hint_locked[hint_order[3]] <= 1'b1;
                    end
                    default: persistent_hint_locked <= persistent_hint_locked;
                endcase
                prev_hint_level <= hint_level;
            end
                    
            // Update all_locked if the word is correct
            if (is_correct) begin
                all_locked <= 5'b11111;
            end
            
            // Apply hints: set letters to actual_word values for locked positions
            if (hint_locked[0])
                word[0] <= actual_word[0];
            if (hint_locked[1])
                word[1] <= actual_word[1];
            if (hint_locked[2])
                word[2] <= actual_word[2];
            if (hint_locked[3])
                word[3] <= actual_word[3];
            if (hint_locked[4])
                word[4] <= actual_word[4];
            
            // Skip locked positions for selection
            if ((hint_locked[selected_letter_idx] || all_locked[selected_letter_idx]) && !is_correct) begin
                // Find next unlocked position
                if (selected_letter_idx < 4) begin
                    if (!hint_locked[selected_letter_idx + 1] && !all_locked[selected_letter_idx + 1])
                        selected_letter_idx <= selected_letter_idx + 1;
                    else if (!hint_locked[selected_letter_idx + 2] && !all_locked[selected_letter_idx + 2] && selected_letter_idx + 2 <= 4)
                        selected_letter_idx <= selected_letter_idx + 2;
                    else if (!hint_locked[selected_letter_idx + 3] && !all_locked[selected_letter_idx + 3] && selected_letter_idx + 3 <= 4)
                        selected_letter_idx <= selected_letter_idx + 3;
                    else if (!hint_locked[selected_letter_idx + 4] && !all_locked[selected_letter_idx + 4] && selected_letter_idx + 4 <= 4)
                        selected_letter_idx <= selected_letter_idx + 4;
                    else if (!hint_locked[0] && !all_locked[0])
                        selected_letter_idx <= 0;
                    else if (!hint_locked[1] && !all_locked[1])
                        selected_letter_idx <= 1;
                    else if (!hint_locked[2] && !all_locked[2])
                        selected_letter_idx <= 2;
                    else if (!hint_locked[3] && !all_locked[3])
                        selected_letter_idx <= 3;
                    else if (!hint_locked[4] && !all_locked[4])
                        selected_letter_idx <= 4;
                end else begin
                    if (!hint_locked[0] && !all_locked[0])
                        selected_letter_idx <= 0;
                    else if (!hint_locked[1] && !all_locked[1])
                        selected_letter_idx <= 1;
                    else if (!hint_locked[2] && !all_locked[2])
                        selected_letter_idx <= 2;
                    else if (!hint_locked[3] && !all_locked[3])
                        selected_letter_idx <= 3;
                    else if (!hint_locked[4] && !all_locked[4])
                        selected_letter_idx <= 4;
                end
            end
            
            // Slow down the update cycle
            if (update_flag) begin
                // Check for button press (btnU) - only if current letter is not locked
                if (btnU && !prev_btnU && debounce_u == 0 && !hint_locked[selected_letter_idx] && !all_locked[selected_letter_idx] && !is_correct) begin
                    word[selected_letter_idx] <= (word[selected_letter_idx] + 1) % 26;  // Cycle letter forward in word[]
                    debounce_u <= 1250000;  // Set debounce time
                    update_flag <= 0;
                end
                // Check for button press (btnD) - only if current letter is not locked
                else if (btnD && !prev_btnD && debounce_d == 0 && !hint_locked[selected_letter_idx] && !all_locked[selected_letter_idx] && !is_correct) begin
                    word[selected_letter_idx] <= (word[selected_letter_idx] == 0) ? 25 : word[selected_letter_idx] - 1; // Cycle letter backward in word[]
                    debounce_d <= 1250000;  // Set debounce time
                    update_flag <= 0;
                end
                // Check for button press (btnL) - only move selection if not all letters locked
                else if (btnL && !prev_btnL && debounce_l == 0 && !is_correct) begin
                    // Find previous unlocked position
                    if (selected_letter_idx > 0) begin
                        if (!hint_locked[selected_letter_idx - 1] && !all_locked[selected_letter_idx - 1])
                            selected_letter_idx <= selected_letter_idx - 1;
                        else if (selected_letter_idx > 1 && !hint_locked[selected_letter_idx - 2] && !all_locked[selected_letter_idx - 2])
                            selected_letter_idx <= selected_letter_idx - 2;
                        else if (selected_letter_idx > 2 && !hint_locked[selected_letter_idx - 3] && !all_locked[selected_letter_idx - 3])
                            selected_letter_idx <= selected_letter_idx - 3;
                        else if (selected_letter_idx > 3 && !hint_locked[selected_letter_idx - 4] && !all_locked[selected_letter_idx - 4])
                            selected_letter_idx <= selected_letter_idx - 4;
                        else
                            selected_letter_idx <= selected_letter_idx; // Stay if all previous are locked
                    end
                    debounce_l <= 1250000;
                    update_flag <= 0;
                end
                // Check for button press (btnR) - only move selection if not all letters locked
                else if (btnR && !prev_btnR && debounce_r == 0 && !is_correct) begin
                    // Find next unlocked position
                    if (selected_letter_idx < 4) begin
                        if (!hint_locked[selected_letter_idx + 1] && !all_locked[selected_letter_idx + 1])
                            selected_letter_idx <= selected_letter_idx + 1;
                        else if (selected_letter_idx < 3 && !hint_locked[selected_letter_idx + 2] && !all_locked[selected_letter_idx + 2])
                            selected_letter_idx <= selected_letter_idx + 2;
                        else if (selected_letter_idx < 2 && !hint_locked[selected_letter_idx + 3] && !all_locked[selected_letter_idx + 3])
                            selected_letter_idx <= selected_letter_idx + 3;
                        else if (selected_letter_idx < 1 && !hint_locked[selected_letter_idx + 4] && !all_locked[selected_letter_idx + 4])
                            selected_letter_idx <= selected_letter_idx + 4;
                        else
                            selected_letter_idx <= selected_letter_idx; // Stay if all next are locked
                    end
                    debounce_r <= 1250000;
                    update_flag <= 0;
                end
                // Check for button press (btnC)
                else if (btnC) begin
                    // Check if word matches actual_word
                    if (word[0] == actual_word[0] && word[1] == actual_word[1] && word[2] == actual_word[2] && word[3] == actual_word[3] && word[4] == actual_word[4]) begin
                        is_correct <= 1; // Word is correct
                        word_correct <= 1; // Set output flag
                        all_locked <= 5'b11111; // Lock all letters if correct
                    end else begin
                        is_correct <= 0; // Word is incorrect
                        word_correct <= 0; // Clear output flag
                    end
                end
            end else begin
                update_flag <= 1; // Allow letter update after debounce delay
            end
            
            // Update previous button states
            prev_btnU <= btnU;
            prev_btnD <= btnD;
            prev_btnL <= btnL;
            prev_btnR <= btnR;
            
            // Debounce logic: reset counters after button release
            if (!btnU && debounce_u > 0) debounce_u <= debounce_u - 1;  // Decrease counter when btnU is released
            if (!btnD && debounce_d > 0) debounce_d <= debounce_d - 1;  // Decrease counter when btnD is released
            if (!btnL && debounce_l > 0) debounce_l <= debounce_l - 1;  // Decrease counter when btnL is released
            if (!btnR && debounce_r > 0) debounce_r <= debounce_r - 1;  // Decrease counter when btnR is released
        end
    end

    reg [99:0] letter_data;
    reg [6:0] pixel_pos;
    reg is_within_letter;
    reg [2:0] i; // Loop variable

    // Update OLED Display
    always @(*) begin
        if (is_correct) 
            current_colour = correct_colour;  // Green if correct
        else 
            current_colour = wrong_colour;  // Red if incorrect
            
        oled_data = background_colour;
    
        // Draw 2-pixel wide dark blue border as a solid rectangle with 4 pixel spacing from edges
        if ((x >= BORDER_OFFSET && x < OLED_WIDTH - BORDER_OFFSET) && 
                (y >= BORDER_OFFSET && y < OLED_HEIGHT - BORDER_OFFSET) && 
                !((x >= BORDER_OFFSET + BORDER_WIDTH && x < OLED_WIDTH - BORDER_OFFSET - BORDER_WIDTH) && 
                  (y >= BORDER_OFFSET + BORDER_WIDTH && y < OLED_HEIGHT - BORDER_OFFSET - BORDER_WIDTH))) 
            begin
                oled_data = d_blue_colour;
            end
    
        // Draw Letters
        for (i = 0; i < 5; i = i + 1) begin
            letter_data = letters[word[i]];
            pixel_pos = (y - LETTER_Y_START) * LETTER_WIDTH + (x - letter_x[i]);
            is_within_letter = (x >= letter_x[i] && x < letter_x[i] + LETTER_WIDTH) && (y >= LETTER_Y_START && y < LETTER_Y_START + LETTER_WIDTH);
                
            if (is_within_letter && letter_data[99 - pixel_pos]) begin
                // Updated color logic:
                if (is_correct)
                    oled_data = correct_colour; // Always green if word is correct
                else if (btnC)
                    oled_data = current_colour; // Red when checking incorrect word
                else if (hint_locked[i] || all_locked[i])
                    oled_data = yellow_colour; // Yellow for hinted/locked letters
                else
                    oled_data = letter_colour; // White for regular letters
            end
        end
    
        // Display yellow indicators for incorrect letters based on hint level
        if (!is_correct) begin // Show indicators even when checking with btnC
            for (i = 0; i < 5; i = i + 1) begin
                // Show yellow dot above letters that are locked but the user's letter doesn't match yet
                if (hint_locked[i] && word[i] != actual_word[i]) begin
                    if (y == LETTER_Y_START - 3 && x >= letter_x[i] + 4 && x <= letter_x[i] + 6)
                        oled_data = yellow_colour;
                end
            end
        end
    
        // Only underline selected letter if it's not locked and word is not correct
        if (!hint_locked[selected_letter_idx] && !all_locked[selected_letter_idx] && !is_correct && y == UNDERLINE_Y && x >= letter_x[selected_letter_idx] && x < letter_x[selected_letter_idx] + LETTER_WIDTH) begin
            oled_data = (btnC) ? current_colour : letter_colour;
        end
        
        // Only draw pencil above selected letter if it's not locked and word is not correct
        if (!hint_locked[selected_letter_idx] && !all_locked[selected_letter_idx] && !is_correct && y >= PENCIL_Y_START && y < PENCIL_Y_START + PENCIL_HEIGHT) begin
            // Center pencil above the selected letter
            if (x >= letter_x[selected_letter_idx] + (LETTER_WIDTH - PENCIL_WIDTH)/2 && 
                x < letter_x[selected_letter_idx] + (LETTER_WIDTH + PENCIL_WIDTH)/2) 
            begin
                // Draw eraser (top part of pencil)
                if (y >= PENCIL_Y_START && y < PENCIL_Y_START + 2) begin
                    oled_data = eraser_colour;
                end
                // Draw pencil body (middle part)
                else if (y >= PENCIL_Y_START + 2 && y < PENCIL_Y_START + PENCIL_HEIGHT - 2) begin
                    oled_data = pencil_colour;
                end
                // Draw pencil tip
                else if (y >= PENCIL_Y_START + PENCIL_HEIGHT - 2 && y < PENCIL_Y_START + PENCIL_HEIGHT) begin
                    // Create pencil tip shape (narrower at bottom)
                    if (x >= letter_x[selected_letter_idx] + (LETTER_WIDTH - PENCIL_WIDTH)/2 + (y - (PENCIL_Y_START + PENCIL_HEIGHT - 2)) &&
                        x < letter_x[selected_letter_idx] + (LETTER_WIDTH + PENCIL_WIDTH)/2 - (y - (PENCIL_Y_START + PENCIL_HEIGHT - 2))) 
                    begin
                        oled_data = lead_colour;
                    end
                end
            end
        end
    end
endmodule
