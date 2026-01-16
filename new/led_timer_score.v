`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2025 12:42:34
// Design Name: 
// Module Name: led_timer_score
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


module led_timer_score(
    input clk,             // 100MHz clock input
    input game_start,      // signals when the canvas screen pops up; starts timer
    input word_correct,    // signals when player guesses the word; stops timer
    input [15:0] sw,       // Switches for configuration and mode selection
    output [15:0] led,     // LEDs for countdown visualization
    output [3:0] an,       // 7-segment display anodes (digit selection)
    output [7:0] seg,      // 7-segment display segments (segment pattern)
    output timer_done      // timer up without having word correct 
);

    //=========================================================================
    // Signal Declarations
    //=========================================================================
    // Timer control signals
    wire [7:0] countdown_timer;   // Selected timer value (in seconds)
    wire countdown_done;          // Flag indicating countdown completion
    wire started;                 // Flag indicating timer is active
    wire error;                   // Flag indicating timer configuration error
    
    // Clock signals
    wire segclk;                  // Clock for 7-segment display multiplexing
    wire timerclk;                // Clock for timer operation
    
    // Score calculation signals
    wire [3:0] base_score = 0;    // Base score value (currently fixed at 0)
    wire [2:0] deduction;         // Performance deduction based on timing
    wire [13:0] multiplied_score; // Calculated score after applying multiplier
    
    // Player management signals
    wire current_player;          // Current player selection (0=player1, 1=player2)
    reg [13:0] player1_score = 0; // Player 1's accumulated score
    reg [13:0] player2_score = 0; // Player 2's accumulated score
  
    // Display control signals
    wire [3:0] an_score, an_done, an_time;  // Anode signals for different display modes
    wire [7:0] seg_score, seg_done, seg_time; // Segment patterns for different display modes
  
    // Button and switch edge detection
    reg [3:0] sw_prev;            // Previous switch state for edge detection
    reg sw15_prev;                // Previous state of sw[15] for score reset
    wire sw15_reset;              // Signal indicating sw[15] was toggled on
    
    assign timer_done = countdown_done;
    
    //=========================================================================
    // Display Mode Selection Logic
    //=========================================================================
    // Display modes are prioritized as follows:
    // 1. Score display (when sw[9] is ON)
    // 2. Error display (when configuration error is detected)
    // 3. "DONE" display (when countdown completes successfully)
    // 4. Time display (during countdown or when idle)
    
    wire show_score = sw[9];                  // Score display mode enabled by sw[9]
    wire show_player1_score = show_score && sw[11]; // Show player 1's score
    wire show_player2_score = show_score && sw[10]; // Show player 2's score
    wire show_error = error;                   // Show error message
    wire show_done = countdown_done && !error; // Show completion message
    wire show_time = (!started && !countdown_done && !error && !show_score) || 
                     (countdown_done && !show_score); // Show timer value
  
    // Select which score to display based on player selection switches
    wire [13:0] displayed_score = show_player1_score ? player1_score :
                                 show_player2_score ? player2_score :
                                 multiplied_score;
  
    //=========================================================================
    // Edge Detection Logic
    //=========================================================================
    always @(posedge clk) begin
        // Store previous states for edge detection
        sw_prev <= sw[3:0];
        sw15_prev <= sw[15];
    end
  
    // Detect rising edge on sw[15] for score reset
    assign sw15_reset = sw[15] && !sw15_prev;
  
    //=========================================================================
    // Player Score Management
    //=========================================================================
    always @(posedge countdown_done or posedge sw15_reset) begin
        if (sw15_reset) begin
            // Reset both player scores when sw[15] is toggled on
            player1_score <= 0;
            player2_score <= 0;
        end
        else if (countdown_done && !error) begin
            // Update the appropriate player's score when countdown completes
            if (current_player == 0) begin
                player1_score <= multiplied_score + player1_score;
            end
            else if (current_player == 1) begin
                player2_score <= multiplied_score + player2_score;
            end
        end
    end
  
    //=========================================================================
    // Display Output Selection
    //=========================================================================
    // Select anode signals based on current display mode
    assign an = (show_score && sw[9]) ? an_score :  // Show score display  
                show_error ? an_done :              // Show error message
                show_done ? an_done :               // Show completion message
                show_time ? an_time :               // Show timer value
                4'b1111;                            // All segments off
                                 
    // Select segment patterns based on current display mode
    assign seg = (show_score && sw[9]) ? seg_score : // Show score display
                  show_error ? seg_done :            // Show error message
                  show_done ? seg_done :             // Show completion message
                  show_time ? seg_time :             // Show timer value
                  8'b11111111;                        // All segments off
          
    //=========================================================================
    // Module Instantiations
    //=========================================================================
    
    // Clock divider for 7-segment display multiplexing (500Hz)
    flexi_clock_divider seg_clk_divider(
        .basys_clk(clk),         // 100MHz input clock
        .divisor(32'd200_000),   // Divide by 200,000 to get ~500Hz
        .my_clk(segclk)
    );
    
    // Clock divider for timer operation (faster for LED animations)
    flexi_clock_divider timer_clk_divider(
        .basys_clk(clk),
        .divisor(32'd7),        // Very fast clock for smooth LED animation
        .my_clk(timerclk)
    );

    // Timer duration selection from switches
    timer_select timer_select_inst(
        .clk(clk),
        .sw(sw[3:0]),            // Use switches 0-3 for timer selection
        .countdown_timer(countdown_timer),
        .error(error)            // Error if multiple switches are active
    );

    // "DONE" or "ERROR" display controller
    display_done display_done_inst(
        .clk(segclk),
        .an(an_done),
        .seg(seg_done),
        .countdown_done(countdown_done),
        .error(error)
    );

    // LED countdown controller with PWM for fading effects
    led_timer led_timer_inst(
        .countdown_timer(countdown_timer),
        .led(led),
        .game_start(game_start),
        .word_correct(word_correct),
        .clk(timerclk),
        .countdown_done(countdown_done),
        .deduction(deduction),
        .started(started)
    );
    
    // Score display controller
    display_score display_score_inst( 
        .an(an_score),
        .seg(seg_score),
        .clk(segclk),
        .score(displayed_score)  // Show selected player's score
    );

    // Time display controller
    display_score display_time_inst(
        .an(an_time),
        .seg(seg_time),
        .clk(segclk),
        .score({6'b0, countdown_timer-5})  // Convert timer value to score format
    );

    // Score calculation logic
    score_multiplier score_multiplier_inst( 
        .multiplied_score(multiplied_score), 
        .base_score(base_score),
        .deduction(deduction),
        .sw(sw[14:12])  // Difficulty mode selection
    );
    
    // Player selection controller
    player_select selected_player(
        .sw(sw[11:10]),  // Select player with switches 10-11
        .player(current_player),
        .clk(clk)
    );
endmodule

//=============================================================================
// Player Selection Module
//=============================================================================
// This module determines which player is currently active based on switches
// - sw[1] (sw[11] in main) selects Player 1
// - sw[0] (sw[10] in main) selects Player 2
// - Default is Player 1 if both or neither switch is active
//=============================================================================
module player_select(
    input [1:0] sw,       // Player selection switches
    output reg player,    // Current player (0=player1, 1=player2)
    input clk             // Clock input
);
    always @(posedge clk) begin
        if(sw[1]) begin
            player = 0;    // Select Player 1 when sw[1] is active
        end
        else if(sw[0]) begin 
            player = 1;    // Select Player 2 when sw[0] is active
        end
        else begin
            player = 0;    // Default to Player 1
        end
    end
endmodule
 

//=============================================================================
// Timer Selection Module
//=============================================================================
// Selects countdown duration based on switch settings
// - Only one switch should be active at a time
// - Sets error flag if no switch or multiple switches are active
//=============================================================================
module timer_select(
    input clk,
    input [3:0] sw,               // Switch inputs for timer selection
    output reg [7:0] countdown_timer, // Selected timer value
    output reg error               // Error flag
);

    always @(posedge clk) begin
        // Select timer value based on active switch
        case (sw)
            4'b0001: begin countdown_timer <= 8'd65; error <= 0; end  // sw0: 65 seconds
            4'b0010: begin countdown_timer <= 8'd85; error <= 0; end  // sw1: 85 seconds
            4'b0100: begin countdown_timer <= 8'd105; error <= 0; end // sw2: 105 seconds
            4'b1000: begin countdown_timer <= 8'd125; error <= 0; end // sw3: 125 seconds
            4'b0000: begin countdown_timer <= 8'd0; error <= 1; end   // No switch: Error
            default: begin countdown_timer <= 8'd0; error <= 1; end   // Multiple switches: Error
        endcase
    end
endmodule

//=============================================================================
// LED Timer Controller
//=============================================================================
// Manages the countdown visualization using LEDs with fading effects
// - Divides countdown into 16 segments (one per LED)
// - Uses PWM for smooth LED brightness transitions
// - Tracks performance deductions based on timing thresholds
//=============================================================================
module led_timer(
    input [7:0] countdown_timer,  // Selected duration in seconds
    output reg [15:0] led,        // LED outputs with PWM brightness control
    input game_start,             // Signal to start the timer
    input word_correct,           // Signal to stop timer early (success)
    input clk,                    // Timer clock (high frequency for smooth animation)
    output reg countdown_done,    // Completion flag
    output reg [2:0] deduction,   // Performance deduction counter
    output reg started            // Countdown active flag
);

    // State registers
    reg [31:0] counter;            // Current position in countdown segment
    reg [31:0] remaining_time;     // Number of LEDs remaining (0-15)
    reg [63:0] ticks_per_led;      // Clock ticks per LED segment
    reg [31:0] off_display_counter; // Post-completion display timer

    // PWM control for LED fading
    reg [7:0] pwm_counter;         // PWM cycle counter (0-255)
    reg [7:0] pwm_value [15:0];    // Brightness values for each LED (0-255)
    reg [15:0] pwm_clock_divider;  // PWM clock divider for timing
    wire pwm_clock = (pwm_clock_divider == 0); // PWM clock pulse

    // Reset condition - when game is not started
    wire reset = (!game_start && !started);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all state variables
            led <= 16'b0;
            countdown_done <= 0;
            started <= 0;
            remaining_time <= 0;
            counter <= 0;
            ticks_per_led <= 0;
            off_display_counter <= 0;
            deduction <= 0;
            pwm_counter <= 0;
            pwm_clock_divider <= 0;
            
            // Turn off all LEDs
            for (integer i = 0; i < 16; i = i + 1) begin
                pwm_value[i] <= 8'h00;
            end
        end
        else begin
            pwm_clock_divider <= pwm_clock_divider + 1;

            // Generate PWM output for all LEDs
            for (integer i = 0; i < 16; i = i + 1) begin
                led[i] <= (pwm_counter < pwm_value[i]);
            end

            // Update PWM counter on pwm_clock pulse
            if (pwm_clock) begin
                pwm_counter <= pwm_counter + 1;
                pwm_clock_divider <= 0;
            end

            // Handle post-completion display timeout
            if (countdown_done) begin 
                off_display_counter <= off_display_counter + 1;
                
                if (off_display_counter >= 9250000) begin 
                    countdown_done <= 0;
                end
                
                for (integer i = 0; i < 16; i = i + 1) begin
                    pwm_value[i] <= 8'h00;
                end
            end

            // Start new countdown when game_start signal is received
            if (game_start && !started) begin
                started <= 1;
                countdown_done <= 0;
                remaining_time <= 0;
                counter <= 0;
                deduction <= 0;
                off_display_counter <= 0;
                
                ticks_per_led <= (64'd6250000 * countdown_timer) / 16;

                for (integer i = 0; i < 16; i = i + 1) begin
                    pwm_value[i] <= 8'hFF;
                end
            end

            // Stop countdown if word_correct signal is received
            if (word_correct && started) begin
                started <= 0;
                countdown_done <= 1;
                
                for (integer i = 0; i < 16; i = i + 1) begin
                    pwm_value[i] <= 8'h00;
                end
            end

            // Countdown and LED animation logic
            if (started && remaining_time < 16) begin
                counter <= counter + 1;

                for (integer i = 0; i < 16; i = i + 1) begin
                    if (i == remaining_time) begin
                        if (counter <= ticks_per_led) begin
                            pwm_value[i] <= 255 - ((counter * 255) / ticks_per_led);
                        end else begin
                            pwm_value[i] <= 0;
                        end
                    end else if (i < remaining_time) begin
                        pwm_value[i] <= 0;
                    end else begin
                        pwm_value[i] <= 255;
                    end
                end

                if (counter >= ticks_per_led) begin
                    counter <= 0;
                    remaining_time <= remaining_time + 1;

                    if (remaining_time == 4 || remaining_time == 8 || remaining_time == 12 || remaining_time == 15) begin
                        deduction <= deduction + 1;
                    end
                end
            end

            // Countdown completion handling
            if (remaining_time == 16) begin
                countdown_done <= 1;
                started <= 0;
                
                for (integer i = 0; i < 16; i = i + 1) begin
                    pwm_value[i] <= 0;
                end
            end
        end
    end
endmodule

//=============================================================================
// Score Calculation Module
//=============================================================================
// Computes final score based on base score, deductions, and difficulty mode
// - Higher difficulty modes offer more points but also higher penalties
// - sw[14:12] select the difficulty mode
//=============================================================================
module score_multiplier(
    output reg [13:0] multiplied_score,  // Final calculated score
    input [13:0] base_score,             // Base score value
    input [2:0] deduction,               // Performance deductions (0-7)
    input [2:0] sw                       // Difficulty mode selection
);

    always @(*) begin
        case (sw)
            // Each mode offers different base points and deduction penalties
            3'b100: multiplied_score = base_score + 4 - deduction;       // Easy mode: 4 pts, -1 per deduction
            3'b010: multiplied_score = base_score + 8 - deduction * 2;   // Medium mode: 8 pts, -2 per deduction
            3'b001: multiplied_score = base_score + 12 - deduction * 3;  // Hard mode: 12 pts, -3 per deduction
            default: multiplied_score = 0;                              // Invalid mode: No points
        endcase
    end
endmodule

//=============================================================================
// Score Display Module
//=============================================================================
// Shows a numeric value (score or time) on the 7-segment displays
// - Handles values from 0 to 9999
// - Leading zeros are suppressed except in ones position
// - Display is multiplexed at segclk frequency
//=============================================================================
module display_score(
     output reg [3:0] an,   // Anode signals (digit selection)
     output reg [7:0] seg,  // Segment signals (digit pattern)
     input clk,             // Display multiplexing clock
     input [13:0] score     // Value to display (0-9999)
 );
 
     // 7-segment encodings for digits 0-9 (common cathode)
     // Active low (0 = segment on, 1 = segment off)
     localparam zero  = 8'b11000000;  // Digit 0
     localparam one   = 8'b11111001;  // Digit 1
     localparam two   = 8'b10100100;  // Digit 2
     localparam three = 8'b10110000;  // Digit 3
     localparam four  = 8'b10011001;  // Digit 4
     localparam five  = 8'b10010010;  // Digit 5
     localparam six   = 8'b10000010;  // Digit 6
     localparam seven = 8'b11111000;  // Digit 7
     localparam eight = 8'b10000000;  // Digit 8
     localparam nine  = 8'b10010000;  // Digit 9
     localparam off   = 8'b11111111;  // All segments off
 
     // Digit values extracted from score
     reg [3:0] ones;        // Ones place (rightmost digit)
     reg [3:0] tens;        // Tens place
     reg [3:0] hundreds;    // Hundreds place
     reg [3:0] thousands;   // Thousands place (leftmost digit)
     reg [1:0] counter = 0; // Display multiplex counter (0-3)
 
     // Break down score into individual digits
     always @(posedge clk) begin
         thousands <= score / 1000;
         hundreds  <= (score % 1000) / 100;
         tens      <= (score % 100) / 10;
         ones      <= score % 10;
         
         // Update display multiplexing counter
         counter <= counter + 1;
     end
 
     // 7-segment display multiplexing logic
     always @(*) begin
         case (counter)
             2'b00: begin  // Ones place (rightmost digit)
                 an = 4'b1110;  // Enable rightmost digit
                 case (ones)
                     4'd0: seg = zero;
                     4'd1: seg = one;
                     4'd2: seg = two;
                     4'd3: seg = three;
                     4'd4: seg = four;
                     4'd5: seg = five;
                     4'd6: seg = six;
                     4'd7: seg = seven;
                     4'd8: seg = eight;
                     4'd9: seg = nine;
                     default: seg = zero;
                 endcase
             end
             2'b01: begin  // Tens place
                 an = 4'b1101;  // Enable second digit from right
                 case (tens)
                     // Show leading zero only if higher digits are used
                     4'd0: seg = (thousands == 0 && hundreds == 0) ? off : zero;
                     4'd1: seg = one;
                     4'd2: seg = two;
                     4'd3: seg = three;
                     4'd4: seg = four;
                     4'd5: seg = five;
                     4'd6: seg = six;
                     4'd7: seg = seven;
                     4'd8: seg = eight;
                     4'd9: seg = nine;
                     default: seg = off;
                 endcase
             end
             2'b10: begin  // Hundreds place
                 an = 4'b1011;  // Enable third digit from right
                 case (hundreds)
                     // Show leading zero only if thousands digit is used
                     4'd0: seg = (thousands == 0) ? off : zero;
                     4'd1: seg = one;
                     4'd2: seg = two;
                     4'd3: seg = three;
                     4'd4: seg = four;
                     4'd5: seg = five;
                     4'd6: seg = six;
                     4'd7: seg = seven;
                     4'd8: seg = eight;
                     4'd9: seg = nine;
                     default: seg = off;
                 endcase
             end
             2'b11: begin  // Thousands place (leftmost digit)
                 an = 4'b0111;  // Enable leftmost digit
                 case (thousands)
                     // Never show leading zero in thousands place
                     4'd0: seg = off;
                     4'd1: seg = one;
                     4'd2: seg = two;
                     4'd3: seg = three;
                     4'd4: seg = four;
                     4'd5: seg = five;
                     4'd6: seg = six;
                     4'd7: seg = seven;
                     4'd8: seg = eight;
                     4'd9: seg = nine;
                     default: seg = off;
                 endcase
             end
             default: begin
                 an = 4'b1111;   // All digits off
                 seg = 8'b11111111; // All segments off
             end
         endcase
     end
 endmodule

//=============================================================================
// Status Display Module
//=============================================================================
// Shows text messages on the 7-segment displays:
// - "DONE" when countdown completes successfully
// - "ERRo" when there's a configuration error
// - Display is multiplexed at segclk frequency
//=============================================================================
module display_done(
    input clk,             // Display multiplexing clock
    input countdown_done,  // Flag indicating countdown completion
    output reg [3:0] an,   // Anode signals (digit selection)
    output reg [7:0] seg,  // Segment signals (segment pattern)
    input error            // Flag indicating configuration error
);

    // 7-segment encodings for letters (common cathode)
    parameter LETTER_D = 8'b10100001;  // Letter "D"
    parameter LETTER_O = 8'b11000000;  // Letter "O"
    parameter LETTER_N = 8'b10101011;  // Letter "N"
    parameter LETTER_E = 8'b10000110;  // Letter "E"
    parameter LETTER_R = 8'b10101111;  // Letter "R"

    reg [1:0] counter = 0; // Display multiplex counter (0-3)

    always @(posedge clk) begin
        if (error) begin  // Highest priority - show "ERRo"
            if (counter == 3) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end

            case (counter)
                // removed ERROR display
                2'd0: begin an <= 4'b0111; seg <= 8'b11111111; end // Leftmost digit
                2'd1: begin an <= 4'b1011; seg <= 8'b11111111; end // Second from left
                2'd2: begin an <= 4'b1101; seg <= 8'b11111111; end // Third from left
                2'd3: begin an <= 4'b1110; seg <= 8'b11111111; end // Rightmost digit
            endcase
        end
        else if (countdown_done) begin  // Show "DONE" when completed
            if (counter == 3) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end

            case (counter)
                2'd0: begin an <= 4'b0111; seg <= LETTER_D; end // Leftmost digit: D
                2'd1: begin an <= 4'b1011; seg <= LETTER_O; end // Second from left: O
                2'd2: begin an <= 4'b1101; seg <= LETTER_N; end // Third from left: N
                2'd3: begin an <= 4'b1110; seg <= LETTER_E; end // Rightmost digit: E
            endcase
        end
        else begin
            // All digits and segments off when not displaying a message
            an <= 4'b1111;
            seg <= 8'b11111111;
        end
    end
endmodule