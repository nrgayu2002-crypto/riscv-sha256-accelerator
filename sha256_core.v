
module sha256_core (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start_hash,
    input  wire [511:0] message_block,
    output reg  [255:0] final_hash,
    output reg          hash_valid
);
    
    reg [31:0] a, b, c, d, e, f, g, h;
    reg [6:0]  round_counter;
    
    // NIST FIPS 180-4 Non-linear functions
    wire [31:0] ch_func  = (e & f) ^ (~e & g);
    wire [31:0] maj_func = (a & b) ^ (a & c) ^ (b & c);
    wire [31:0] sigma0   = {a[1:0], a[31:2]} ^ {a[12:0], a[31:13]} ^ {a[21:0], a[31:22]};
    wire [31:0] sigma1   = {e[5:0], e[31:6]} ^ {e[10:0], e[31:11]} ^ {e[24:0], e[31:25]};
    
    // Simplified temporary words (Assumes w_t and k_t logic is expanded here)
    wire [31:0] w_t = 32'h00000000; // Placeholder for message schedule output
    wire [31:0] k_t = 32'h428a2f98; // Placeholder for round constant ROM output
    
    wire [31:0] t1 = h + sigma1 + ch_func + k_t + w_t;
    wire [31:0] t2 = sigma0 + maj_func;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            round_counter <= 0;
            hash_valid    <= 0;
            final_hash    <= 256'd0;
        end else if (start_hash) begin
            if (round_counter < 64) begin
                h <= g;
                g <= f;
                f <= e;
                e <= d + t1;
                d <= c;
                c <= b;
                b <= a;
                a <= t1 + t2;
                round_counter <= round_counter + 1;
                hash_valid <= 1'b0;
            end else begin
                final_hash <= {a, b, c, d, e, f, g, h};
                hash_valid <= 1'b1;
            end
        end else begin
            hash_valid <= 1'b0;
        end
    end
endmodule