module snake_game #(
    parameter GRID_W  = 32,
    parameter GRID_H  = 24,
    parameter MAX_LEN = 64
)(
    input clk,
    input reset,
    input game_tick,
    input [1:0] dir,
    input [15:0] rand_num,
    output reg [5*MAX_LEN-1:0] snake_x_flat,
    output reg [5*MAX_LEN-1:0] snake_y_flat,
    output reg [6:0] length,
    output reg [4:0] food_x,
    output reg [4:0] food_y,
    output reg game_over,
    output reg [7:0] score
);

localparam UP=2'd0, DOWN=2'd1, LEFT=2'd2, RIGHT=2'd3;

integer i;

wire [4:0] head_x = snake_x_flat[4:0];
wire [4:0] head_y = snake_y_flat[4:0];

reg [4:0] new_head_x, new_head_y;
reg wall_hit, self_hit, ate_food;

always @(*) begin
    new_head_x = head_x;
    new_head_y = head_y;
    wall_hit = 0;
    case (dir)
        UP:    if (head_y == 0)        wall_hit = 1; else new_head_y = head_y - 1;
        DOWN:  if (head_y == GRID_H-1) wall_hit = 1; else new_head_y = head_y + 1;
        LEFT:  if (head_x == 0)        wall_hit = 1; else new_head_x = head_x - 1;
        RIGHT: if (head_x == GRID_W-1) wall_hit = 1; else new_head_x = head_x + 1;
    endcase

    self_hit = 0;
    for (i = 0; i < MAX_LEN; i = i + 1) begin
        if (!wall_hit && i < (length-1)) begin
            if (snake_x_flat[i*5 +: 5] == new_head_x && snake_y_flat[i*5 +: 5] == new_head_y)
                self_hit = 1;
        end
    end

    ate_food = (!wall_hit) && (new_head_x == food_x) && (new_head_y == food_y);
end

wire [4:0] rand_x = rand_num[4:0];
wire [4:0] rand_y_raw = rand_num[13:9];
wire [4:0] rand_y = (rand_y_raw >= GRID_H) ? (rand_y_raw - GRID_H) : rand_y_raw;

always @(posedge clk) begin
    if (reset) begin
        length    <= 3;
        game_over <= 0;
        score     <= 0;
        snake_x_flat[0*5 +: 5] <= 16; snake_y_flat[0*5 +: 5] <= 12;
        snake_x_flat[1*5 +: 5] <= 15; snake_y_flat[1*5 +: 5] <= 12;
        snake_x_flat[2*5 +: 5] <= 14; snake_y_flat[2*5 +: 5] <= 12;
        food_x <= 20;
        food_y <= 12;
    end else if (game_tick && !game_over) begin
        if (wall_hit || self_hit) begin
            game_over <= 1;
        end else begin
            for (i = MAX_LEN-1; i > 0; i = i - 1) begin
                snake_x_flat[i*5 +: 5] <= snake_x_flat[(i-1)*5 +: 5];
                snake_y_flat[i*5 +: 5] <= snake_y_flat[(i-1)*5 +: 5];
            end
            snake_x_flat[0*5 +: 5] <= new_head_x;
            snake_y_flat[0*5 +: 5] <= new_head_y;

            if (ate_food) begin
                if (length < MAX_LEN) length <= length + 1;
                if (score < 8'd255) score <= score + 1;
                food_x <= rand_x;
                food_y <= rand_y;
            end
        end
    end
end

endmodule