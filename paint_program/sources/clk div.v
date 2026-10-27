module clk_div (
    input  wire clk100,
    output reg  clk25 = 0
);
    reg [1:0] count = 0;

    always @(posedge clk100) begin
        count <= count + 1'b1;
        if (count == 2'd1) begin
            clk25 <= ~clk25;
            count <= 2'd0;
        end
    end
endmodule