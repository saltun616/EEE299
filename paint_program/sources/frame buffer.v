module frame_buffer (
    input  wire        clk,

    input  wire        we,
    input  wire [14:0] write_addr,   
    input  wire [2:0]  write_color,

    input  wire [14:0] read_addr,    
    output reg  [2:0]  read_color
);
    reg [2:0] mem [0:19199];

    integer i;
    initial begin
        for (i = 0; i < 19200; i = i + 1)
            mem[i] = 3'b000; 
    end

    always @(posedge clk) begin
        if (we)
            mem[write_addr] <= write_color;
        read_color <= mem[read_addr];
    end

endmodule