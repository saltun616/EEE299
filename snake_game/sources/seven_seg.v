module seven_seg(
    input clk,
    input [7:0] score,
    output reg [6:0] seg,
    output reg [3:0] an
);

wire [3:0] ones = score % 10;
wire [3:0] tens = (score / 10) % 10;

reg [16:0] refresh_cnt = 0;
always @(posedge clk)
    refresh_cnt <= refresh_cnt + 1;

wire [1:0] digit_sel = refresh_cnt[16:15]; 

reg [3:0] digit_val;
always @(*) begin
    case (digit_sel)
        2'b00: begin an = 4'b1110; digit_val = ones;  end 
        2'b01: begin an = 4'b1101; digit_val = tens;  end
        2'b10: begin an = 4'b1011; digit_val = 4'hF;  end 
        2'b11: begin an = 4'b0111; digit_val = 4'hF;  end 
    endcase
end

always @(*) begin
    case (digit_val) 
        4'h0: seg = 7'b1000000;
        4'h1: seg = 7'b1111001;
        4'h2: seg = 7'b0100100;
        4'h3: seg = 7'b0110000;
        4'h4: seg = 7'b0011001;
        4'h5: seg = 7'b0010010;
        4'h6: seg = 7'b0000010;
        4'h7: seg = 7'b1111000;
        4'h8: seg = 7'b0000000;
        4'h9: seg = 7'b0010000;
        default: seg = 7'b1111111; 
    endcase
end

endmodule