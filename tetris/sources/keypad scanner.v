module keypad_scanner(
    input  wire clk,
    input  wire reset,
    input  wire scan_tick,
    output reg  [3:0] kp_col,
    input  wire [3:0] kp_row,
    output reg  [3:0] key_code,
    output reg        key_pulse
);

    localparam SETTLE_CYCLES = 8;  
    localparam REPEAT_DELAY  = 12; 
    localparam REPEAT_RATE   = 4;  

    reg [1:0] col_idx;
    reg [3:0] settle_cnt;
    reg       scanning;

    reg       found_hit;
    reg [3:0] found_key;   

    reg [3:0] sweep_result;
    reg       sweep_valid;
    reg [3:0] sweep_result_prev;
    reg       sweep_valid_prev;
    reg       sweep_done;        

    reg [3:0] last_stable;
    reg [7:0] hold_cnt;
    reg       repeating;

    always @(*) begin
        case (col_idx)
            2'd0: kp_col = 4'b1110;
            2'd1: kp_col = 4'b1101;
            2'd2: kp_col = 4'b1011;
            default: kp_col = 4'b0111;
        endcase
    end

    reg [1:0] row_hit;
    reg       any_hit;
    always @(*) begin
        any_hit = 1'b0;
        row_hit = 2'd0;
        if (!kp_row[0]) begin any_hit = 1'b1; row_hit = 2'd0; end
        else if (!kp_row[1]) begin any_hit = 1'b1; row_hit = 2'd1; end
        else if (!kp_row[2]) begin any_hit = 1'b1; row_hit = 2'd2; end
        else if (!kp_row[3]) begin any_hit = 1'b1; row_hit = 2'd3; end
    end

    always @(posedge clk) begin
        if (reset) begin
            col_idx           <= 2'd0;
            settle_cnt        <= 4'd0;
            scanning          <= 1'b0;
            found_hit         <= 1'b0;
            found_key         <= 4'd0;
            sweep_result      <= 4'd0;
            sweep_valid       <= 1'b0;
            sweep_result_prev <= 4'd0;
            sweep_valid_prev  <= 1'b0;
            sweep_done        <= 1'b0;
            last_stable       <= 4'd0;
            hold_cnt          <= 8'd0;
            repeating         <= 1'b0;
            key_code          <= 4'd0;
            key_pulse         <= 1'b0;
        end else begin
            key_pulse  <= 1'b0;
            sweep_done <= 1'b0;

            if (!scanning) begin
                if (scan_tick) begin
                    scanning   <= 1'b1;
                    col_idx    <= 2'd0;
                    settle_cnt <= 4'd0;
                    found_hit  <= 1'b0;
                    found_key  <= 4'd0;
                end
            end else begin
                if (settle_cnt < SETTLE_CYCLES - 1) begin
                    settle_cnt <= settle_cnt + 1'b1;
                end else begin
                    settle_cnt <= 4'd0;

                    if (any_hit) begin
                        found_hit <= 1'b1;
                        found_key <= {row_hit, col_idx};
                    end

                    if (col_idx == 2'd3) begin
                        sweep_result_prev <= sweep_result;
                        sweep_valid_prev  <= sweep_valid;
                        sweep_result      <= any_hit ? {row_hit, col_idx} : found_key;
                        sweep_valid       <= found_hit || any_hit;
                        sweep_done        <= 1'b1;
                        scanning          <= 1'b0;
                    end else begin
                        col_idx <= col_idx + 1'b1;
                    end
                end
            end

            if (sweep_done) begin
                if (sweep_valid && sweep_valid_prev &&
                    (sweep_result == sweep_result_prev)) begin

                    if (sweep_result != last_stable) begin
                        last_stable <= sweep_result;
                        key_code    <= sweep_result;
                        key_pulse   <= 1'b1;
                        hold_cnt    <= 8'd0;
                        repeating   <= 1'b0;
                    end else begin
                        if (!repeating) begin
                            if (hold_cnt >= REPEAT_DELAY - 1) begin
                                key_code  <= sweep_result;
                                key_pulse <= 1'b1;
                                hold_cnt  <= 8'd0;
                                repeating <= 1'b1;
                            end else begin
                                hold_cnt <= hold_cnt + 1'b1;
                            end
                        end else begin
                            if (hold_cnt >= REPEAT_RATE - 1) begin
                                key_code  <= sweep_result;
                                key_pulse <= 1'b1;
                                hold_cnt  <= 8'd0;
                            end else begin
                                hold_cnt <= hold_cnt + 1'b1;
                            end
                        end
                    end
                end else if (!sweep_valid && !sweep_valid_prev) begin
                    last_stable <= 4'd0;
                    hold_cnt    <= 8'd0;
                    repeating   <= 1'b0;
                end
            end
        end
    end

endmodule
