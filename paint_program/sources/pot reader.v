module dual_pot_reader (
    input  wire        clk,        
    input  wire        vauxp6,     
    input  wire        vauxn6,     
    input  wire        vauxp14,    
    input  wire        vauxn14,    
    output reg  [9:0]  pot_x = 512,
    output reg  [9:0]  pot_y = 512
);

    wire [15:0] do_out;
    wire [4:0]  channel_out;
    wire        eoc_out;
    wire        drdy_out;

    localparam CHAN_VAUX6  = 5'd22;
    localparam CHAN_VAUX14 = 5'd30;

    xadc_wiz_0 xadc_inst (
        .daddr_in   ({2'b00, channel_out}), 
        .den_in     (eoc_out),                
        .di_in      (16'h0000),
        .dwe_in     (1'b0),
        .do_out     (do_out),
        .drdy_out   (drdy_out),
        .dclk_in    (clk),
        .reset_in   (1'b0),
        .vauxp6     (vauxp6),                
        .vauxn6     (vauxn6),
        .vauxp14    (vauxp14),
        .vauxn14    (vauxn14),
        .eoc_out    (eoc_out),
        .channel_out(channel_out),
        .busy_out   (),
        .eos_out    (),
        .alarm_out  (),
        .vp_in      (1'b0),
        .vn_in      (1'b0)
    );

    always @(posedge clk) begin
        if (drdy_out) begin
            case (channel_out)
                CHAN_VAUX6:  pot_x <= do_out[15:6];
                CHAN_VAUX14: pot_y <= do_out[15:6];
                default:     ;
            endcase
        end
    end

endmodule