module vga_sync (
    input  wire       clk25,
    output wire       hsync,
    output wire       vsync,
    output wire       video_on,
    output wire [9:0] pixel_x,
    output wire [9:0] pixel_y
);
    localparam H_DISPLAY = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = H_DISPLAY + H_FRONT + H_SYNC + H_BACK; 

    localparam V_DISPLAY = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = V_DISPLAY + V_FRONT + V_SYNC + V_BACK; 

    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    always @(posedge clk25) begin
        if (h_count == H_TOTAL - 1) begin
            h_count <= 0;
            v_count <= (v_count == V_TOTAL - 1) ? 10'd0 : v_count + 1'b1;
        end else begin
            h_count <= h_count + 1'b1;
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