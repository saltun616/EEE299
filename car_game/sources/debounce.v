module debounce(
    input  wire clk,
    input  wire btn_in,
    output reg  btn_out = 0
);
    reg [19:0] counter = 0;
    reg btn_sync = 0;

    always @(posedge clk) begin
        btn_sync <= btn_in;
        if (btn_sync == btn_out) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
            if (counter == 20'hFFFFF)
                btn_out <= btn_sync;
        end
    end
endmodule