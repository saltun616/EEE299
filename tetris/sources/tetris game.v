module tetris_game(
    input  wire        clk,
    input  wire        reset,
    input  wire        frame_tick,   
    input  wire [3:0]  key_code,
    input  wire        key_pulse,

    input  wire [9:0]  hcount,
    input  wire [9:0]  vcount,
    input  wire        video_on,

    output reg  [3:0]  rgb_red,
    output reg  [3:0]  rgb_green,
    output reg  [3:0]  rgb_blue,

    output wire [15:0] led_out
);

    localparam BOARD_W = 10;
    localparam BOARD_H = 20;
    localparam CELL    = 20;                
    localparam BOARD_LEFT = 220;
    localparam BOARD_TOP  = 40;
    localparam DROP_FRAMES = 30;             
    localparam KEY_ROTATE = 4'd1;  
    localparam KEY_LEFT   = 4'd4; 
    localparam KEY_RIGHT  = 4'd6;  
    localparam KEY_DOWN   = 4'd9; 
    localparam S_SPAWN   = 3'd0;
    localparam S_FALL    = 3'd1;
    localparam S_LOCK    = 3'd2;
    localparam S_CLEAR   = 3'd3;
    localparam S_GAMEOVER= 3'd4;

    reg [2:0] state;
    reg [3:0] board [0:BOARD_H-1][0:BOARD_W-1];
    reg [3:0] temp_board [0:BOARD_H-1][0:BOARD_W-1]; 
    integer ri, ci;
    reg [2:0] piece_type;      
    reg [1:0] rotation;       
    reg signed [4:0] px;
    reg [4:0] py;              
    reg [2:0] next_piece;
    reg [7:0] lfsr;
    reg [7:0] gravity_cnt;
    reg [7:0] lines_cleared;
    assign led_out = {8'd0, lines_cleared};

    function shape_bit;
        input [2:0] ptype;
        input [1:0] rot;
        input [1:0] r, c;
        reg [1:0] br, bc;
        reg [15:0] pattern;
        begin
            case (rot)
                2'd0: begin br = r;     bc = c;     end
                2'd1: begin br = 3-c;   bc = r;     end
                2'd2: begin br = 3-r;   bc = 3-c;   end
                default: begin br = c;  bc = 3-r;   end
            endcase
            case (ptype)
                3'd0: pattern = 16'h00F0; 
                3'd1: pattern = 16'h0660; 
                3'd2: pattern = 16'h0720; 
                3'd3: pattern = 16'h0360; 
                3'd4: pattern = 16'h0630; 
                3'd5: pattern = 16'h0710; 
                default: pattern = 16'h0740; 
            endcase
            shape_bit = pattern[br*4 + bc];
        end
    endfunction
    
    function collision;
        input [2:0] ptype;
        input [1:0] rot;
        input signed [4:0] tx;
        input [4:0] ty;
        integer r, c;
        integer bx, by;
        reg hit;
        begin
            hit = 1'b0;
            for (r = 0; r < 4; r = r + 1) begin
                for (c = 0; c < 4; c = c + 1) begin
                    if (shape_bit(ptype, rot, r[1:0], c[1:0])) begin
                        bx = tx + c;
                        by = ty + r;
                        if (bx < 0 || bx >= BOARD_W || by >= BOARD_H)
                            hit = 1'b1;
                        else if (by >= 0 && board[by][bx] != 4'd0)
                            hit = 1'b1;
                    end
                end
            end
            collision = hit;
        end
    endfunction

    function is_row_full;
        input integer row;
        integer c;
        reg full;
        begin
            full = 1'b1;
            for (c = 0; c < BOARD_W; c = c + 1)
                if (board[row][c] == 4'd0) full = 1'b0;
            is_row_full = full;
        end
    endfunction

    integer wr, sr;

    always @(posedge clk) begin
        if (reset) begin
            state          <= S_SPAWN;
            px             <= 5'd3;
            py             <= 5'd0;
            rotation       <= 2'd0;
            piece_type     <= 3'd0;
            next_piece     <= 3'd1;
            lfsr           <= 8'hA5;
            gravity_cnt    <= 8'd0;
            lines_cleared  <= 8'd0;
            for (ri = 0; ri < BOARD_H; ri = ri + 1)
                for (ci = 0; ci < BOARD_W; ci = ci + 1)
                    board[ri][ci] <= 4'd0;
        end else begin

            lfsr <= {lfsr[6:0], lfsr[7]^lfsr[5]^lfsr[4]^lfsr[3]};

            case (state)

                S_SPAWN: begin
                    piece_type <= next_piece;
                    rotation   <= 2'd0;
                    px         <= 5'd3;
                    py         <= 5'd0;
                    next_piece <= (lfsr[2:0] == 3'd7) ? 3'd0 : lfsr[2:0];
                    if (collision(next_piece, 2'd0, 5'd3, 5'd0))
                        state <= S_GAMEOVER;
                    else
                        state <= S_FALL;
                end

                S_FALL: begin
                    if (key_pulse && key_code == KEY_LEFT) begin
                        if (!collision(piece_type, rotation, px-1, py))
                            px <= px - 1'b1;
                    end else if (key_pulse && key_code == KEY_RIGHT) begin
                        if (!collision(piece_type, rotation, px+1, py))
                            px <= px + 1'b1;
                    end else if (key_pulse && key_code == KEY_ROTATE) begin
                        if (!collision(piece_type, rotation+1'b1, px, py))
                            rotation <= rotation + 1'b1;
                    end else if (key_pulse && key_code == KEY_DOWN) begin

                        gravity_cnt <= 8'd0;
                        if (!collision(piece_type, rotation, px, py+1))
                            py <= py + 1'b1;
                        else
                            state <= S_LOCK;
                    end

                    if (frame_tick) begin
                        if (gravity_cnt == DROP_FRAMES-1) begin
                            gravity_cnt <= 8'd0;
                            if (!collision(piece_type, rotation, px, py+1))
                                py <= py + 1'b1;
                            else
                                state <= S_LOCK;
                        end else begin
                            gravity_cnt <= gravity_cnt + 1'b1;
                        end
                    end
                end

                S_LOCK: begin
                    for (ri = 0; ri < 4; ri = ri + 1)
                        for (ci = 0; ci < 4; ci = ci + 1)
                            if (shape_bit(piece_type, rotation, ri[1:0], ci[1:0]))
                                board[py+ri][px+ci] <= piece_type + 3'd1;
                    state <= S_CLEAR;
                end

                S_CLEAR: begin
                    wr = BOARD_H - 1;
                    for (sr = BOARD_H - 1; sr >= 0; sr = sr - 1) begin
                        if (!is_row_full(sr)) begin
                            for (ci = 0; ci < BOARD_W; ci = ci + 1)
                                temp_board[wr][ci] = board[sr][ci];
                            wr = wr - 1;
                        end
                    end
                    for (ri = 0; ri < BOARD_H; ri = ri + 1) begin
                        if (ri <= wr) begin
                            for (ci = 0; ci < BOARD_W; ci = ci + 1)
                                temp_board[ri][ci] = 4'd0;
                        end
                    end

                    for (ri = 0; ri < BOARD_H; ri = ri + 1)
                        for (ci = 0; ci < BOARD_W; ci = ci + 1)
                            board[ri][ci] <= temp_board[ri][ci];

                    if (wr < BOARD_H - 1)
                        lines_cleared <= lines_cleared + (BOARD_H - 1 - wr);

                    state <= S_SPAWN;
                end

                S_GAMEOVER: begin
                    state <= S_GAMEOVER;
                end

                default: state <= S_SPAWN;
            endcase
        end
    end


    function [3:0] color_r; input [3:0] id; begin
        case(id)
            4'd1: color_r=4'h0; 4'd2: color_r=4'hF; 4'd3: color_r=4'h8;
            4'd4: color_r=4'h0; 4'd5: color_r=4'hF; 4'd6: color_r=4'h0;
            4'd7: color_r=4'hF; default: color_r=4'h0;
        endcase end
    endfunction
    function [3:0] color_g; input [3:0] id; begin
        case(id)
            4'd1: color_g=4'hF; 4'd2: color_g=4'hF; 4'd3: color_g=4'h0;
            4'd4: color_g=4'hF; 4'd5: color_g=4'h0; 4'd6: color_g=4'h0;
            4'd7: color_g=4'h8; default: color_g=4'h0;
        endcase end
    endfunction
    function [3:0] color_b; input [3:0] id; begin
        case(id)
            4'd1: color_b=4'hF; 4'd2: color_b=4'h0; 4'd3: color_b=4'h8;
            4'd4: color_b=4'h0; 4'd5: color_b=4'h0; 4'd6: color_b=4'hF;
            4'd7: color_b=4'h0; default: color_b=4'h0;
        endcase end
    endfunction

    integer bx, by;
    reg [3:0] cell_id;
    reg       in_board;
    reg       is_border;

    always @(*) begin
        rgb_red   = 4'h0;
        rgb_green = 4'h0;
        rgb_blue  = 4'h0;

        if (video_on) begin
            in_board = (hcount >= BOARD_LEFT) && (hcount < BOARD_LEFT + BOARD_W*CELL) &&
                       (vcount >= BOARD_TOP)  && (vcount < BOARD_TOP  + BOARD_H*CELL);

            is_border = (hcount >= BOARD_LEFT-2 && hcount < BOARD_LEFT + BOARD_W*CELL + 2 &&
                         vcount >= BOARD_TOP-2  && vcount < BOARD_TOP  + BOARD_H*CELL + 2) && !in_board;

            if (is_border) begin
                rgb_red = 4'hF; rgb_green = 4'hF; rgb_blue = 4'hF;
            end else if (in_board) begin
                bx = (hcount - BOARD_LEFT) / CELL;
                by = (vcount - BOARD_TOP)  / CELL;
                cell_id = board[by][bx];

                if (cell_id == 4'd0 &&
                    (bx - px >= 0) && (bx - px < 4) &&
                    (by - py >= 0) && (by - py < 4) &&
                    shape_bit(piece_type, rotation, (by-py), (bx-px)))
                    cell_id = piece_type + 3'd1;

                if (cell_id != 4'd0) begin
                    rgb_red   = color_r(cell_id);
                    rgb_green = color_g(cell_id);
                    rgb_blue  = color_b(cell_id);
                end else begin
                    rgb_red = 4'h1; rgb_green = 4'h1; rgb_blue = 4'h2; 
                end
            end else begin
                rgb_red = 4'h0; rgb_green = 4'h0; rgb_blue = 4'h3;
            end
        end
    end

endmodule