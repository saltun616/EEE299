module cursor_ctrl (
    input  wire        clk,         
    input  wire [9:0]  pot_x_val,    
    input  wire [9:0]  pot_y_val,    
    input  wire        btn_draw,     
    input  wire        btn_clear,    
    input  wire [2:0]  color_sw,
    output reg  [7:0]  cursor_x = 80,
    output reg  [6:0]  cursor_y = 60,
    output wire        pen_down,
    output wire        clear_req,
    output wire [2:0]  draw_color
);
    localparam CANVAS_W = 160;
    localparam CANVAS_H = 120;

    localparam DEADBAND = 6; 

    assign pen_down   = btn_draw;
    assign clear_req  = btn_clear;
    assign draw_color = color_sw;

    reg [13:0] filter_x = 512 << 4;
    reg [13:0] filter_y = 512 << 4;

    always @(posedge clk) begin
        filter_x <= filter_x + $signed({{4{1'b0}}, pot_x_val} - filter_x[13:4]);
        filter_y <= filter_y + $signed({{4{1'b0}}, pot_y_val} - filter_y[13:4]);
    end

    wire [9:0] smooth_x_val = filter_x[13:4];
    wire [9:0] smooth_y_val = filter_y[13:4];

    wire [17:0] scaled_x = smooth_x_val * 18'd160;
    wire [7:0]  mapped_x = scaled_x[17:10];

    wire [17:0] scaled_y = smooth_y_val * 18'd120;
    wire [6:0]  mapped_y = scaled_y[16:10];

    wire signed [8:0] x_diff = $signed({1'b0, mapped_x}) - $signed({1'b0, cursor_x});
    wire signed [7:0] y_diff = $signed({1'b0, mapped_y}) - $signed({1'b0, cursor_y});

    wire [7:0] abs_x = (x_diff < 0) ? -x_diff : x_diff;
    wire [7:0] abs_y = (y_diff < 0) ? -y_diff : y_diff;

    reg [19:0] tick_cnt = 0;
    wire       move_tick = (tick_cnt == 20'd800_000);

    always @(posedge clk) begin
        tick_cnt <= move_tick ? 20'd0 : tick_cnt + 1'b1;
    end

    always @(posedge clk) begin
        if (move_tick) begin
            if (abs_x > DEADBAND && (abs_x >= (abs_y >> 1))) begin
                if (x_diff > 0 && cursor_x < CANVAS_W - 1)
                    cursor_x <= cursor_x + 1'b1;
                else if (x_diff < 0 && cursor_x > 0)
                    cursor_x <= cursor_x - 1'b1;
            end

            if (abs_y > DEADBAND && (abs_y >= (abs_x >> 1))) begin
                if (y_diff > 0 && cursor_y < CANVAS_H - 1)
                    cursor_y <= cursor_y + 1'b1;
                else if (y_diff < 0 && cursor_y > 0)
                    cursor_y <= cursor_y - 1'b1;
            end
        end
    end

endmodule