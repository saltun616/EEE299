module game_logic(
    input  wire clk_25mhz,
    input  wire video_on,
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire vsync,
    input  wire btn_up,
    input  wire btn_down,
    input  wire reset,
    output reg [3:0] vga_red,
    output reg [3:0] vga_green,
    output reg [3:0] vga_blue,
    output wire game_over
);
    parameter CAR_W = 40;
    parameter CAR_H = 30;
    parameter PLAYER_X = 60;

    reg [9:0] player_y = 210;

    reg [9:0] obs0_x = 640, obs1_x = 780, obs2_x = 920;
    reg [9:0] obs0_y = 100, obs1_y = 250, obs2_y = 400;

    reg [9:0] speed = 4;
    reg [23:0] speed_timer = 0;
    reg [15:0] score = 0;
    reg collided = 0;
    assign game_over = collided;

    wire [15:0] rand0, rand1, rand2;
    lfsr16 #(.SEED(16'hACE1)) u_lfsr0(.clk(vsync), .rand_out(rand0));
    lfsr16 #(.SEED(16'h1234)) u_lfsr1(.clk(vsync), .rand_out(rand1));
    lfsr16 #(.SEED(16'hBEEF)) u_lfsr2(.clk(vsync), .rand_out(rand2));

    always @(posedge vsync) begin
        if (reset) begin
            player_y <= 210;
        end else if (!collided) begin
            if (btn_up   && player_y > 10)              player_y <= player_y - 8;
            if (btn_down && player_y < 480 - CAR_H - 10) player_y <= player_y + 8;
        end
    end

    always @(posedge vsync) begin
        if (reset) begin
            speed_timer <= 0;
            speed <= 4;
        end else if (!collided) begin
            speed_timer <= speed_timer + 1;
            if (speed_timer == 24'd180) begin
                speed_timer <= 0;
                if (speed < 20) speed <= speed + 1;
            end
        end
    end

    always @(posedge vsync) begin
        if (reset) begin
            obs0_x <= 640;
            obs0_y <= 10 + (rand0 % 430);
        end else if (!collided) begin
            if (obs0_x <= speed) begin
                obs0_x <= 640 + (rand0 % 100);
                obs0_y <= 10 + (rand0 % 430);
                score  <= score + 1;
            end else begin
                obs0_x <= obs0_x - speed;
            end
        end
    end

    always @(posedge vsync) begin
        if (reset) begin
            obs1_x <= 780;
            obs1_y <= 10 + (rand1 % 430);
        end else if (!collided) begin
            if (obs1_x <= speed) begin
                obs1_x <= 640 + (rand1 % 100);
                obs1_y <= 10 + (rand1 % 430);
                score  <= score + 1;
            end else begin
                obs1_x <= obs1_x - speed;
            end
        end
    end

    always @(posedge vsync) begin
        if (reset) begin
            obs2_x <= 920;
            obs2_y <= 10 + (rand2 % 430);
        end else if (!collided) begin
            if (obs2_x <= speed) begin
                obs2_x <= 640 + (rand2 % 100);
                obs2_y <= 10 + (rand2 % 430);
                score  <= score + 1;
            end else begin
                obs2_x <= obs2_x - speed;
            end
        end
    end

    wire coll0 = (obs0_x < PLAYER_X + CAR_W) && (obs0_x + CAR_W > PLAYER_X) &&
                 (obs0_y < player_y + CAR_H) && (obs0_y + CAR_H > player_y);
    wire coll1 = (obs1_x < PLAYER_X + CAR_W) && (obs1_x + CAR_W > PLAYER_X) &&
                 (obs1_y < player_y + CAR_H) && (obs1_y + CAR_H > player_y);
    wire coll2 = (obs2_x < PLAYER_X + CAR_W) && (obs2_x + CAR_W > PLAYER_X) &&
                 (obs2_y < player_y + CAR_H) && (obs2_y + CAR_H > player_y);

    always @(posedge vsync) begin
        if (reset)
            collided <= 0;
        else if (coll0 || coll1 || coll2)
            collided <= 1;
    end

    wire in_player = (pixel_x >= PLAYER_X) && (pixel_x < PLAYER_X + CAR_W) &&
                     (pixel_y >= player_y) && (pixel_y < player_y + CAR_H);

    wire in_obs0 = (pixel_x >= obs0_x) && (pixel_x < obs0_x + CAR_W) &&
                   (pixel_y >= obs0_y) && (pixel_y < obs0_y + CAR_H);
    wire in_obs1 = (pixel_x >= obs1_x) && (pixel_x < obs1_x + CAR_W) &&
                   (pixel_y >= obs1_y) && (pixel_y < obs1_y + CAR_H);
    wire in_obs2 = (pixel_x >= obs2_x) && (pixel_x < obs2_x + CAR_W) &&
                   (pixel_y >= obs2_y) && (pixel_y < obs2_y + CAR_H);

    always @(posedge clk_25mhz) begin
        if (!video_on) begin
            vga_red <= 0; vga_green <= 0; vga_blue <= 0;
        end else if (collided) begin
            vga_red <= 4'hF; vga_green <= 0; vga_blue <= 0;
        end else if (in_player) begin
            vga_red <= 0; vga_green <= 4'hF; vga_blue <= 0;
        end else if (in_obs0 || in_obs1 || in_obs2) begin
            vga_red <= 4'hF; vga_green <= 4'h8; vga_blue <= 0;
        end else begin
            vga_red <= 4'h2; vga_green <= 4'h2; vga_blue <= 4'h2;
        end
    end
endmodule