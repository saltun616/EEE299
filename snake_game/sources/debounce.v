module debounce(
    input clk,
    input btn_in,
    output reg btn_out
);

parameter DEBOUNCE_LIMIT = 250000; 

reg btn_sync_0 = 0;
reg btn_sync_1 = 0;
reg [17:0] count = 0;

always @(posedge clk) begin
    btn_sync_0 <= btn_in;
    btn_sync_1 <= btn_sync_0;
end

always @(posedge clk) begin
    if (btn_sync_1 == btn_out) begin
        count <= 0;
    end else begin
        count <= count + 1;
        if (count >= DEBOUNCE_LIMIT) begin
            btn_out <= btn_sync_1;
            count   <= 0;
        end
    end
end

endmodule