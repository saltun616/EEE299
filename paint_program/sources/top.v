module top (
    input  wire        clk,        // 100 MHz Basys3 system clock

    // Dual Potentiometers on JXADC
    input  wire        pot_x_vp,   // J3
    input  wire        pot_x_vn,   // K3
    input  wire        pot_y_vp,   // L3
    input  wire        pot_y_vn,   // M3

    // Controls
    input  wire        sw15,       // Switch 15: Pen-down when ON
    input  wire        btnL,       // Clear canvas button

    // Switches for color select (sw[2:0])
    input  wire [2:0]  sw,

    // VGA output
    output wire        vga_hs,
    output wire        vga_vs,
    output wire [3:0]  vga_r,
    output wire [3:0]  vga_g,
    output wire [3:0]  vga_b
);
    localparam CANVAS_W = 160;

    // ---------------------------------------------------------------
    // Clocking
    // ---------------------------------------------------------------
    wire clk25;
    clk_div u_clk_div (
        .clk100 (clk), 
        .clk25  (clk25)
    );

    // ---------------------------------------------------------------
    // VGA timing
    // ---------------------------------------------------------------
    wire        video_on;
    wire [9:0]  pixel_x, pixel_y;
    vga_sync u_vga_sync (
        .clk25    (clk25),
        .hsync    (vga_hs),
        .vsync    (vga_vs),
        .video_on (video_on),
        .pixel_x  (pixel_x),
        .pixel_y  (pixel_y)
    );

    // ---------------------------------------------------------------
    // Debounced buttons
    // ---------------------------------------------------------------
    wire d_btnC, d_btnL;
    debounce dc (.clk(clk), .btn_in(btnC), .btn_out(d_btnC));
    debounce dl (.clk(clk), .btn_in(btnL), .btn_out(d_btnL));

    // ---------------------------------------------------------------
    // Dual Potentiometers (X and Y Axis Reader)
    // ---------------------------------------------------------------
    wire [9:0] pot_x_val;
    wire [9:0] pot_y_val;

    dual_pot_reader u_dual_pot (
        .clk     (clk),
        .vauxp6  (pot_x_vp),
        .vauxn6  (pot_x_vn),
        .vauxp14 (pot_y_vp),
        .vauxn14 (pot_y_vn),
        .pot_x   (pot_x_val),
        .pot_y   (pot_y_val)
    );

    // ---------------------------------------------------------------
    // Cursor / pen / color
    // ---------------------------------------------------------------
    wire [7:0] cursor_x;
    wire [6:0] cursor_y;
    wire       pen_down, clear_req;
    wire [2:0] draw_color;

    cursor_ctrl u_cursor (
        .clk        (clk),
        .pot_x_val  (pot_x_val),
        .pot_y_val  (pot_y_val),
        .btn_draw   (sw15),      // High when SW15 is turned ON
        .btn_clear  (d_btnL),
        .color_sw   (sw),
        .cursor_x   (cursor_x),
        .cursor_y   (cursor_y),
        .pen_down   (pen_down),
        .clear_req  (clear_req),
        .draw_color (draw_color)
    );

    // ---------------------------------------------------------------
    // Clear-screen FSM: sweeps every address once when clear_req rises
    // ---------------------------------------------------------------
    reg         clearing    = 0;
    reg [14:0]  clear_addr  = 0;
    reg         clear_req_d = 0;

    always @(posedge clk) begin
        clear_req_d <= clear_req;
        if (clear_req && !clear_req_d) begin
            clearing   <= 1;
            clear_addr <= 0;
        end else if (clearing) begin
            if (clear_addr == 15'd19199)
                clearing <= 0;
            else
                clear_addr <= clear_addr + 1'b1;
        end
    end

    // ---------------------------------------------------------------
    // Frame buffer write side: clearing takes priority over drawing
    // ---------------------------------------------------------------
    wire [14:0] draw_addr = cursor_y * CANVAS_W + cursor_x;

    wire        fb_we    = clearing ? 1'b1       : pen_down;
    wire [14:0] fb_waddr = clearing ? clear_addr : draw_addr;
    wire [2:0]  fb_wcol  = clearing ? 3'b000     : draw_color;

    // ---------------------------------------------------------------
    // Frame buffer read side: map VGA pixel coords -> canvas cell
    // ---------------------------------------------------------------
    wire [14:0] read_addr = (pixel_y >> 2) * CANVAS_W + (pixel_x >> 2);
    wire [2:0]  cell_color;

    frame_buffer u_fb (
        .clk         (clk),
        .we          (fb_we),
        .write_addr  (fb_waddr),
        .write_color (fb_wcol),
        .read_addr   (read_addr),
        .read_color  (cell_color)
    );

    // ---------------------------------------------------------------
    // Cursor outline overlay (drawn live, never stored in the buffer)
    // ---------------------------------------------------------------
    wire in_cursor_cell = (pixel_x >> 2 == cursor_x) &&
                          (pixel_y >> 2 == cursor_y);
    wire on_cell_border  = (pixel_x[1:0] == 2'b00) ||
                          (pixel_y[1:0] == 2'b00);
    wire show_cursor     = in_cursor_cell && on_cell_border;

    // ---------------------------------------------------------------
    // Final color mux: 3-bit palette -> 4-bit VGA channels
    // ---------------------------------------------------------------
    wire [2:0] out_color = show_cursor ? 3'b111 : cell_color;

    assign vga_r = (video_on && out_color[2]) ? 4'hF : 4'h0;
    assign vga_g = (video_on && out_color[1]) ? 4'hF : 4'h0;
    assign vga_b = (video_on && out_color[0]) ? 4'hF : 4'h0;

endmodule