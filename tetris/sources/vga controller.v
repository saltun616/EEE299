module vga_controller(
    input  wire clk100,
    input  wire reset,
    output wire clk25_out,
    output reg  [9:0] hcount,
    output reg  [9:0] vcount,
    output wire hsync,
    output wire vsync,
    output wire video_on,
    output reg  frame_tick    
);

    reg [1:0] clkdiv;
    always @(posedge clk100) begin
        clkdiv <= clkdiv + 1'b1;
    end
    assign clk25_out = clkdiv[1];

    localparam H_VISIBLE = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = 800;

    localparam V_VISIBLE = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = 525;

    always @(posedge clk25_out) begin
        if (reset) begin
            hcount <= 0;
            vcount <= 0;
            frame_tick <= 0;
        end else begin
            frame_tick <= 0;
            if (hcount == H_TOTAL-1) begin
                hcount <= 0;
                if (vcount == V_TOTAL-1) begin
                    vcount <= 0;
                    frame_tick <= 1;   
                end else begin
                    vcount <= vcount + 1'b1;
                end
            end else begin
                hcount <= hcount + 1'b1;
            end
        end
    end

    assign hsync = ~((hcount >= H_VISIBLE + H_FRONT) &&
                      (hcount <  H_VISIBLE + H_FRONT + H_SYNC));
    assign vsync = ~((vcount >= V_VISIBLE + V_FRONT) &&
                      (vcount <  V_VISIBLE + V_FRONT + V_SYNC));
    assign video_on = (hcount < H_VISIBLE) && (vcount < V_VISIBLE);

endmodule