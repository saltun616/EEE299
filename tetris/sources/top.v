module top(
    input  wire clk100,        
    input  wire btnC,         

    output wire [3:0] kp_col,  
    input  wire [3:0] kp_row,  

    output wire        Hsync,
    output wire        Vsync,
    output wire [3:0]  vgaRed,
    output wire [3:0]  vgaGreen,
    output wire [3:0]  vgaBlue,

    output wire [15:0] led
);

    wire clk25;
    wire [9:0] hcount;
    wire [9:0] vcount;
    wire       video_on;
    wire       frame_tick;   

    wire reset;
    assign reset = btnC;

    vga_controller vga_ctrl (
        .clk100     (clk100),
        .reset      (reset),
        .clk25_out  (clk25),
        .hcount     (hcount),
        .vcount     (vcount),
        .hsync      (Hsync),
        .vsync      (Vsync),
        .video_on   (video_on),
        .frame_tick (frame_tick)
    );

    wire [3:0] key_code;
    wire       key_pulse;

    keypad_scanner kp (
        .clk        (clk25),
        .reset      (reset),
        .scan_tick  (frame_tick),
        .kp_col     (kp_col),
        .kp_row     (kp_row),
        .key_code   (key_code),
        .key_pulse  (key_pulse)
    );

    tetris_game game (
        .clk        (clk25),
        .reset      (reset),
        .frame_tick (frame_tick),
        .key_code   (key_code),
        .key_pulse  (key_pulse),
        .hcount     (hcount),
        .vcount     (vcount),
        .video_on   (video_on),
        .rgb_red    (vgaRed),
        .rgb_green  (vgaGreen),
        .rgb_blue   (vgaBlue),
        .led_out    (led)
    );

endmodule
