`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2023 15:05:29
// Design Name: 
// Module Name: paint
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


module paint(
    input clk_100M, clk_12p5M,
    input mouse_l, mouse_r, reset, reset_main, new_game, enable,  
    input [11:0] mouse_x, mouse_y,
    input [12:0] pixel_index, 
    output reg [15:0] colour_chooser    
);   
    reg clockMouse;       
    
    reg [2:0]pixel_data[682:0]; //going for 28 x 28, the scale down of 56 x 56. Original is 32 x 32, scale down of 64 x 64
    integer k;
    initial begin
          for (k=0; k<683; k=k+1) begin
              pixel_data[k] = 3'b111;
          end
    end
    
    // colours
    parameter WHITE = 16'b11111_111111_11111;
        parameter ORANGE = 16'b11111_101101_00000;
        parameter BLUE = 16'b00000_000000_11111;
        parameter GREEN = 16'b00000_111111_00000;
        parameter RED = 16'b11111_000000_00000;
        parameter PURPLE = 16'b11111_000000_11110;    
        parameter BLACK = 16'b00000_000000_00000;
        parameter GREY = 16'b00111_001111_00111;
        parameter BROWN = 16'b10001_010001_00100;
    
    
    wire [6:0] row, col;
    assign col = pixel_index % 96;
    assign row = pixel_index / 96;        
    
    reg [2:0] state_choice = 3'b110;
    reg [2:0] state = 3'b110; 
    
    // check if right click for reset with bounce detection
    reg [31:0] reset_count = 0;
    
    // initialize the reset to prevent unwanted error
    reg mouse_reset;
    initial begin
        mouse_reset = 1'b1;
    end
    
    always @ (posedge clk_100M) begin
        clockMouse = clk_12p5M; 
        // will held reset for 100ms if activate
        if (reset || reset_count > 0) begin
            reset_count = (reset_count > 999_999) ? 0 : reset_count + 1;
        end
        // double if statement to prevent premature detection under clear screen        
        mouse_reset = (reset_count > 0) ? 1 : ((mouse_reset && mouse_l && mouse_x < 96 && mouse_y < 64) ? 0 : mouse_reset);
    end
    
    // This is to generate the color plate selector
    always @(*) begin
        if (mouse_x > 0 && mouse_x < 12 && mouse_y > 0 && mouse_y < 12) state <= 3'b000;
            else if (mouse_x > 12 && mouse_x < 24 && mouse_y > 0 && mouse_y < 12) state <= 3'b001;
            else if (mouse_x > 24 && mouse_x < 36 && mouse_y > 0 && mouse_y < 12) state <= 3'b010;
            else if (mouse_x > 36 && mouse_x < 48 && mouse_y > 0 && mouse_y < 12) state <= 3'b011;
            else if (mouse_x > 48 && mouse_x < 60 && mouse_y > 0 && mouse_y < 12) state <= 3'b100;    
            else if (mouse_x > 60 && mouse_x < 72 && mouse_y > 0 && mouse_y < 12) state <= 3'b101;
            else if (mouse_x > 72 && mouse_x < 84 && mouse_y > 0 && mouse_y < 12) state <= 3'b110; 
            else if (mouse_x > 84 && mouse_x < 96 && mouse_y > 0 && mouse_y < 12) state <= 3'b111;
        end
   
    
    // To determine the color at each x-y coordinate, configurable    
    wire red, blue, green, orange, brown, purple, black, white, palette, screen;
    assign red = (col > 0 && col < 12 && row > 0 && row < 12);
    assign orange =  (col > 12 && col < 24 && row > 0 && row < 12);
    assign green =  (col > 24 && col < 36 && row > 0 && row < 12);
    assign blue =  (col > 36 && col < 48 && row > 0 && row < 12);
    assign purple = (col > 48 && col < 60 && row > 0 && row < 12);
    assign brown = (col > 60 && col < 72 && row > 0 && row < 12);
    assign black = (col > 72 && col < 84 && row > 0 && row < 12);
    assign white = (col > 84 && col < 96 && row > 0 && row < 12);
    assign palette = (row < 13);
    assign screen = (row > 12 && row < 64); // create a 96 x 52 screen
    
   
    reg [15:0] cursor_color;
    wire within_cursor;
    assign within_cursor = ((col == mouse_x) || ((col - mouse_x) == 1) || ((mouse_x - col) == 1)) && ((row == mouse_y) || ((row - mouse_y) == 1) || ((mouse_y - row) == 1));
    
    initial begin
        cursor_color = GREY;
    end
    
    // cursor colour change
    always @(*) begin
        if (within_cursor) begin
            case (state_choice)
                0: cursor_color = RED;
                1: cursor_color = ORANGE;
                2: cursor_color = GREEN;
                3: cursor_color = BLUE;
                4: cursor_color = PURPLE;
                5: cursor_color = BROWN;
                6: cursor_color = BLACK;
                7: cursor_color = WHITE;
                default: cursor_color = GREY;
            endcase
        end
    end
    
    // This is for color selection
    always @ (posedge mouse_l) begin
        if (enable) begin            
            if (mouse_l && (mouse_y < 12) && (mouse_x < 96)) 
                state_choice <= state; // Set colour 
        end
    end
    

    // We use 3 pixel per lines or per click    
    always @ (posedge clockMouse, posedge reset, posedge reset_main) begin
        if (reset || reset_main || new_game) begin
            for (k=0; k<683; k=k+1) begin //  here corresponding change from 1024 to 784
                pixel_data[k] <= 3'b111;
            end          
        end else if (enable && mouse_l && mouse_y > 12 && mouse_x < 96) begin                         
            pixel_data[(mouse_y/3)*32 + (mouse_x/3)] <= state_choice; // update pixel_data to chosen colour based on clicks
        end 
    end
    
    
    // This portion to generate the pixel data output
    always @ (pixel_index) begin
        if (enable) begin           
            if (within_cursor && cursor_color != 16'b1111_11111_1111) colour_chooser <= cursor_color;
            else if (red) colour_chooser <= RED;
            else if (blue) colour_chooser <= BLUE;
            else if (green) colour_chooser <= GREEN;
            else if (orange) colour_chooser <= ORANGE;
            else if (brown) colour_chooser <= BROWN;
            else if (purple) colour_chooser <= PURPLE;
            else if (black) colour_chooser <= BLACK;
            else if (white) colour_chooser <= WHITE;
            else if (palette) colour_chooser <= GREY;
            else if (screen) begin                
                case (pixel_data[32*(row/3)+ col/3])
                    0: colour_chooser <= RED;
                    1: colour_chooser <= ORANGE;
                    2: colour_chooser <= GREEN;
                    3: colour_chooser <= BLUE;
                    4: colour_chooser <= PURPLE;
                    5: colour_chooser <= BROWN;
                    6: colour_chooser <= BLACK;
                    7: colour_chooser <= WHITE;
                endcase
            end else colour_chooser <= WHITE;
        end
    end    
     
endmodule


