module vga_sync(
    input clk100,
    output reg hsync,
    output reg vsync,
    output [9:0] hcount,
    output [9:0] vcount,
    output video_on
);

localparam H_DISPLAY = 640;
localparam H_FRONT   = 16;
localparam H_SYNC    = 96;
localparam H_TOTAL   = 800;

localparam V_DISPLAY = 480;
localparam V_FRONT   = 10;
localparam V_SYNC    = 2;
localparam V_TOTAL   = 525;

reg [1:0] clkdiv = 0;
reg ce_25mhz = 0;
reg [9:0] h_cnt = 0;
reg [9:0] v_cnt = 0;

always @(posedge clk100) begin
    clkdiv   <= clkdiv + 1;
    ce_25mhz <= (clkdiv == 2'd3);
end

always @(posedge clk100) begin
    if (ce_25mhz) begin
        if (h_cnt == H_TOTAL-1) begin
            h_cnt <= 0;
            v_cnt <= (v_cnt == V_TOTAL-1) ? 0 : v_cnt + 1;
        end else begin
            h_cnt <= h_cnt + 1;
        end
    end
end

always @(posedge clk100) begin
    hsync <= ~(h_cnt >= (H_DISPLAY+H_FRONT) && h_cnt < (H_DISPLAY+H_FRONT+H_SYNC));
    vsync <= ~(v_cnt >= (V_DISPLAY+V_FRONT) && v_cnt < (V_DISPLAY+V_FRONT+V_SYNC));
end

assign hcount = h_cnt;
assign vcount = v_cnt;
assign video_on = (h_cnt < H_DISPLAY) && (v_cnt < V_DISPLAY);

endmodule