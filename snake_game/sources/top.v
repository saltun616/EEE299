module top(
    input clk,
    input btnU, btnD, btnL, btnR, btnC,
    output hsync,
    output vsync,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output [6:0] seg,
    output [3:0] an
);

localparam GRID_W  = 32;
localparam GRID_H  = 24;
localparam CELL    = 20;
localparam MAX_LEN = 64;
localparam UP=2'd0, DOWN=2'd1, LEFT=2'd2, RIGHT=2'd3;

wire reset = btnC;

wire [9:0] hcount, vcount;
wire video_on;

vga_sync vga_inst(
    .clk100(clk),
    .hsync(hsync),
    .vsync(vsync),
    .hcount(hcount),
    .vcount(vcount),
    .video_on(video_on)
);

wire up_db, down_db, left_db, right_db;
debounce db_up    (.clk(clk), .btn_in(btnU), .btn_out(up_db));
debounce db_down  (.clk(clk), .btn_in(btnD), .btn_out(down_db));
debounce db_left  (.clk(clk), .btn_in(btnL), .btn_out(left_db));
debounce db_right (.clk(clk), .btn_in(btnR), .btn_out(right_db));

reg [1:0] dir = RIGHT;
always @(posedge clk) begin
    if (reset) dir <= RIGHT;
    else if (up_db    && dir != DOWN)  dir <= UP;
    else if (down_db  && dir != UP)    dir <= DOWN;
    else if (left_db  && dir != RIGHT) dir <= LEFT;
    else if (right_db && dir != LEFT)  dir <= RIGHT;
end

reg [23:0] tick_cnt = 0;
wire game_tick = (tick_cnt == 24'd12_499_999); 
always @(posedge clk) begin
    tick_cnt <= game_tick ? 24'd0 : tick_cnt + 1;
end

wire [15:0] rand_num;
lfsr lfsr_inst(.clk(clk), .reset(reset), .lfsr_out(rand_num));

wire [5*MAX_LEN-1:0] snake_x_flat;
wire [5*MAX_LEN-1:0] snake_y_flat;
wire [6:0] length;
wire [4:0] food_x, food_y;
wire game_over;
wire [7:0] score;

snake_game #(.GRID_W(GRID_W), .GRID_H(GRID_H), .MAX_LEN(MAX_LEN)) game_inst(
    .clk(clk),
    .reset(reset),
    .game_tick(game_tick),
    .dir(dir),
    .rand_num(rand_num),
    .snake_x_flat(snake_x_flat),
    .snake_y_flat(snake_y_flat),
    .length(length),
    .food_x(food_x),
    .food_y(food_y),
    .game_over(game_over),
    .score(score)
);

seven_seg seg_inst(
    .clk(clk),
    .score(score),
    .seg(seg),
    .an(an)
);

wire [4:0] cell_x = hcount / CELL;
wire [4:0] cell_y = vcount / CELL;
wire [4:0] px = hcount % CELL;
wire [4:0] py = vcount % CELL;

reg is_snake;
reg is_head;
integer i;
always @(*) begin
    is_snake = 0;
    is_head  = 0;
    for (i = 0; i < MAX_LEN; i = i + 1) begin
        if (i < length &&
            snake_x_flat[i*5 +: 5] == cell_x &&
            snake_y_flat[i*5 +: 5] == cell_y) begin
            is_snake = 1;
            if (i == 0) is_head = 1;
        end
    end
end

wire is_food = (cell_x == food_x) && (cell_y == food_y);

wire is_eye = is_head &&
              (((px >= 4  && px <= 6)  && (py >= 5 && py <= 7)) ||
               ((px >= 13 && px <= 15) && (py >= 5 && py <= 7)));

function is_heart_pixel;
    input [3:0] bx, by;
    reg [9:0] row;
    begin
        case (by)
            4'd0: row = 10'b0011001100;
            4'd1: row = 10'b0111111110;
            4'd2: row = 10'b1111111111;
            4'd3: row = 10'b1111111111;
            4'd4: row = 10'b1111111111;
            4'd5: row = 10'b0111111110;
            4'd6: row = 10'b0011111100;
            4'd7: row = 10'b0001111000;
            4'd8: row = 10'b0000110000;
            default: row = 10'b0000000000;
        endcase
        is_heart_pixel = row[9 - bx];
    end
endfunction

wire is_heart_shaped_food = is_food && is_heart_pixel(px >> 1, py >> 1);

function [2:0] get_char_id;
    input [3:0] idx;
    begin
        case (idx)
            4'd0: get_char_id = 3'd0; 
            4'd1: get_char_id = 3'd1; 
            4'd2: get_char_id = 3'd2; 
            4'd3: get_char_id = 3'd7;
            4'd4: get_char_id = 3'd3;
            4'd5: get_char_id = 3'd4; 
            4'd6: get_char_id = 3'd3; 
            4'd7: get_char_id = 3'd5; 
            4'd8: get_char_id = 3'd6;
            default: get_char_id = 3'd7;
        endcase
    end
endfunction

function [4:0] font_row;
    input [2:0] char_id;
    input [2:0] row;
    begin
        case (char_id)
            3'd0: case (row) 
                3'd0: font_row = 5'b01110;
                default: font_row = 5'b00100;
            endcase
            3'd1: case (row) 
                3'd0: font_row = 5'b11110;
                3'd1: font_row = 5'b10001;
                3'd2: font_row = 5'b10001;
                3'd3: font_row = 5'b11110;
                3'd4: font_row = 5'b10100;
                3'd5: font_row = 5'b10010;
                3'd6: font_row = 5'b10001;
                default: font_row = 5'b00000;
            endcase
            3'd2: case (row)
                3'd0: font_row = 5'b10001;
                3'd1: font_row = 5'b10001;
                3'd2: font_row = 5'b01010;
                3'd3, 3'd4, 3'd5, 3'd6: font_row = 5'b00100;
                default: font_row = 5'b00000;
            endcase
            3'd3: case (row) 
                3'd0: font_row = 5'b01110;
                3'd1: font_row = 5'b10001;
                3'd2: font_row = 5'b10001;
                3'd3: font_row = 5'b11111;
                3'd4: font_row = 5'b10001;
                3'd5: font_row = 5'b10001;
                3'd6: font_row = 5'b10001;
                default: font_row = 5'b00000;
            endcase
            3'd4: case (row) 
                3'd0: font_row = 5'b01110;
                3'd1: font_row = 5'b10001;
                3'd2: font_row = 5'b10000;
                3'd3: font_row = 5'b10111;
                3'd4: font_row = 5'b10001;
                3'd5: font_row = 5'b10001;
                3'd6: font_row = 5'b01111;
                default: font_row = 5'b00000;
            endcase
            3'd5: case (row) 
                3'd0: font_row = 5'b11111;
                3'd1, 3'd2, 3'd3, 3'd4, 3'd5: font_row = 5'b00100;
                3'd6: font_row = 5'b11111;
                default: font_row = 5'b00000;
            endcase
            3'd6: case (row) 
                3'd0: font_row = 5'b10001;
                3'd1: font_row = 5'b11001;
                3'd2: font_row = 5'b10101;
                3'd3: font_row = 5'b10101;
                3'd4: font_row = 5'b10011;
                3'd5: font_row = 5'b10001;
                3'd6: font_row = 5'b10001;
                default: font_row = 5'b00000;
            endcase
            default: font_row = 5'b00000; 
        endcase
    end
endfunction

localparam TEXT_SCALE   = 6;
localparam CHAR_W       = 5 * TEXT_SCALE;
localparam CHAR_GAP     = TEXT_SCALE;
localparam CHAR_STEP    = CHAR_W + CHAR_GAP;
localparam NUM_CHARS    = 9;
localparam TEXT_WIDTH   = NUM_CHARS * CHAR_STEP - CHAR_GAP;
localparam TEXT_HEIGHT  = 7 * TEXT_SCALE;
localparam TEXT_X_START = (640 - TEXT_WIDTH) / 2;
localparam TEXT_Y_START = (480 - TEXT_HEIGHT) / 2;

wire in_text_box = (hcount >= TEXT_X_START) && (hcount < TEXT_X_START + TEXT_WIDTH) &&
                    (vcount >= TEXT_Y_START) && (vcount < TEXT_Y_START + TEXT_HEIGHT);

wire [9:0] rel_x = hcount - TEXT_X_START;
wire [9:0] rel_y = vcount - TEXT_Y_START;
wire [3:0] char_idx = rel_x / CHAR_STEP;
wire [9:0] col_in_step = rel_x % CHAR_STEP;
wire in_char_gap = col_in_step >= CHAR_W;
wire [2:0] col = col_in_step / TEXT_SCALE;
wire [2:0] row = rel_y / TEXT_SCALE;
wire [2:0] char_id = get_char_id(char_idx);
wire [4:0] font_bits = font_row(char_id, row);
wire is_text_pixel = in_text_box && !in_char_gap && font_bits[4-col];


reg [3:0] red, green, blue;
always @(*) begin
    if (!video_on) begin
        red = 0; green = 0; blue = 0;
    end else if (game_over) begin
        if (is_text_pixel) begin
            red = 4'hF; green = 4'hF; blue = 4'hF; 
        end else begin
            red = 4'hF; green = 4'h0; blue = 4'h0; 
        end
    end else if (is_eye) begin
        red = 4'h0; green = 4'h0; blue = 4'h0;
    end else if (is_snake) begin
        red = 4'hF; green = 4'h6; blue = 4'hB;
    end else if (is_heart_shaped_food) begin
        red = 4'h9; green = 4'h0; blue = 4'hD;
    end else begin
        red = 4'h0; green = 4'h0; blue = 4'h0;
    end
end

assign vgaRed   = red;
assign vgaGreen = green;
assign vgaBlue  = blue;

endmodule