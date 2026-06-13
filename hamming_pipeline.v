
module hamming_pipeline (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [255:0] hash_in,
    input  wire         valid_in,
    output reg  [7:0]   weight_out,
    output reg          valid_out
);

    integer i;
    reg [7:0] bit_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            weight_out <= 8'd0;
            valid_out  <= 1'b0;
        end else if (valid_in) begin
            // 8-stage discrete calculation implementation
            bit_count = 0;
            for (i = 0; i < 256; i = i + 1) begin
                if (hash_in[i]) bit_count = bit_count + 1;
            end
            weight_out <= bit_count;
            valid_out  <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end
endmodule