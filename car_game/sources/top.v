module top(
    input  wire clk,
    input  wire btnU,
    input  wire btnD,
    input  wire btnC,
    output wire hsync,
    output wire vsync,
    output wire [3:0] vga_red,
    output wire [3:0] vga_green,
    output wire [3:0] vga_blue
);
    wire clk_25mhz;
    wire video_on;
    wire [9:0] pixel_x, pixel_y;
    wire btnU_db, btnD_db, btnC_db;

    clk_div u_clkdiv(.clk_100mhz(clk), .clk_25mhz(clk_25mhz));

    debounce u_debU(.clk(clk), .btn_in(btnU), .btn_out(btnU_db));
    debounce u_debD(.clk(clk), .btn_in(btnD), .btn_out(btnD_db));
    debounce u_debC(.clk(clk), .btn_in(btnC), .btn_out(btnC_db));

    vga_sync u_vga(
        .clk_25mhz(clk_25mhz),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    game_logic u_game(
        .clk_25mhz(clk_25mhz),
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .vsync(vsync),
        .btn_up(btnU_db),
        .btn_down(btnD_db),
        .reset(btnC_db),
        .vga_red(vga_red),
        .vga_green(vga_green),
        .vga_blue(vga_blue),
        .game_over()
    );
endmodule