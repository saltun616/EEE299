module clk_div(
    input  wire clk_100mhz,
    output reg  clk_25mhz = 0
);
    reg [1:0] counter = 0;

    always @(posedge clk_100mhz) begin
        counter <= counter + 1;
        if (counter == 1) begin
            clk_25mhz <= ~clk_25mhz;
            counter <= 0;
        end
    end
endmodule