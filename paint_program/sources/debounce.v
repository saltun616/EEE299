module debounce (
    input  wire clk,
    input  wire btn_in,
    output reg  btn_out = 0
);
    reg [19:0] cnt = 0;
    reg sync0 = 0, sync1 = 0;

    always @(posedge clk) begin
        sync0 <= btn_in;
        sync1 <= sync0;
    end

    always @(posedge clk) begin
        if (sync1 == btn_out) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1'b1;
            if (cnt == 20'hF_FFFF)
                btn_out <= sync1;
        end
    end
endmodule