`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2025 10:46:12 AM
// Design Name: 
// Module Name: word_selector
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


module word_selector_easy(
    input clk,
    input rst,
    input new_game,
    output reg [24:0] encoded_word  // 5 bits per letter * 5 letters
);

    wire [2:0] word_index;

    lfsr_selector (.clk(clk), .rst(rst), .word_index(word_index), .new_game(new_game));

    // Function to encode ASCII A-Z to 5-bit value (A=1, B=2, ..., Z=26)
    function [4:0] encode_letter;
        input [7:0] letter;
        begin
            encode_letter = letter - 8'd64; // "A" = 65 => 1
        end
    endfunction

    reg [7:0] char1, char2, char3, char4, char5;

    always @(posedge clk) begin
        if (rst) begin
            encoded_word <= {5'd1, 5'd1, 5'd1, 5'd1, 5'd1}; // Default "AAAAA" => 1,1,1,1,1
        end else begin
            case (word_index)
                3'd0: {char1, char2, char3, char4, char5} <= {"A", "P", "P", "L", "E"};
                3'd1: {char1, char2, char3, char4, char5} <= {"H", "O", "U", "S", "E"};
                3'd2: {char1, char2, char3, char4, char5} <= {"S", "N", "A", "K", "E"};
                3'd3: {char1, char2, char3, char4, char5} <= {"C", "L", "O", "C", "K"};
                3'd4: {char1, char2, char3, char4, char5} <= {"D", "O", "N", "U", "T"};
                3'd5: {char1, char2, char3, char4, char5} <= {"C", "L", "O", "U", "D"};
                3'd6: {char1, char2, char3, char4, char5} <= {"H", "E", "A", "R", "T"};
                3'd7: {char1, char2, char3, char4, char5} <= {"F", "R", "I", "E", "S"};
                default: {char1, char2, char3, char4, char5} <= {"C", "R", "O", "W", "N"};
            endcase

            encoded_word <= {
                encode_letter(char1),
                encode_letter(char2),
                encode_letter(char3),
                encode_letter(char4),
                encode_letter(char5)
            };
        end
    end

endmodule

  
module word_selector_med(
    input clk,
    input rst,
    input new_game,
    output reg [24:0] encoded_word  // 5 bits per letter * 5 letters
);

    wire [2:0] word_index;

    lfsr_selector (.clk(clk), .rst(rst), .word_index(word_index), .new_game(new_game));

    // Function to encode ASCII A-Z to 5-bit value (A=1, B=2, ..., Z=26)
    function [4:0] encode_letter;
        input [7:0] letter;
        begin
            encode_letter = letter - 8'd64; // "A" = 65 => 1
        end
    endfunction

    reg [7:0] char1, char2, char3, char4, char5;

    always @(posedge clk) begin
        if (rst) begin
            encoded_word <= {5'd1, 5'd1, 5'd1, 5'd1, 5'd1}; // Default "AAAAA" => 1,1,1,1,1
        end else begin
            case (word_index)
                3'd0: {char1, char2, char3, char4, char5} <= {"E", "A", "R", "T", "H"};
                3'd1: {char1, char2, char3, char4, char5} <= {"P", "I", "Z", "Z", "A"};
                3'd2: {char1, char2, char3, char4, char5} <= {"T", "A", "B", "L", "E"};
                3'd3: {char1, char2, char3, char4, char5} <= {"M", "U", "S", "I", "C"};
                3'd4: {char1, char2, char3, char4, char5} <= {"R", "O", "B", "O", "T"};
                3'd5: {char1, char2, char3, char4, char5} <= {"H", "O", "R", "S", "E"};
                3'd6: {char1, char2, char3, char4, char5} <= {"C", "H", "A", "I", "R"};
                3'd7: {char1, char2, char3, char4, char5} <= {"M", "E", "D", "A", "L"};
                default: {char1, char2, char3, char4, char5} <= {"P", "L", "A", "N", "E"};
            endcase

            encoded_word <= {
                encode_letter(char1),
                encode_letter(char2),
                encode_letter(char3),
                encode_letter(char4),
                encode_letter(char5)
            };
        end
    end

endmodule

    
module word_selector_hard(
    input clk,
    input rst,
    input new_game,
    output reg [24:0] encoded_word  // 5 bits per letter * 5 letters
);

    wire [2:0] word_index;

    lfsr_selector (.clk(clk), .rst(rst), .word_index(word_index), .new_game(new_game));

    // Function to encode ASCII A-Z to 5-bit value (A=1, B=2, ..., Z=26)
    function [4:0] encode_letter;
        input [7:0] letter;
        begin
            encode_letter = letter - 8'd64; // "A" = 65 => 1
        end
    endfunction

    reg [7:0] char1, char2, char3, char4, char5;

    always @(posedge clk) begin
        if (rst) begin
            encoded_word <= {5'd1, 5'd1, 5'd1, 5'd1, 5'd1}; // Default "AAAAA" => 1,1,1,1,1
        end else begin
            case (word_index)
                3'd0: {char1, char2, char3, char4, char5} <= {"C", "H", "E", "S", "S"};
                3'd1: {char1, char2, char3, char4, char5} <= {"F", "L", "A", "M", "E"};
                3'd2: {char1, char2, char3, char4, char5} <= {"S", "K", "A", "T", "E"};
                3'd3: {char1, char2, char3, char4, char5} <= {"G", "H", "O", "S", "T"};
                3'd4: {char1, char2, char3, char4, char5} <= {"R", "U", "L", "E", "R"};
                3'd5: {char1, char2, char3, char4, char5} <= {"W", "H", "A", "L", "E"};
                default: {char1, char2, char3, char4, char5} <= {"T", "O", "R", "C", "H"};
            endcase

            encoded_word <= {
                encode_letter(char1),
                encode_letter(char2),
                encode_letter(char3),
                encode_letter(char4),
                encode_letter(char5)
            };
        end
    end

endmodule

    
