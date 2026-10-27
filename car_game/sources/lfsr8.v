module lfsr16 #(
    parameter [15:0] SEED = 16'hACE1
)(
    input  wire clk,
    output reg [15:0] rand_out
);
    initial rand_out = SEED;
    wire feedback = rand_out[15] ^ rand_out[13] ^ rand_out[12] ^ rand_out[10];

    always @(posedge clk) begin
        rand_out <= {rand_out[14:0], feedback};
    end
endmodule