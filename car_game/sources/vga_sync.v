module vga_sync(
    input  wire clk_25mhz,
    output wire hsync,
    output wire vsync,
    output wire video_on,
    output wire [9:0] pixel_x,
    output wire [9:0] pixel_y
);
    localparam H_DISPLAY = 640, H_FRONT = 16, H_SYNC = 96, H_BACK = 48;
    localparam V_DISPLAY = 480, V_FRONT = 10, V_SYNC = 2,  V_BACK = 33;
    localparam H_TOTAL = H_DISPLAY + H_FRONT + H_SYNC + H_BACK; // 800
    localparam V_TOTAL = V_DISPLAY + V_FRONT + V_SYNC + V_BACK; // 525

    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    always @(posedge clk_25mhz) begin
        if (h_count == H_TOTAL - 1) begin
            h_count <= 0;
            v_count <= (v_count == V_TOTAL - 1) ? 0 : v_count + 1;
        end else begin
            h_count <= h_count + 1;
        end
    end

    assign hsync = ~((h_count >= H_DISPLAY + H_FRONT) &&
                      (h_count <  H_DISPLAY + H_FRONT + H_SYNC));
    assign vsync = ~((v_count >= V_DISPLAY + V_FRONT) &&
                      (v_count <  V_DISPLAY + V_FRONT + V_SYNC));

    assign video_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);
    assign pixel_x  = h_count;
    assign pixel_y  = v_count;
endmodule