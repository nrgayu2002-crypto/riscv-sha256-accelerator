
module u_ram (
    input  wire        clk,
    input  wire        we,
    input  wire [31:0] data_addr,
    input  wire [31:0] data_wdata,
    output reg  [31:0] data_rdata
);

    reg [31:0] ram_memory [0:255];

    always @(posedge clk) begin
        if (we) begin
            ram_memory[data_addr >> 2] <= data_wdata;
        end
        data_rdata <= ram_memory[data_addr >> 2];
    end
endmodule