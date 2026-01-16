`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: A0281977J TAN XINMIN
//  STUDENT B NAME: A0281936U JOEL JESSE HA SEE JUN
//  STUDENT C NAME: A0272840E TRAVIS ESWARAN
//  STUDENT D NAME: A0272152M WONG MAN ZHONG
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (
    input clk, btnU, btnD, btnL, btnR, btnC, 
    input [15:0] sw, 
    output [7:0] JC, JA, 
    inout PS2Clk, PS2Data, //mouse
    output [7:0] seg, 
    output [3:0] an, 
    output [15:0] led
);
  
    wire [2:0] random_hint_level;
    reg [2:0] hint_level;
    reg hint_trigger;
    reg [2:0] prev_hint_level;
    reg reset_task;
    wire reset = reset_task;
    wire [9:0] blink_led;
    
    
    // Add hint activation flag
    reg hint_active = 0;
    
    // Add button press detection
    reg btnC_prev = 0;
    
    // Add hint counter to track how many hints have been displayed (0-4)
    reg [2:0] hint_count = 0;
    
    // Add game_started flag to detect when game has started
    reg game_started = 0;
    
    // Word selector outputs
    wire [24:0] encoded_word_easy;
    wire [24:0] encoded_word_med;
    wire [24:0] encoded_word_hard;
    reg [24:0] selected_word;
    
    // Add hint start signal to pass to game_display
    wire hint_start;
    assign hint_start = hint_active;
    reg [31:0] hint_wait_timer = 0;
    reg first_hint_delay_done = 0;
    parameter ONE_MINUTE_TICKS = 60 * 100_000_000; // 60s × 100MHz
    
    // Clock modules
    wire clk6p25m, hintclk, clk25m, clk12p5m, clk1;
    flexi_clock_divider clk_6p25m (clk, 32'd7, clk6p25m);
    flexi_clock_divider hint_clk (clk, 32'd1_249_999_999, hintclk); // 25s per hint letter
    flexi_clock_divider my_25MHz (clk, 1, clk25m);
    flexi_clock_divider my_12p5MHz (clk, 3, clk12p5m);
    flexi_clock_divider my_1Hz (clk, 49_999_999, clk1);
      
    
    // Hint level randomizer
    hint_level_randomizer hint_rand(
        .clk(clk),
        .rst(reset),
        .enable(hint_trigger),
        .hint_level(random_hint_level)
    );
    
    // mouse instantiation
    wire left, right, middle;
    wire [11:0] xpos, ypos;
    wire [3:0] zpos;
    wire new_event;
    MouseCtl mouse (.clk(clk), .rst(0), .value(96), .setx(0), .sety(0), .setmax_x(1), .setmax_y(1),
                    .ps2_clk(PS2Clk), .ps2_data(PS2Data), .left(left), .right(right), .middle(middle), .xpos(xpos),
                    .ypos(ypos), .zpos(zpos), .new_event(new_event));
                    
    //paint instatiation
    wire [15:0] pixel_data_canvas;
    wire [12:0] pixel_index_JA, pixel_index_JC; 
    wire new_game; // signals new game started
    paint canvas (.mouse_x(xpos), .mouse_y(ypos), .mouse_l(left), .mouse_r(right), .reset(middle), .reset_main(sw[15]), .new_game(new_game), .pixel_index(pixel_index_JA), 
                        .enable(1), .clk_100M(clk), .clk_12p5M(clk12p5m), .colour_chooser(pixel_data_canvas));      
        
        
    // Display module
    wire [15:0] oled_data_JA, oled_data_JC;
    wire frame_begin_JA, frame_begin_JC, sending_pixels_JA, sending_pixels_JC, sample_pixel_JA, sample_pixel_JC;
    Oled_Display oledDisplay_JC (.clk(clk6p25m), .reset(0), .frame_begin(frame_begin_JC), .sending_pixels(sending_pixels_JC), .sample_pixel(sample_pixel_JC), .pixel_index(pixel_index_JC), 
                            .pixel_data(oled_data_JC), .cs(JC[0]), .sdin(JC[1]), .sclk(JC[3]), .d_cn(JC[4]), .resn(JC[5]), .vccen(JC[6]), .pmoden(JC[7]));
        
    Oled_Display oledDisplay_JA (.clk(clk6p25m), .reset(0), .frame_begin(frame_begin_JA), .sending_pixels(sending_pixels_JA), .sample_pixel(sample_pixel_JA), .pixel_index(pixel_index_JA), 
                            .pixel_data(oled_data_JA), .cs(JA[0]), .sdin(JA[1]), .sclk(JA[3]), .d_cn(JA[4]), .resn(JA[5]), .vccen(JA[6]), .pmoden(JA[7]));
    
    wire word_correct;   
    wire game_start;
    wire timer_done;        
    wire [15:0] timer_led;             
    led_timer_score timer_score(.clk(clk), .game_start(game_start), .word_correct(word_correct), .sw(sw), .led(timer_led), .an(an), .seg(seg), .timer_done(timer_done));
    
    
    // Word selector modules
    word_selector_easy word_easy_inst(
        .clk(clk),
        .rst(reset),
        .new_game(new_game),
        .encoded_word(encoded_word_easy)
    );
            
    word_selector_med word_med_inst(
        .clk(clk),
        .rst(reset),
        .new_game(new_game),
        .encoded_word(encoded_word_med)
    );
            
    word_selector_hard word_hard_inst(
        .clk(clk),
        .rst(reset),
        .new_game(new_game),
        .encoded_word(encoded_word_hard)
    );
    
    // Extract individual letters from the selected word
    wire [4:0] target_letter0, target_letter1, target_letter2, target_letter3, target_letter4;
    assign target_letter0 = selected_word[24:20] - 1; // Convert from 1-based to 0-based indexing
    assign target_letter1 = selected_word[19:15] - 1;
    assign target_letter2 = selected_word[14:10] - 1;
    assign target_letter3 = selected_word[9:5] - 1;
    assign target_letter4 = selected_word[4:0] - 1;
    
    // Game Display module
    wire [15:0] game_display_oled_data;
    
    
    game_display game_display_inst(
        .clk(clk6p25m),
        .clk1Hz(clk1),
        .hint_level(hint_level),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .btnC(btnC),
        .reset(reset),
        .pixel_idx_JA(pixel_index_JA),
        .pixel_idx_JC(pixel_index_JC),
        .target_letter0(target_letter0),
        .target_letter1(target_letter1),
        .target_letter2(target_letter2),
        .target_letter3(target_letter3),
        .target_letter4(target_letter4),
        .hint_start(hint_start),
        .oled_data_JC(oled_data_JC),
        .oled_data_JA(oled_data_JA),
        .canvas_oled_data(pixel_data_canvas),
        .word_correct(word_correct), // Get word completion status
        .game_start(game_start),
        .timer_done(timer_done),
        .end_game(new_game)
    );
    
    
    initial begin
        reset_task = 1;
        hint_level = 0;
        hint_trigger = 0;
        prev_hint_level = 0;
        selected_word = 25'b0;
        hint_active = 0;
        btnC_prev = 0;
        hint_count = 0;
        game_started = 0;
    end
    
    // Word selection logic based on switches
    always @(*) begin
        if (sw[14])
            selected_word = encoded_word_easy;
        else if (sw[13])
            selected_word = encoded_word_med; 
        else if (sw[12])
            selected_word = encoded_word_hard;
        else
            selected_word = encoded_word_easy; // Default to easy if no switch is on
    end
    
    // Edge detection for hintclk and btnC
    reg hintclk_prev;
    
    always @(posedge clk or posedge reset) begin
        if (reset||new_game) begin // reset hints when new game begins
            hint_level <= 0;
            hint_trigger <= 0;
            prev_hint_level <= 0;
            hintclk_prev <= 0;
            hint_active <= 0;
            btnC_prev <= 0;
            hint_count <= 0;
            game_started <= 0;
        end else begin
        
            // Store previous states for edge detection
            hintclk_prev <= hintclk;
            btnC_prev <= btnC;
            
            // Detect game start from game_display module
            if (game_start && !game_started) begin
                game_started <= 1;
                hint_active <= 0; // Don't activate hint until delay is over
                hint_count <= 0; // Reset hint counter
                hint_level <= 0; // Start with no hints
                hint_wait_timer <= 0;
                first_hint_delay_done <= 0;
            end
            
            // ~ 1 min delay before hints appear
            if (game_started && !first_hint_delay_done) begin
                if (hint_wait_timer < ONE_MINUTE_TICKS) begin
                    hint_wait_timer <= hint_wait_timer + 1;
                end else begin
                    first_hint_delay_done <= 1;
                    hint_active <= 1; // Now allow hints
                end
            end
            
            // Reset hint active if the word is completed
            if (word_correct) begin
                hint_active <= 0;
            end
            
            // Clear hint_trigger after one cycle
            if (hint_trigger) begin
                hint_trigger <= 0;
            end
            
            // Set hint_trigger
            else if (hint_active && game_started && hint_count < 4 && hintclk && !hintclk_prev) begin
                hint_trigger <= 1;
                hint_count <= hint_count + 1; // Increment hint counter
                
                // Set hint level based on the current hint count (1-4)
                hint_level <= hint_count + 1;
                
                prev_hint_level <= hint_level;
            end
        end
    end
    
    always @(posedge clk6p25m) begin
        if (sw[15]) begin
            reset_task <= 1;
        end else begin
            reset_task <= 0;
        end
    end  
    
   assign led = (game_start) ? timer_led : sw;
   
       
endmodule
