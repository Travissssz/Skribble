`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2025 12:31:34 PM
// Design Name: 
// Module Name: game_display
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


module game_display(
    input clk, clk1Hz, btnU, btnD, btnL, btnR, btnC, reset,
    input [12:0] pixel_idx_JA, pixel_idx_JC,
    input [4:0] target_letter0, target_letter1, target_letter2, target_letter3, target_letter4,
    input [2:0] hint_level,
    input hint_start, timer_done,
    input [15:0] canvas_oled_data,
    output reg [15:0] oled_data_JC, oled_data_JA,
    output wire word_correct,
    output wire game_start,
    output end_game
);
    
    // State definitions
    localparam STATE_START_MENU = 3'd0;
    localparam STATE_TEAM_SELECT = 3'd1;
    localparam STATE_DIFF_SELECT = 3'd2;
    localparam STATE_TIMER_SELECT = 3'd3;
    localparam STATE_GAME = 3'd4;
    localparam STATE_CANVAS = 3'd5; // for drawer
    localparam STATE_DONE = 3'd6;
    
    // State register
    reg [2:0] current_state = STATE_START_MENU;
    
    // Button debounce circuits
    reg btnC_prev = 0;
    reg btnC_debounced = 0;
    reg [19:0] debounce_counter = 0;
    reg btnC_stable = 0;
    
    // Output data from submodules
    wire [15:0] game_start_menu_oled_data;
    wire [15:0] team_frame_oled_data;
    wire [15:0] diff_frame_oled_data;
    wire [15:0] timer_frame_oled_data;
    wire [15:0] letter_cycler_oled_data;
    wire [15:0] letter_drawer_oled_data;
    wire [15:0] bunny_frame_oled_data;
    wire [15:0] game_over_oled_data;
    
    // Control signals
    wire word_correct_internal;
    
    // Connect internal signals to outputs
    assign word_correct = word_correct_internal;
    assign game_start = (current_state == STATE_CANVAS);
    
    // Button signals for letter_cycler
    wire letter_btnU, letter_btnD, letter_btnL, letter_btnR;
    
    // Only pass button inputs to letter_cycler when in the game state
    assign letter_btnU = (current_state == STATE_CANVAS) ? btnU : 1'b0;
    assign letter_btnD = (current_state == STATE_CANVAS) ? btnD : 1'b0;
    assign letter_btnL = (current_state == STATE_CANVAS) ? btnL : 1'b0;
    assign letter_btnR = (current_state == STATE_CANVAS) ? btnR : 1'b0;
    
    // Debounce logic for btnC
    always @(posedge clk) begin
        if (reset) begin
            btnC_stable <= 0;
            debounce_counter <= 0;
            btnC_debounced <= 0;
        end else begin
            // If btnC is different from stable value, start/continue counting
            if (btnC != btnC_stable) begin
                debounce_counter <= debounce_counter + 1;
                // Wait for ~10ms (at 50MHz, 500,000 cycles)
                if (debounce_counter >= 20'h7A120) begin
                    btnC_stable <= btnC;
                    debounce_counter <= 0;
                end
            end else begin
                debounce_counter <= 0;
            end
            
            // Update debounced value
            btnC_debounced <= btnC_stable;
        end
    end
    
    // mod 5 counter for drawer transition between word screen to canvas screen
    wire start, done;
    reg [2:0] timer_count;
    always @ (posedge clk1Hz) 
    begin
          if (start || end_game) begin
               if (timer_count == 5) begin
                   timer_count <= 0;
               end else begin
                   timer_count <= timer_count + 1;
               end
           end else 
               timer_count <= 0;
       end
    
    // State transition logic
    always @(posedge clk) begin
        if (reset) begin
            current_state <= STATE_START_MENU;
            btnC_prev <= 0;
        end else begin
            btnC_prev <= btnC_debounced;
            
            // Button press detection (rising edge of debounced signal)
            if (btnC_debounced && !btnC_prev) begin
                case (current_state)
                    STATE_START_MENU:   current_state <= STATE_TEAM_SELECT;
                    STATE_TEAM_SELECT:  current_state <= STATE_DIFF_SELECT;
                    STATE_DIFF_SELECT:  current_state <= STATE_TIMER_SELECT;
                    STATE_TIMER_SELECT: current_state <= STATE_GAME;
                    default: ; // No action for other states
                endcase
            end
            
            if (current_state == STATE_GAME) // Waiting at STATE_GAME for 5 seconds to display word to guesser
                current_state <= (done) ? STATE_CANVAS : STATE_GAME;   
                
            if (current_state == STATE_CANVAS)
                current_state <= (word_correct_internal || timer_done) ? STATE_DONE : STATE_CANVAS;
                
            if (current_state == STATE_DONE)
                current_state <= (done) ? STATE_TEAM_SELECT : STATE_DONE;
        end
    end
    
    assign done = (timer_count == 5);
    assign start = (current_state == STATE_GAME);
    assign end_game = (current_state == STATE_DONE);
 
    // Instantiate game_start_menu module
    game_start_menu start_menu_inst(
        .clk(clk),
        .btnC(1'b0),
        .reset(reset),
        .pixel_idx(pixel_idx_JC),
        .oled_data(game_start_menu_oled_data),
        .game_start()
    );
    
    
    bunny_frame bunny_frame_inst(
        .frame_rate(1'b0),
        .pixel_index(pixel_idx_JC),
        .oled_data(bunny_frame_oled_data)
    );
    
    
    // Instantiate team_frame module
    team_frame team_frame_inst(
        .frame_rate(1'b0),
        .pixel_index(pixel_idx_JC),
        .oled_data(team_frame_oled_data)
    );
    
    // Instantiate diff_frame module
    diff_frame diff_frame_inst(
        .frame_rate(1'b0),
        .pixel_index(pixel_idx_JC),
        .oled_data(diff_frame_oled_data)
    );
    
    // Instantiate timer_frame module
    timer_frame timer_frame_inst(
        .frame_rate(1'b0),
        .pixel_index(pixel_idx_JC),
        .oled_data(timer_frame_oled_data)
    );
    
    // Instantiate letter_cycler module with debounced btnC
    letter_cycler letter_cycler_inst(
        .clk(clk),
        .btnU(letter_btnU),
        .btnD(letter_btnD),
        .btnL(letter_btnL),
        .btnR(letter_btnR),
        .btnC(btnC_debounced && (current_state == STATE_CANVAS)), // btnC only detected during STATE_CANVAS
        .reset(reset),
        .pixel_idx(pixel_idx_JC),
        .target_letter0(target_letter0),
        .target_letter1(target_letter1),
        .target_letter2(target_letter2),
        .target_letter3(target_letter3),
        .target_letter4(target_letter4),
        .hint_level(hint_level),
        .hint_active(hint_start),
        .oled_data(letter_cycler_oled_data),
        .word_correct(word_correct_internal),
        .new_round(end_game)
    );
    
    letter_drawer letter_drawer_inst(
        .clk(clk), 
        .reset(reset), 
        .pixel_idx(pixel_idx_JC),
        .target_letter0(target_letter0),
        .target_letter1(target_letter1),
        .target_letter2(target_letter2),
        .target_letter3(target_letter3),
        .target_letter4(target_letter4),
        .oled_data(letter_drawer_oled_data)
     );
     
     
     game_over_screen game_over_inst(
         .clk(clk), .reset(reset),
         .pixel_idx(pixel_idx_JC),
         .oled_data(game_over_oled_data)
     );
    
    // Select which display to show based on current state
    always @(*) begin
        case (current_state)
            STATE_START_MENU: begin
                oled_data_JC = game_start_menu_oled_data;
                oled_data_JA = bunny_frame_oled_data;
                end
            STATE_TEAM_SELECT:  begin
                oled_data_JC = team_frame_oled_data;
                oled_data_JA = bunny_frame_oled_data;
                end
            STATE_DIFF_SELECT:  begin
                oled_data_JC = diff_frame_oled_data;
                oled_data_JA = bunny_frame_oled_data;
                end
            STATE_TIMER_SELECT: begin
                oled_data_JC = timer_frame_oled_data;
                oled_data_JA = bunny_frame_oled_data;
                end
            STATE_GAME:         begin
                oled_data_JC = letter_cycler_oled_data;
                oled_data_JA = letter_drawer_oled_data;
                end
            STATE_CANVAS:       begin
                oled_data_JC = letter_cycler_oled_data;
                oled_data_JA = canvas_oled_data;
                end
            default:            begin
                oled_data_JC = game_over_oled_data;
                oled_data_JA = game_over_oled_data;
                end
        endcase
    end
        
endmodule
