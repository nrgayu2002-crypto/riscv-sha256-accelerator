module apb_slave (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        psel,
    input  wire        penable,
    input  wire        pwrite,
    input  wire [31:0] paddr,
    input  wire [31:0] pwdata,
    output reg  [31:0] prdata,
    
    // Interface to Hardware Engine
    output reg         start_hash,
    output reg [511:0] message_block,
    input  wire [7:0]  hw_weight,
    input  wire        done_pqc
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start_hash <= 1'b0;
            message_block <= 512'd0;
            prdata <= 32'd0;
        end else begin
            start_hash <= 1'b0; // Default state
            
            // Write Operation
            if (psel && penable && pwrite) begin
                if (paddr < 32'h0000_0040) begin
                    message_block[paddr*8 +: 32] <= pwdata;
                end
                if (paddr == 32'h0000_003C) begin
                    start_hash <= 1'b1; // Trigger hardware once fully loaded
                end
            end
            
            // Read Operation
            if (psel && penable && !pwrite) begin
                if (paddr == 32'h0000_0100 && done_pqc) begin
                    prdata <= {24'd0, hw_weight};
                end else begin
                    prdata <= 32'd0;
                end
            end
        end
    end
endmodule